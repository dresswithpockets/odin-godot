import sys
import os
import pathlib
from dataclasses import dataclass

@dataclass
class Arg:
    name: str
    type: str
    is_func_ptr: bool
    original: str

@dataclass
class TypeDef:
    doc: str
    type_name: str
    func_name: str
    return_type: str
    args: list[Arg]

no_prefix_types = [
    "VariantPtr",
    "StringNamePtr",
    "StringPtr",
    "ObjectPtr",
    "TypePtr",
    "MethodBindPtr",
    "RefPtr"
]

type_map = {
    "GDExtensionVariantOperator": "VariantOperator",
    "GDExtensionCallErrorType": "CallErrorType",
    "GDExtensionCallError": "CallError",
    "GDExtensionVariantFromTypeConstructorFunc": "VariantFromTypeConstructorProc",
    "GDExtensionTypeFromVariantConstructorFunc": "TypeFromVariantConstructorProc",
    "GDExtensionPtrOperatorEvaluator": "PtrOperatorEvaluator",
    "GDExtensionPtrBuiltInMethod": "PtrBuiltInMethod",
    "GDExtensionPtrConstructor": "PtrConstructor",
    "GDExtensionPtrDestructor": "PtrDestructor",
    "GDExtensionPtrSetter": "PtrSetter",
    "GDExtensionPtrGetter": "PtrGetter",
    "GDExtensionPtrIndexedSetter": "PtrIndexedSetter",
    "GDExtensionPtrIndexedGetter": "PtrIndexedGetter",
    "GDExtensionPtrKeyedSetter": "PtrKeyedSetter",
    "GDExtensionPtrKeyedChecker": "PtrKeyedGetter",
    "GDExtensionPtrKeyedGetter": "PtrKeyedGetter",
    "GDExtensionPtrUtilityFunction": "PtrUtilityFunction",
    "GDInstanceBindingCallbacks": "InstanceBindingCallbacks",
    "GDExtensionScriptInstancePtr": "ScriptInstancePtr",
    "GDExtensionPropertyInfo": "PropertyInfo",
    "GDExtensionVariantType": "VariantType",
    "GDExtensionBool": "bool",
    "GDExtensionInt": "i64",
    "GDObjectInstanceID": "ObjectInstanceId",
    "int8_t": "i8",
    "int16_t": "i16",
    "int32_t": "i32",
    "int64_t": "i64",
    "uint8_t": "u8",
    "uint16_t": "u16",
    "uint32_t": "u32",
    "uint64_t": "u64",
    "char": "c.char",
    "char16_t": "u16",
    "char32_t": "u32",
    "wchar_t": "c.wchar_t",
    "size_t": "c.size_t",
    "double": "f64",
}

def parse_args(args, line):
    arg_strs: list[(bool, str)] = []
    paren_depth = 0
    current_arg_str = ""
    for c in args:
        if c == '(':
            paren_depth += 1
        elif c == ')':
            paren_depth -= 1
        elif c == ',' and paren_depth == 0:
            arg_strs.append(current_arg_str)
            current_arg_str = ""
            continue

        current_arg_str += c

    if len(current_arg_str) > 0:
        arg_strs.append(current_arg_str)

    for arg_str in arg_strs:
        arg_str = arg_str.strip().removeprefix("const").strip()
        arg_parts = arg_str.split(" ", 1)
        assert len(arg_parts) == 2, f"Unexpected arg parts in line: {line}"
        while arg_parts[1].startswith("*"):
            # the arg type is a pointer
            arg_parts[0] = arg_parts[0] + " *"
            arg_parts[1] = arg_parts[1][1:]

        # if the arg type is a function pointer, this needs to be manually resolved
        is_func_ptr = arg_parts[1].startswith("(*")
        yield Arg(arg_parts[1], arg_parts[0], is_func_ptr, arg_str)


def convert_type(type_name: str) -> str | None:
    ptr_depth = 0 if "*" not in type_name else type_name.count("*", type_name.index("*"))
    type_name = type_name.replace("*", "").strip()
    if type_name == "void":
        if ptr_depth == 0:
            return None
        return "rawptr"

    type_name = type_map.get(type_name, type_name)
    for suffix in no_prefix_types:
        if type_name in [ f"GDExtension{suffix}", f"GDExtensionUninitialized{suffix}", f"GDExtensionConst{suffix}" ]:
            type_name = suffix
            break

    type_name = type_name.strip().replace("GDExtension", "Extension")
    type_name = ("^" * ptr_depth) + type_name
    return type_name


def write_typedefs(typedefs: list[TypeDef]):
    print("package gdextension\n")
    print("import \"core:c\"\n")

    for typedef in typedefs:
        print(typedef.doc, end="")
        print(f"{typedef.type_name} :: #type proc \"c\" (", end="")
        for i, arg in enumerate(typedef.args):
            if i > 0:
                print(", ", end="")

            if arg.is_func_ptr:
                print(f"/** is_func_ptr **/ {arg.original}", end="")
            else:
                arg_type = convert_type(arg.type)
                print(f"{arg.name}: {arg_type}", end="")
        print(")", end="")
        return_type = convert_type(typedef.return_type)
        if return_type is not None:
            print(f" -> {return_type}", end="")

        print()
        print()


def write_interface(typedefs: list[TypeDef]):
    print("package gdextension\n")

    for typedef in typedefs:
        print(typedef.doc, end="")
        print(f"{typedef.func_name}: {typedef.type_name}\n")

    print()
    print("init :: proc \"contextless\" (library_ptr: ExtensionClassLibraryPtr, get_proc_address: ExtensionInterfaceGetProcAddress) {")
    print("    library = library_ptr")
    for typedef in typedefs:
        print(f"    {typedef.func_name} = cast({typedef.type_name})get_proc_address(\"{typedef.func_name}\")")
    print("}")



def main():
    if len(sys.argv) != 3:
        print("Expected path to gdextension_interface.h file, followed by mode")
        return

    mode = sys.argv[2]
    assert mode in ["interface", "typedefs"]

    interface_header = sys.argv[1]
    header_contents = []
    in_interface_zone = False
    with open(interface_header) as f:
        for line in f:
            if in_interface_zone:
                header_contents.append(line.rstrip())
            if "*GDExtensionInterfaceGetGodotVersion" in line:
                in_interface_zone = True

    typedefs: list[TypeDef] = []
    current_doc: str = ""
    current_type_name: str = ""
    current_func_name: str = ""
    current_return_type: str = ""
    current_args: list[Arg] = {}
    for line in header_contents:
        if len(line) == 0:
            continue

        if line.startswith("/**") or line.startswith(" *"):
            current_doc += f"{line}\n"
            if line.startswith(" * @name "):
                current_func_name = line[len(" * @name "):]

        if line.startswith("typedef"):
            try:
                func_ptr_left_paren = line.index("(*")
                func_ptr_right_paren = line.index(")", func_ptr_left_paren)
                func_ptr_args_left_paren = line.index("(", func_ptr_right_paren)
                func_ptr_args_right_paren = line.index(");", func_ptr_args_left_paren)
            except ValueError:
                print(f"Error on line: {line}")
                raise
            current_return_type = line[len("typedef"):func_ptr_left_paren].strip().removeprefix("const").strip()
            current_type_name = line[func_ptr_left_paren + 2:func_ptr_right_paren].replace("GDExtension", "Extension")
            args_str = line[func_ptr_args_left_paren + 1:func_ptr_args_right_paren]
            current_args = list(parse_args(args_str, line))

            typedefs.append(TypeDef(current_doc, current_type_name, current_func_name, current_return_type, current_args))
            current_args = []
            current_doc = ""

    if mode == "interface":
        write_interface(typedefs)
    elif mode == "typedefs":
        write_typedefs(typedefs)


if __name__ == "__main__":
    main()

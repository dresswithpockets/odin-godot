import json
from pathlib import Path
from typing import TextIO
from dataclasses import dataclass


alias_map = {
    "Error": "Err",
}


gdinterface_module = "gdinterface"
constructor_type = f"{gdinterface_module}.PtrConstructor"
destructor_type = f"{gdinterface_module}.PtrDestructor"
operator_evaluator_type = f"{gdinterface_module}.PtrOperatorEvaluator"
builtin_method_type = f"{gdinterface_module}.PtrBuiltInMethod"


operator_name_map = {
    "==": "equal",
    "!=": "notequal",
    "<": "less",
    "<=": "lessequal",
    ">": "greater",
    ">=": "greaterequal",

    "+": "add",
    "-": "sub",
    "*": "mul",
    "/": "div",
    "unary-": "neg",
    "unary+": "pos",
    "%": "mod",
    "**": "pow",

    "<<": "bitleft",
    ">>": "bitright",
    "&": "bitand",
    "|": "bitor",
    "^": "bitxor",
    "~": "bitneg",

    "and": "and",
    "or": "or",
    "xor": "xor",
    "not": "not",

    "in": "int",
}


operator_enum_map = {
    "==": "Equal",
    "!=": "NotEqual",
    "<": "Less",
    "<=": "LessEqual",
    ">": "Greater",
    ">=": "GreaterEqual",

    "+": "Add",
    "-": "Subtract",
    "*": "Multiply",
    "/": "Divide",
    "unary-": "Negate",
    "unary+": "Positive",
    "%": "Module",
    "**": "Power",

    "<<": "ShiftLeft",
    ">>": "ShiftRight",
    "&": "BitAnd",
    "|": "BitOr",
    "^": "BitXor",
    "~": "BitNegate",

    "and": "And",
    "or": "Or",
    "xor": "Xor",
    "not": "Not",

    "in": "In",
}

variant_type_map = {
    "int": "Int",
    "float": "Float",
    "bool": "Bool",
}


types_with_odin_string_constructors = ["String", "StringName", "NodePath"]


@dataclass
class GenConfig:

    use_tabs: bool = False
    space_indent_width: int = 4

    @property
    def indent(self):
        return " " * self.space_indent_width if not self.use_tabs else "\t"


config = GenConfig()


def const_to_pascal_case(name: str) -> str:
    s = ""
    in_word = False
    for c in name:
        if c == "_":
            in_word = False
            continue

        if not c.isalpha():
            in_word = False
            s += c
            continue

        if c.isalpha() and not in_word:
            s += c.upper()
            in_word = True
            continue

        s += c.lower()
    assert(len(s) != 0)
    if s[0].isdigit():
        s = "_" + s
    return s


def pascal_to_const_case(name: str) -> str:
    s = ""
    for c in name:
        if c.isalpha() and c.isupper() and len(s) > 0:
            s += f"_{c}"
        else:
            s += c.upper()
    return s


def godot_to_pascal_case(name: str) -> str:
    # godot uses pascal case with ALL CAPS for acronyms
    s = ""
    for i, c in enumerate(name):
        if i == 0:
            s += c.upper()
            continue
        if c.isupper() and (name[i-1].isupper() or name[i-1].isnumeric()):
            if i >= len(name) - 1 or name[i+1].isupper():
                s += c.lower()
                continue
        s += c
    return s


def pascal_to_snake_case(name: str) -> str:
    s = ""
    for c in name:
        if c.isalpha() and c.isupper() and len(s) > 0:
            s += f"_{c.lower()}"
        else:
            s += c.lower()
    return s


def is_pod_type(type_name):
    """
    Those are types for which no class should be generated.
    """
    return type_name in [
        "Nil",
        "void",
        "bool",
        "real_t",
        "float",
        "double",
        "int",
        "int8_t",
        "uint8_t",
        "int16_t",
        "uint16_t",
        "int32_t",
        "int64_t",
        "uint32_t",
        "uint64_t",
    ]


def gen_global_enums(f: TextIO, enums: list):
    for enum in enums:
        name: str = enum["name"]

        # these are already in gdinterface
        if name in ["Variant.Operator", "Variant.Type"]:
            continue

        name = godot_to_pascal_case(name)
        alias = alias_map.get(name)

        const_name = pascal_to_const_case(name)
        const_alias_name = pascal_to_const_case(alias) if alias is not None else None
        is_flags = name.endswith("Flags")
        non_plural_const_name = const_name[:-1] if is_flags or const_name.endswith("s") else const_name
        non_flags_const_name = const_name[:-5] if is_flags else const_name

        values = enum["values"]
        f.write(f"{name} :: enum {{\n")
        for value in values:
            name = value["name"]
            if len(name) != len(const_name):
                name = name.removeprefix(const_name)
            if const_alias_name is not None and len(name) != len(const_alias_name):
                name = name.removeprefix(const_alias_name)
            if len(name) != len(non_plural_const_name):
                name = name.removeprefix(non_plural_const_name)
            if is_flags and len(name) != len(non_flags_const_name):
                name = name.removeprefix(non_flags_const_name)
            name = const_to_pascal_case(name)
            v = value["value"]
            f.write(f"    {name} = {v},\n")
        f.write("}\n\n")


def get_builtin_operator_backing_field(class_name: str, operator: dict) -> str:
    op_name = operator["name"]
    right_type = operator.get("right_type")
    mapped_name = operator_name_map[op_name]
    if right_type is not None:
        return f"__{class_name}__{mapped_name}_{right_type}"
    else:
        return f"__{class_name}__{mapped_name}"


def get_builtin_method_backing_field(class_name: str, method: dict) -> str:
    method_name = method["name"]
    arguments = method.get("arguments", [])
    s = f"__{class_name}__{method_name}"
    if len(arguments) > 0:
        s += "_"
        for arg in arguments:
            arg_type = arg["type"]
            s += f"_{arg_type}"
    
    return s


def gen_builtin_class(f: TextIO, builtin_class: dict, builtin_sizes_map: dict[int], package_name: str, gdinterface_import_path: str="../gdinterface"):
def gen_builtin_class(f: TextIO, builtin_class: dict, builtin_sizes_map: dict[int], package_name: str):
    name: str = builtin_class["name"]
    methods: list = builtin_class.get("methods", [])
    operators: list = builtin_class["operators"]
    constructors: list = builtin_class["constructors"]
    has_destructor: bool = builtin_class["has_destructor"]

    pascal_name = godot_to_pascal_case(name)
    variant_name = variant_type_map.get(name, name)
    snake_name = pascal_to_snake_case(name)

    f.write(f"package {package_name}\n\n")
    f.write("import \"../core\"\n")
    if name in types_with_odin_string_constructors:
        f.write("import \"core:strings\"\n")
    f.write(f"import gdinterface \"../gdinterface\"\n\n")

    f.write(f"{pascal_name} :: struct {{\n")
    f.write(f"    _opaque: {pascal_name}OpaqueType,\n")
    f.write("}\n\n")

    first_configuration = True
    for configuration, sizes in builtin_sizes_map.items():
        size = sizes[name]
        if first_configuration:
            f.write("when ")
            first_configuration = False
        else:
            f.write(" else when ")
        
        f.write(f"gdcore.interface.BUILD_CONFIG == \"{configuration}\" {{\n")
        if (size & (size - 1) == 0) and size != 0 and size < 16:
            size *= 8
            f.write(f"    {pascal_name}OpaqueType :: u{size}\n")
        else:
            f.write(f"    {pascal_name}OpaqueType :: [{size}]u8\n")
        f.write("}")
    f.write("\n\n")

    # generate public/frontend component
    for method in methods:
        method_name = method["name"]
        return_type = method.get("return_type")
        is_vararg = method["is_vararg"]
        # probably dont need is_const
        is_const = method["is_const"]
        is_static = method["is_static"]
        method_hash = method["hash"]
        arguments = method.get("arguments", [])
        # TODO: generate methods

    for operator in operators:
        pass
        # TODO: generate operator methods
    
    base_constructor_name = f"new_{snake_name}"
    constructor_names = []
    for constructor in constructors:
        index = constructor["index"]
        arguments = constructor.get("arguments")
        suffix = "_default"
        arg_list = ""
        copy_into = ""
        call_list = ""
        if arguments is not None:
            suffix = ""
            for argument in arguments:
                arg_name = argument["name"]
                arg_type = argument["type"]
                pascal_type = godot_to_pascal_case(arg_type) if not is_pod_type(arg_type) else arg_type
                snake_type = pascal_to_snake_case(arg_type)
                suffix += f"_{snake_type}"
                arg_list += f"{arg_name}: {pascal_type}, "
                copy_into += f"    {arg_name} := {arg_name}\n"

                call_list += f"cast(TypePtr)&{arg_name}"
                if not is_pod_type(arg_type):
                    call_list += "._opaque"
                call_list += ", "

            arg_list = arg_list[:-2]
            call_list = call_list[:-2]

        constructor_name = f"{base_constructor_name}{suffix}"
        constructor_names.append(constructor_name)
        f.write(f"{constructor_name} :: proc({arg_list}) -> (ret: {pascal_name}) {{\n")
        f.write("    using gdinterface\n")
        f.write(copy_into)
        f.write(f"    ret = {pascal_name}{{}}\n")
        f.write(f"    call_builtin_constructor(__{pascal_name}__constructor_{index}, cast(TypePtr)&ret._opaque")
        if len(call_list) > 0:
            f.write(", ")
            f.write(call_list)
        f.write(")\n")
        f.write("    return\n")
        f.write("}\n\n")
    
    # special constructor for constructing string types from odin strings
    if name in types_with_odin_string_constructors:
        constructor_name = f"{base_constructor_name}_odin"
        constructor_names.append(constructor_name)
        f.write(f"{constructor_name} :: proc(from: string) -> (ret: {pascal_name}) {{\n")
        f.write("    using gdinterface\n")
        f.write("    cstr, err := strings.clone_to_cstring(from)\n")
        f.write(f"    ret = {pascal_name}{{}}\n")
        f.write("    core.interface.string_new_with_latin1_chars(cast(StringPtr)&ret._opaque, cstr)\n")
        f.write("    return\n")
        f.write("}\n\n")

    f.write(f"{base_constructor_name} :: proc{{\n")
    for cname in constructor_names:
        f.write(f"    {cname},\n")
    f.write("}\n\n")
    
    if has_destructor:
        f.write(f"free_{snake_name} :: proc(self: {pascal_name}) {{\n")
        f.write("    using gdinterface\n")
        f.write("    self := self\n")
        f.write(f"    __{pascal_name}__destructor(cast(TypePtr)&self._opaque)\n")
        f.write("}\n\n")

    # generate init binding
    f.write(f"init_{snake_name}_bindings :: proc() {{\n")
    f.write("    using gdinterface\n\n")
    for constructor in constructors:
        index = constructor["index"]
        f.write(f"    __{pascal_name}__constructor_{index} = core.interface.variant_get_ptr_constructor(VariantType.{pascal_name}, {index})\n")

    if has_destructor:
        f.write(f"    __{pascal_name}__destructor = core.interface.variant_get_ptr_destructor(VariantType.{pascal_name})\n")
    
    f.write("\n")

    for operator in operators:
        # __String_equals_Variant = core.interface.variant_get_ptr_operator_evaluator(VariantOperator.Equal, VariantType.String, VariantType.Nil)
        operator_name = operator["name"]
        right_type = operator.get("right_type", "Nil")
        if right_type == "Variant":
            right_type = "Nil"
        right_type = godot_to_pascal_case(right_type)
        backing_field = get_builtin_operator_backing_field(name, operator)
        operator_enum_name = operator_enum_map[operator_name]
        f.write(f"    {backing_field} = core.interface.variant_get_ptr_operator_evaluator(VariantOperator.{operator_enum_name}, VariantType.{pascal_name}, VariantType.{right_type})\n")

    f.write("\n")

    if len(methods) > 0:
        f.write("    function_name: StringName\n\n")
        for method in methods:
            method_name = method["name"]
            method_hash = method["hash"]
            backing_field = get_builtin_method_backing_field(name, method)
            f.write(f"    function_name = new_string_name(\"{method_name}\")\n")
            f.write(f"    {backing_field} = core.interface.variant_get_ptr_builtin_method(VariantType.{pascal_name}, cast(StringNamePtr)&function_name._opaque, {method_hash})\n")
            f.write(f"    free_string_name(function_name)\n\n")

    f.write("}\n\n")

    # generate private/backend component
    for operator in operators:
        f.write("@private\n")
        f.write(get_builtin_operator_backing_field(name, operator))
        f.write(f": {operator_evaluator_type}\n\n")

    for method in methods:
        f.write("@private\n")
        f.write(get_builtin_method_backing_field(name, method))
        f.write(f": {builtin_method_type}\n\n")

    for constructor in constructors:
        index = constructor["index"]
        f.write("@private\n")
        f.write(f"__{pascal_name}__constructor_{index}: {constructor_type}\n\n")

    if has_destructor:
        f.write("@private\n")
        f.write(f"__{pascal_name}__destructor: {destructor_type}\n\n")


def main():
    api_file = "./godot-cpp/gdextension/extension_api.json"
    
    with open(api_file) as f:
        api_json = json.load(f)
    
    builtin_class_sizes = api_json["builtin_class_sizes"]
    global_enums = api_json["global_enums"]
    utility_functions = api_json["utility_functions"]
    builtin_classes = api_json["builtin_classes"]
    classes = api_json["classes"]
    singletons = api_json["singletons"]
    native_structures = api_json["native_structures"]

    builtin_sizes_map = {v["build_configuration"]: {s["name"]: s["size"] for s in v["sizes"]} for v in builtin_class_sizes}

    Path("./core").mkdir(exist_ok=True)
    with open("core/enums.odin", "w") as f:
        f.write("package godot\n\n")
        gen_global_enums(f, global_enums)
    
    Path("./variant").mkdir(exist_ok=True)
    for builtin_api in builtin_classes:
        name = builtin_api["name"]
        if is_pod_type(name):
            continue
        # TODO: included types
        file_name = pascal_to_snake_case(godot_to_pascal_case(name))
        file_name = f"variant/{file_name}.odin"
        with open(file_name, "w") as f:
            gen_builtin_class(f, builtin_api, builtin_sizes_map, "variant")
    
    # TODO: generate classes, utility functions, singletons, etc


if __name__ == "__main__":
    main()


"""
    Copyright 2023 Dresses Digital

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
"""

package views

import g "../graph"
import "../names"
import "base:intrinsics"
import "core:fmt"
import "core:slice"
import "core:strings"

Package_Map_Mode :: enum {
    // generates `core/class_name`, `editor/class_name`, and `variant` packages with all classes
    Nested,

    // generates `core`, `editor`, and `variant` packages with all classes.
    Flat,
}

Type_Import :: union {
    No_Import,
    Import,
}

No_Import :: struct {}

@(private)
declared_builtins := []names.Godot_Name{"Object", "RefCounted"}

@(private)
gdextension_enums := []names.Godot_Name{"Variant.Type", "Variant.Operator"}

@(private = "file")
_api_type_to_import_name := [2]string{"__bindgen_core", "__bindgen_editor"}

@(private = "file")
_api_type_to_import_path := [2]string{"godot:core", "godot:editor"}

@(private = "file")
_get_api_type_import_path :: proc(api_type: g.Engine_Api_Type) -> string {
    switch api_type {
    case .Core:
        return "godot:core"
    case .Editor:
        return "godot:editor"
    }

    panic("unexpected api_type")
}

@(private)
import_map: map[rawptr]Type_Import

map_types_to_imports :: proc(graph: g.Graph, map_mode: Package_Map_Mode) {
    switch map_mode {
    case .Nested:
        for _, type in graph.types {
            switch root_type in type {
            case ^g.Builtin_Class:
                import_map[root_type] = No_Import{}

                for &class_enum in root_type.enums {
                    import_map[&class_enum] = No_Import{}
                }

                for &class_bit_field in root_type.bit_fields {
                    import_map[&class_bit_field] = No_Import{}
                }
            case ^g.Engine_Class:
                import_map[root_type] = No_Import{}

                for &class_enum in root_type.enums {
                    import_map[&class_enum] = No_Import{}
                }

                for &class_bit_field in root_type.bit_fields {
                    import_map[&class_bit_field] = No_Import{}
                }

            case ^g.Enum:
                if slice.contains(gdextension_enums, root_type.godot_name) {
                    import_map[root_type] = Import {
                        name = "__bindgen_gde",
                        path = "godot:gdext",
                    }
                    continue
                }

                import_map[root_type] = No_Import{}
            case ^g.Bit_Field:
                import_map[root_type] = No_Import{}
            case ^g.Native_Struct:
                import_map[root_type] = No_Import{}
            case ^g.Primitive:
                import_map[root_type] = No_Import{}
            }
        }
    case .Flat:
        unimplemented("Flat mode not implemented yet")
    }

    // TODO: we need a list of all TypedArray pointers that we can map against
}

@(private)
_any_to_rawptr :: proc(type: g.Any_Type) -> rawptr {
    switch as_type in type {
    case ^g.Builtin_Class:
        return as_type
    case ^g.Engine_Class:
        return as_type
    case ^g.Class_Enum(g.Builtin_Class):
        return as_type
    case ^g.Class_Bit_Field(g.Builtin_Class):
        return as_type
    case ^g.Class_Enum(g.Engine_Class):
        return as_type
    case ^g.Class_Bit_Field(g.Engine_Class):
        return as_type
    case ^g.Enum:
        return as_type
    case ^g.Bit_Field:
        return as_type
    case ^g.Native_Struct:
        return as_type
    case ^g.Primitive:
        return as_type
    case ^g.Typed_Array:
        return as_type
    case ^g.Pointer:
        return as_type
    case ^g.Sized_Array:
        return as_type
    }

    panic("type is nil")
}

_any_to_variant_type :: proc(type: g.Any_Type) -> names.Odin_Name {
    switch as_type in type {
    case ^g.Builtin_Class:
        if as_type.godot_name == "Variant" {
            return "Nil"
        }
        return as_type.odin_name
    case ^g.Engine_Class:
        return "Object"
    case ^g.Class_Enum(g.Builtin_Class):
        return "Int"
    case ^g.Class_Bit_Field(g.Builtin_Class):
        return "Int"
    case ^g.Class_Enum(g.Engine_Class):
        return "Int"
    case ^g.Class_Bit_Field(g.Engine_Class):
        return "Int"
    case ^g.Enum:
        return "Int"
    case ^g.Bit_Field:
        return "Int"
    case ^g.Native_Struct:
        panic("Native Structs cant be used as Variant")
    case ^g.Primitive:
        if as_type.odin_name == "Real" {
            return "Real"
        } else if as_type.odin_name == "ObjectPtr" {
            return "Object"
        }

        return "Int"
    case ^g.Typed_Array:
        return "Array"
    case ^g.Pointer:
        panic("Pointers cant be used as Variant")
    case ^g.Sized_Array:
        panic("Sized_Arrays cant be used as Variant")
    }

    unimplemented("type is nil")
}

@(private)
_any_to_odin_name :: proc(type: g.Any_Type, location := #caller_location) -> names.Odin_Name {
    switch as_type in type {
    case ^g.Builtin_Class:
        return as_type.odin_name
    case ^g.Engine_Class:
        return as_type.odin_name
    case ^g.Class_Enum(g.Builtin_Class):
        return(
            cast(names.Odin_Name)fmt.aprintf("%v_%v", as_type.class.odin_name, as_type.odin_name) \
        )
    case ^g.Class_Bit_Field(g.Builtin_Class):
        return(
            cast(names.Odin_Name)fmt.aprintf("%v_%v", as_type.class.odin_name, as_type.odin_name) \
        )
    case ^g.Class_Enum(g.Engine_Class):
        return as_type.odin_name
    case ^g.Class_Bit_Field(g.Engine_Class):
        return as_type.odin_name
    case ^g.Enum:
        return as_type.odin_name
    case ^g.Bit_Field:
        return as_type.odin_name
    case ^g.Native_Struct:
        return as_type.odin_name
    case ^g.Primitive:
        return cast(names.Odin_Name)as_type.odin_name
    case ^g.Typed_Array:
        name := cast(names.Odin_Name)fmt.aprintf("!!DEBUG Typed_Array(%v)", _any_to_odin_name(as_type.element_type))
        fmt.eprintln("WARN! _any_to_odin_name called on Typed_Array: ", name, location)
        return name
    case ^g.Pointer:
        name := cast(names.Odin_Name)fmt.aprintf(
            "!!DEBUG Pointer(%v, %v)",
            as_type.depth,
            _any_to_odin_name(g.pointable_to_any(as_type.type)),
        )
        fmt.eprintln("WARN! _any_to_odin_name called on Pointer: ", name, location)
        return name
    case ^g.Sized_Array:
        name := cast(names.Odin_Name)fmt.aprintf(
            "!!DEBUG Sized_Array(%v, %v)",
            as_type.size,
            _any_to_odin_name(as_type.type),
        )
        fmt.eprintln("WARN! _any_to_odin_name called on Sized_Array: ", name, location)
        return name
    }

    panic("type is nil")
}

ensure_imports :: proc(imports: ^map[string]Import, type: g.Any_Type, current_package: string) {
    if typed_array, is_typed_array := type.(^g.Typed_Array); is_typed_array {
        ensure_imports(imports, typed_array.element_type, current_package)
        return
    }

    if pointer, is_pointer := type.(^g.Pointer); is_pointer {
        ensure_imports(imports, g.pointable_to_any(pointer.type), current_package)
        return
    }

    if array, is_array := type.(^g.Sized_Array); is_array {
        ensure_imports(imports, array.type, current_package)
        return
    }

    type_import, ok := import_map[_any_to_rawptr(type)]
    assert(ok, "Couldn't find mapped import for type.")

    import_, is_import := type_import.(Import)
    if !is_import || import_.path == current_package {
        return
    }

    imports[import_.name] = import_
}

resolve_qualified_type :: proc(type: g.Any_Type, current_package: string) -> string {
    if typed_array, is_typed_array := type.(^g.Typed_Array); is_typed_array {
        elem_type := resolve_qualified_type(typed_array.element_type, current_package)
        return fmt.aprintf("Typed_Array(%v)", elem_type)
    }

    if pointer, is_pointer := type.(^g.Pointer); is_pointer {
        ptr_prefix := strings.repeat("^", pointer.depth)
        elem_type := resolve_qualified_type(g.pointable_to_any(pointer.type), current_package)
        return fmt.aprintf("%v%v", ptr_prefix, elem_type)
    }

    if array, is_array := type.(^g.Sized_Array); is_array {
        elem_type := resolve_qualified_type(array.type, current_package)
        return fmt.aprintf("[%v]%v", array.size, elem_type)
    }

    type_import, ok := import_map[_any_to_rawptr(type)]
    assert(ok, fmt.tprintfln("Couldn't find mapped import for type: %v", _any_to_odin_name(type)))

    import_, is_import := type_import.(Import)
    if !is_import || import_.path == current_package {
        return cast(string)_any_to_odin_name(type)
    }

    return fmt.aprintf("%v.%v", import_.name, _any_to_odin_name(type))
}

resolve_constructor_proc_name :: proc(type: g.Any_Type, current_package: string) -> string {
    type_import, ok := import_map[_any_to_rawptr(type)]
    assert(ok, "Couldn't find mapped import for type.")

    prefix := ""
    if import_, is_import := type_import.(Import); is_import && import_.path != current_package {
        prefix = fmt.tprintf("%v.", import_.name)
    }

    class_name: names.Snake_Name

    #partial switch class in type {
    case ^g.Builtin_Class:
        class_name = class.snake_name
    case ^g.Engine_Class:
        class_name = class.snake_name
    case:
        panic(
            fmt.tprintf(
                "Only Builtin_Class and Engine_Class have constructors, got %v instead.",
                typeid_of(type_of(type)),
            ),
        )
    }

    return fmt.aprintf("%vnew_%v", prefix, class_name)
}

/*
    Copyright 2025 Dresses Digital

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

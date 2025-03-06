package views

import g "../graph"
import "core:fmt"

Package_Map_Mode :: enum {
    // generates `core`, `editor`, and `variant` packages with all classes.
    Flat,

    // generates `core/ClassName`, `editor/ClassName`, and `variant` packages with all classes
    Nested,
}

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
import_map: map[rawptr]Import

map_types_to_imports :: proc(graph: g.Graph, map_mode: Package_Map_Mode) {

    switch map_mode {
    case .Flat:
        for _, type in graph.types {
            switch root_type in type {
            case ^g.Builtin_Class:
                import_map[root_type] = Import {
                    name = "__bindgen_var",
                    path = "godot:variant",
                }

                for &class_enum in root_type.enums {
                    import_map[&class_enum] = Import {
                        name = "__bindgen_var",
                        path = "godot:variant",
                    }
                }

                for &class_bit_field in root_type.bit_fields {
                    import_map[&class_bit_field] = Import {
                        name = "__bindgen_var",
                        path = "godot:variant",
                    }
                }
            case ^g.Engine_Class:
                import_map[root_type] = Import {
                    name = _api_type_to_import_name[root_type.api_type],
                    path = _api_type_to_import_path[root_type.api_type],
                }

                for &class_enum in root_type.enums {
                    import_map[&class_enum] = Import {
                        name = _api_type_to_import_name[root_type.api_type],
                        path = _api_type_to_import_path[root_type.api_type],
                    }
                }

                for &class_bit_field in root_type.bit_fields {
                    import_map[&class_bit_field] = Import {
                        name = _api_type_to_import_name[root_type.api_type],
                        path = _api_type_to_import_path[root_type.api_type],
                    }
                }
            case ^g.Enum:
                import_map[root_type] = Import {
                    name = "__bindgen_core",
                    path = "godot:core",
                }
            case ^g.Bit_Field:
                import_map[cast(rawptr)root_type] = Import {
                    name = "__bindgen_core",
                    path = "godot:core",
                }
            case ^g.Native_Struct:
                import_map[cast(rawptr)root_type] = Import {
                    name = "__bindgen_var",
                    path = "godot:variant",
                }
            case ^g.Primitive:
                // TODO: refactor Primitive to not include pointer or package qualifier in odin_name?
                unimplemented("TODO: primitive")
            }
        }
    case .Nested:
        unimplemented("Nested mode not implemented yet")
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
    }

    unimplemented("type is nil")
}

@(private)
_any_to_name :: proc(type: g.Any_Type) -> string {
    switch as_type in type {
    case ^g.Builtin_Class:
        return as_type.name
    case ^g.Engine_Class:
        return as_type.name
    case ^g.Class_Enum(g.Builtin_Class):
        return as_type.name
    case ^g.Class_Bit_Field(g.Builtin_Class):
        return as_type.name
    case ^g.Class_Enum(g.Engine_Class):
        return as_type.name
    case ^g.Class_Bit_Field(g.Engine_Class):
        return as_type.name
    case ^g.Enum:
        return as_type.name
    case ^g.Bit_Field:
        return as_type.name
    case ^g.Native_Struct:
        return as_type.name
    case ^g.Primitive:
        return as_type.name
    case ^g.Typed_Array:
        unimplemented("See TODO in map_type_to_imports")
    }

    unimplemented("type is nil")
}

resolve_qualified_type :: proc(type: g.Any_Type, current_package: string) -> string {
    type_import, ok := import_map[_any_to_rawptr(type)]
    assert(ok, "Couldn't find mapped import for type.")

    if type_import.path == current_package {
        return _any_to_name(type)
    }

    return fmt.aprintf("%v.%v", type_import.name, _any_to_name(type))
}

resolve_constructor_proc_name :: proc(type: g.Any_Type, current_package: string) -> string {
    type_import, ok := import_map[_any_to_rawptr(type)]
    assert(ok, "Couldn't find mapped import for type.")

    prefix := ""
    if type_import.path != current_package {
        prefix = fmt.tprintf("%v.", type_import.name)
    }

    class_name: string

    #partial switch class in type {
    case ^g.Builtin_Class:
        class_name = class.name
    case ^g.Engine_Class:
        class_name = class.name
    case:
        panic(
            fmt.tprintf(
                "Only Builtin_Class and Engine_Class have constructors, got %v instead.",
                typeid_of(type_of(type)),
            ),
        )
    }

    return fmt.aprintf("%vnew_%v", prefix, odin_to_snake_case(class_name))
}

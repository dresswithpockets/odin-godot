package views

import g "../graph"
import "../names"
import "core:mem"
import "core:strings"

Package_Class :: struct {
    name:    string,
    derives: string,
}

Core_Package :: struct {
    packages:   []string,
    classes:    []Package_Class,
    functions:  []Function,
    enums:      []Enum,
    bit_fields: []Bit_Field,
}

Editor_Package :: struct {
    packages:   []string,
    classes:    []Package_Class,
}

Function :: struct {
    name:        string,
    godot_name:  string,
    hash:        i64,
    args:        []Function_Arg,
    return_type: Maybe(string),
}

Function_Arg :: struct {
    name: string,
    type: string,
}

core_package :: proc(graph: ^g.Graph, allocator: mem.Allocator) -> (core: Core_Package) {
    context.allocator = allocator

    core_class_count := 0
    for class in graph.engine_classes {
        if class.api_type == .Core {
            core_class_count += 1
        }
    }

    core = Core_Package {
        packages   = make([]string, core_class_count),
        classes    = make([]Package_Class, core_class_count),
        functions  = make([]Function, len(graph.util_procs)),
        // taking 2 off for Variant.Type and Variant.Operator, which are both in gdextension
        enums      = make([]Enum, len(graph.enums)),
        bit_fields = make([]Bit_Field, len(graph.bit_fields)),
    }

    class_idx := 0
    for class in graph.engine_classes {
        if class.api_type == .Core {
            core.packages[class_idx] = cast(string)names.to_snake(class.name)
            core.classes[class_idx] = Package_Class {
                name    = cast(string)names.to_odin(class.name),
                derives = resolve_qualified_type(class.inherits, "godot:core"),
            }
            class_idx += 1
        }
    }

    for util_proc, proc_idx in graph.util_procs {
        function := Function {
            name       = strings.clone(util_proc.name),
            godot_name = strings.clone(util_proc.name),
            hash       = util_proc.hash,
            args       = make([]Function_Arg, len(util_proc.args)),
        }

        if util_proc.return_type != nil {
            function.return_type = resolve_qualified_type(util_proc.return_type, "godot:core")
        }

        for arg, arg_idx in util_proc.args {
            function.args[arg_idx] = Function_Arg {
                name = strings.clone(arg.name),
                type = resolve_qualified_type(arg.type, "godot:core"),
                // TODO: default values?
            }
        }

        core.functions[proc_idx] = function
    }

    for graph_enum, enum_idx in graph.enums {
        new_enum := Enum {
            name   = cast(string)names.to_odin(graph_enum.name),
            values = make([]Enum_Value, len(graph_enum.values)),
        }

        for value, value_idx in graph_enum.values {
            new_enum.values[value_idx] = Enum_Value {
                name  = cast(string)names.to_odin(value.name),
                value = strings.clone(value.value),
            }
        }

        core.enums[enum_idx] = new_enum
    }

    for graph_bit_field, enum_idx in graph.bit_fields {
        new_bit_field := Bit_Field {
            name   = cast(string)names.to_odin(graph_bit_field.name),
            values = make([]Enum_Value, len(graph_bit_field.values)),
        }

        for value, value_idx in graph_bit_field.values {
            new_bit_field.values[value_idx] = Enum_Value {
                name  = cast(string)names.to_odin(value.name),
                value = strings.clone(value.value),
            }
        }

        core.bit_fields[enum_idx] = new_bit_field
    }

    return
}

editor_package :: proc(graph: ^g.Graph, allocator: mem.Allocator) -> (editor: Editor_Package) {
    context.allocator = allocator

    editor_class_count := 0
    for class in graph.engine_classes {
        if class.api_type == .Editor {
            editor_class_count += 1
        }
    }

    editor = Editor_Package {
        packages = make([]string, editor_class_count),
        classes  = make([]Package_Class, editor_class_count),
    }

    class_idx := 0
    for class in graph.engine_classes {
        if class.api_type == .Editor {
            editor.packages[class_idx] = cast(string)names.to_snake(class.name)
            editor.classes[class_idx] = Package_Class {
                name    = cast(string)names.to_odin(class.name),
                derives = resolve_qualified_type(class.inherits, "godot:editor"),
            }
            class_idx += 1
        }
    }

    return
}

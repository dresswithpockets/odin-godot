package views

import g "../graph"
import "../names"
import "core:mem"
import "core:slice"
import "core:strings"

Package_Class :: struct {
    name:       string,
    snake_name: string,
    derives:    string,
}

Godot_Package :: struct {
    classes:    []Package_Class,
    inits:      []string,
    functions:  []Function,
    enums:      []Enum,
    bit_fields: []Bit_Field,
    singletons: []Singleton,
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

Singleton :: struct {
    name:       string,
    snake_name: string,
    type:       string,
}

godot_package :: proc(graph: ^g.Graph, allocator: mem.Allocator) -> (core: Godot_Package) {
    context.allocator = allocator

    // some types are declared as builtins in variant/ instead of as classes in core/
    core_class_count := len(graph.engine_classes) - len(declared_builtins)

    // taking some off since we're going to skip enums in gdextension_enums
    enum_count := len(graph.enums) - len(gdextension_enums)

    core = Godot_Package {
        classes    = make([]Package_Class, core_class_count),
        inits      = make([]string, len(graph.engine_classes)),
        functions  = make([]Function, len(graph.util_procs)),
        enums      = make([]Enum, enum_count),
        bit_fields = make([]Bit_Field, len(graph.bit_fields)),
        singletons = make([]Singleton, len(graph.singletons)),
    }

    class_idx := 0
    for class, init_idx in graph.engine_classes {
        core.inits[init_idx] = names.clone_string(class.snake_name)

        if slice.contains(declared_builtins, class.godot_name) {
            continue
        }

        core.classes[class_idx] = Package_Class {
            name       = names.clone_string(class.odin_name),
            snake_name = names.clone_string(class.snake_name),
            derives    = resolve_qualified_type(class.inherits, "godot:core"),
        }
        class_idx += 1
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

    enum_idx := 0
    for graph_enum in graph.enums {
        // skip over enums that are defined in gdextension
        if slice.contains(gdextension_enums, graph_enum.godot_name) {
            continue
        }

        new_enum := Enum {
            name   = names.clone_string(graph_enum.odin_name),
            values = make([]Enum_Value, len(graph_enum.values)),
        }

        for value, value_idx in graph_enum.values {
            new_enum.values[value_idx] = Enum_Value {
                name  = names.clone_string(value.odin_name),
                value = strings.clone(value.value),
            }
        }

        core.enums[enum_idx] = new_enum
        enum_idx += 1
    }

    for graph_bit_field, enum_idx in graph.bit_fields {
        new_bit_field := Bit_Field {
            name   = names.clone_string(graph_bit_field.odin_name),
            values = make([]Enum_Value, len(graph_bit_field.values)),
        }

        for value, value_idx in graph_bit_field.values {
            new_bit_field.values[value_idx] = Enum_Value {
                name  = names.clone_string(value.odin_name),
                value = strings.clone(value.value),
            }
        }

        core.bit_fields[enum_idx] = new_bit_field
    }

    for singleton, singleton_idx in graph.singletons {
        core.singletons[singleton_idx] = Singleton {
            name       = names.clone_string(singleton.odin_name),
            snake_name = names.clone_string(singleton.snake_name),
            type       = resolve_qualified_type(singleton.type, "godot:godot"),
        }
    }

    return
}

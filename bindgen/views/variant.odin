package views

import g "../graph"
import "core:fmt"
import "core:mem"
import "core:strings"

Import :: struct {
    name: string,
    path: string,
}

Enum :: struct {
    name:   string,
    values: []Enum_Value,
}

Enum_Value :: struct {
    name:  string,
    value: string,
}

File_Constant :: struct {
    name:  string,
    type:  string,
    value: string,
}

Init_Constant :: struct {
    name:        string,
    type:        string,
    constructor: string,
    args:        []string,
}

Constructor :: struct {
    name:  string,
    index: int,
    args:  []Constructor_Arg,
}

Constructor_Arg :: struct {
    name: string,
    type: string,
}

Member :: struct {}

Method :: struct {}

Operator :: struct {}

Variant :: struct {
    imports:                   []Import,
    name:                      string,
    size_float32:              uint,
    size_float64:              uint,
    size_double32:             uint,
    size_double64:             uint,
    enums:                     []Enum,
    bit_sets:                  []Enum,
    // constants rendered as compile-time constants (`x :: y` in Odin)
    file_constants:            []File_Constant,
    // constants rendered as a static variable that has to be initialized in a proc
    init_constants:            []Init_Constant,
    constructor_overload_name: string,
    // constructors rendered in the template that correlate 1-to-1 with a builtin constructor in Godot
    constructors:              []Constructor,
    // special constructor names written manually, these are included in the `new_XX` overload proc
    extern_constructors:       []string,
    destructor:                Maybe(string),
    members:                   []Member,
    methods:                   []Method,
    operators:                 []Operator,
}

@(private = "file")
default_imports := []Import{Import{name = "__bindgen_gd", path = "../gdextension"}}

@(private = "file")
imports_with_math := []Import {
    Import{name = "__bindgen_gd", path = "../gdextension"},
    Import{name = "__bindgen_math", path = "core:math"},
}

@(private = "file")
string_name_constructors := []string{"new_string_name_odin", "new_string_name_cstring"}

@(private = "file")
string_constructors := []string{"new_string_odin", "new_string_cstring"}

@(private = "file")
_resolve_qualified_type :: proc(type: g.Any_Type) -> string {
    unimplemented()
}

@(private = "file")
_resolve_constructor_proc_name :: proc(type: g.Any_Type) -> string {
    unimplemented()
}

variant :: proc(class: ^g.Builtin_Class) -> Variant {
    snake_name := godot_to_snake_case(class.name)

    file_constant_count := 0
    init_constant_count := 0
    for constant in class.constants {
        switch _ in constant.initializer {
        case string:
            file_constant_count += 1
        case g.Initialize_By_Constructor:
            init_constant_count += 1
        }
    }

    variant := Variant {
        imports                   = default_imports,
        name                      = godot_to_odin_case(class.name),
        size_float32              = class.layout_float32.size,
        size_float64              = class.layout_float64.size,
        size_double32             = class.layout_double32.size,
        size_double64             = class.layout_double64.size,
        enums                     = make([]Enum, len(class.enums)),
        bit_sets                  = make([]Enum, len(class.bit_fields)),
        file_constants            = make([]File_Constant, file_constant_count),
        init_constants            = make([]Init_Constant, init_constant_count),
        constructor_overload_name = fmt.tprintf("new_%v", snake_name),
        constructors              = make([]Constructor, len(class.constructors)),
        extern_constructors       = nil,
        destructor                = nil,
        members                   = make([]Member, len(class.members)),
        methods                   = make([]Method, len(class.methods)),
        operators                 = make([]Operator, len(class.operators)),
    }

    if class.destructor {
        variant.destructor = fmt.tprintf("free_%v", snake_name)
    }

    // N.B. some builtin classes have specialized constructors that aren't automatically generated
    switch class.name {
    case "StringName":
        variant.extern_constructors = string_name_constructors
    case "String":
        variant.extern_constructors = string_constructors
    }

    for class_enum, enum_idx in class.enums {
        variant_enum := Enum {
            name   = fmt.tprintf("%v_%v", class_enum.class.name, class_enum.name),
            values = make([]Enum_Value, len(class_enum.values)),
        }

        for value, value_idx in class_enum.values {
            variant_enum.values[value_idx] = Enum_Value {
                name  = strings.clone(value.name),
                value = strings.clone(value.value),
            }
        }

        variant.enums[enum_idx] = variant_enum
    }

    for class_bit_field, bit_field_idx in class.bit_fields {
        variant_bit_set := Enum {
            name   = fmt.tprintf("%v_%v", class_bit_field.class.name, class_bit_field.name),
            values = make([]Enum_Value, len(class_bit_field.values)),
        }

        for value, value_idx in class_bit_field.values {
            variant_bit_set.values[value_idx] = Enum_Value {
                name  = strings.clone(value.name),
                value = strings.clone(value.value),
            }
        }

        variant.bit_sets[bit_field_idx] = variant_bit_set
    }

    file_constant_idx := 0
    init_constant_idx := 0
    for class_constant, constant_idx in class.constants {
        switch initializer in class_constant.initializer {
        case string:
            variant.file_constants[file_constant_idx] = File_Constant {
                name  = strings.clone(class_constant.name),
                type  = _resolve_qualified_type(class_constant.type),
                value = initializer,
            }

            file_constant_idx += 1
        case g.Initialize_By_Constructor:
            init_constant := Init_Constant {
                name = strings.clone(class_constant.name),
                type = _resolve_qualified_type(class_constant.type),
                constructor = _resolve_constructor_proc_name(class_constant.type),
                args = make([]string, len(initializer.arg_values))
            }

            for value, arg_idx in initializer.arg_values {
                init_constant.args[arg_idx] = strings.clone(value)
            }

            variant.init_constants[init_constant_idx] = init_constant

            init_constant_idx += 1
        }
    }

    for class_constructor, constructor_idx in class.constructors {
        // TODO:
    }

    for class_member, member_idx in class.members {
        // TODO:
    }

    for class_method, method_idx in class.methods {
        // TODO:
    }

    for class_operator, operator_idx in class.operators {
        // TODO:
    }

    return variant
}

free_variant :: proc(view: Variant) -> (error: mem.Allocator_Error) {
    unimplemented()
}

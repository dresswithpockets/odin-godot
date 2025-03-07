#+feature dynamic-literals
package views

import g "../graph"
import "../names"
import "core:fmt"
import "core:mem"
import "core:strings"

@(private = "file")
render_flag_map := map[string]Render_Flags {
    // skip these builtins
    "Bool" = {},
    "Int" = {},
    "Float" = {},
    "Nil" = {},

    "AABB" = Render_Flags_Native,
    "Basis" = Render_Flags_Native,
    "Color" = Render_Flags_Native,
    "Plane" = Render_Flags_Native,
    "Projection" = Render_Flags_Native,
    "Quaternion" = Render_Flags_Native,
    "Rect2" = Render_Flags_Native,
    "Rect2i" = Render_Flags_Native,
    "Transform2d" = Render_Flags_Native,
    "Transform3d" = Render_Flags_Native,
    "Vector2" = Render_Flags_Native,
    "Vector2i" = Render_Flags_Native,
    "Vector3" = Render_Flags_Native,
    "Vector3i" = Render_Flags_Native,
    "Vector4" = Render_Flags_Native,
    "Vector4i" = Render_Flags_Native,

    "Callable" = Render_Flags_Opaque,
    "Dictionary" = Render_Flags_Opaque,
    "NodePath" = Render_Flags_Opaque,
    "PackedByteArray" = Render_Flags_Opaque,
    "PackedColorArray" = Render_Flags_Opaque,
    "PackedFloat32Array" = Render_Flags_Opaque,
    "PackedFloat64Array" = Render_Flags_Opaque,
    "PackedInt32Array" = Render_Flags_Opaque,
    "PackedInt64Array" = Render_Flags_Opaque,
    "PackedStringArray" = Render_Flags_Opaque,
    "PackedVector2Array" = Render_Flags_Opaque,
    "PackedVector3Array" = Render_Flags_Opaque,
    "PackedVector4Array" = Render_Flags_Opaque,
    "Rid" = Render_Flags_Opaque,
    "Signal" = Render_Flags_Opaque,
    "String" = Render_Flags_Opaque,
    "StringName" = Render_Flags_Opaque,
}

Render_Flags :: bit_set[enum{
    Constants,
    Constructors,
    Destructor,
    Members,
    Methods,
    Operators,
}]

Render_Flags_Native: Render_Flags: {.Methods, .Operators}
Render_Flags_Opaque: Render_Flags: {.Constructors, .Destructor, .Members, .Methods, .Operators}

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
    index: u64,
    args:  []Constructor_Arg,
}

Constructor_Arg :: struct {
    name: string,
    type: string,
}

Member :: struct {
    name: string,
    type: string,
}

Method :: struct {
    name:        string,
    vararg:      bool,
    hash:        i64,
    return_type: Maybe(string),
    args:        []Method_Arg,
}

Method_Arg :: struct {
    name: string,
    type: string,
}

Operator :: struct {}

Variant :: struct {
    imports:                   []Import,
    name:                      string,
    proc_prefix:               string,
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
    static_methods:            []Method,
    instance_methods:          []Method,
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

@(private)
_class_constructor_name :: proc(base_constructor_name: string, args: []g.Constructor_Arg) -> string {
    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    fmt.sbprint(&sb, base_constructor_name)
    if len(args) == 0 {
        fmt.sbprint(&sb, "_default")
        return strings.clone(strings.to_string(sb))
    }

    for arg in args {
        type_name := _any_to_name(arg.type)
        if type_name == cast(names.Odin_Name)"GDFLOAT" {
            type_name = cast(names.Odin_Name)"float"
        }
        snake_type := names.to_snake(type_name)
        fmt.sbprintf(&sb, "_%v", snake_type)
    }

    return strings.clone(strings.to_string(sb))
}

variant :: proc(class: ^g.Builtin_Class) -> (variant: Variant, render: bool) {
    render_flags := render_flag_map[class.name] or_else {}

    if render_flags == {} {
        return {}, false
    }

    snake_name := names.to_snake(class.name)

    file_constant_count := 0
    init_constant_count := 0
    if Render_Flags.Constants in render_flags {
        for constant in class.constants {
            switch _ in constant.initializer {
            case string:
                file_constant_count += 1
            case g.Initialize_By_Constructor:
                init_constant_count += 1
            }
        }
    }

    static_method_count := 0
    instance_method_count := 0
    if Render_Flags.Methods in render_flags {
        for method in class.methods {
            if method.static {
                static_method_count += 1
            } else {
                instance_method_count += 1
            }
        }
    }

    variant = Variant {
        imports                   = default_imports,
        name                      = cast(string)names.to_odin(class.name),
        proc_prefix               = cast(string)names.to_snake(class.name),
        enums                     = make([]Enum, len(class.enums)),
        bit_sets                  = make([]Enum, len(class.bit_fields)),
        file_constants            = make([]File_Constant, file_constant_count),
        init_constants            = make([]Init_Constant, init_constant_count),
        constructor_overload_name = fmt.tprintf("new_%v", snake_name),
        constructors              = make([]Constructor, len(class.constructors)),
        extern_constructors       = nil,
        destructor                = nil,
        members                   = make([]Member, len(class.members)),
        static_methods            = make([]Method, static_method_count),
        instance_methods          = make([]Method, instance_method_count),
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
            name   = fmt.tprintf("%v_%v", names.to_odin(class_enum.class.name), names.to_odin(class_enum.name)),
            values = make([]Enum_Value, len(class_enum.values)),
        }

        for value, value_idx in class_enum.values {
            variant_enum.values[value_idx] = Enum_Value {
                name  = cast(string)names.to_odin(value.name),
                value = strings.clone(value.value),
            }
        }

        variant.enums[enum_idx] = variant_enum
    }

    for class_bit_field, bit_field_idx in class.bit_fields {
        variant_bit_set := Enum {
            name   = fmt.tprintf(
                "%v_%v",
                names.to_odin(class_bit_field.class.name),
                names.to_odin(class_bit_field.name),
            ),
            values = make([]Enum_Value, len(class_bit_field.values)),
        }

        for value, value_idx in class_bit_field.values {
            variant_bit_set.values[value_idx] = Enum_Value {
                name  = cast(string)names.to_odin(value.name),
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
                name  = fmt.aprintf("%v_%v", variant.name, names.to_odin(class_constant.name)), // TODO: prefixing by variant.name isnt necessary in Nested package mode
                type  = resolve_qualified_type(class_constant.type, "godot:variant"), // TODO: other package modes
                value = initializer,
            }

            file_constant_idx += 1
        case g.Initialize_By_Constructor:
            init_constant := Init_Constant {
                name        = fmt.aprintf("%v_%v", variant.name, names.to_odin(class_constant.name)), // TODO: prefixing by variant.name isnt necessary in Nested package mode
                type        = resolve_qualified_type(class_constant.type, "godot:variant"), // TODO: other package modes
                constructor = resolve_constructor_proc_name(class_constant.type, "godot:variant"), // TODO: other package modes
                args        = make([]string, len(initializer.arg_values)),
            }

            for value, arg_idx in initializer.arg_values {
                init_constant.args[arg_idx] = strings.clone(value)
            }

            variant.init_constants[init_constant_idx] = init_constant

            init_constant_idx += 1
        }
    }

    for class_constructor, constructor_idx in class.constructors {
        constructor := Constructor {
            name  = _class_constructor_name(variant.constructor_overload_name, class_constructor.args),
            index = class_constructor.index,
            args  = make([]Constructor_Arg, len(class_constructor.args)),
        }

        for constructor_arg, arg_idx in class_constructor.args {
            constructor.args[arg_idx] = Constructor_Arg {
                name = constructor_arg.name,
                type = resolve_qualified_type(constructor_arg.type, "godot:variant"), // TODO: other package modes
            }
        }

        variant.constructors[constructor_idx] = constructor
    }

    for class_member, member_idx in class.members {
        variant.members[member_idx] = Member {
            name = class_member.name,
            type = resolve_qualified_type(class_member.type, "godot:variant"), // TODO: other package modes
        }
    }

    static_method_idx := 0
    instance_method_idx := 0
    for class_method, method_idx in class.methods {
        method := Method{
            name = fmt.aprintf("%v_%v", snake_name, class_method.name),
            hash = class_method.hash,
            args = make([]Method_Arg, len(class_method.args)),
            vararg = class_method.vararg,
            return_type = nil,
        }

        if class_method.return_type != nil {
            method.return_type = resolve_qualified_type(class_method.return_type, "godot:variant") // TODO: other package modes
        }

        for class_method_arg, arg_idx in class_method.args {
            method.args[arg_idx] = Method_Arg {
                name = class_method_arg.name,
                type = resolve_qualified_type(class_method_arg.type, "godot:variant") // TODO: other package modes
                // TODO: defaults?
            }
        }

        if class_method.static {
            variant.static_methods[static_method_idx] = method
            static_method_idx += 1
        } else {
            variant.instance_methods[instance_method_idx] = method
            instance_method_idx += 1
        }
    }

    for class_operator, operator_idx in class.operators {
        // TODO:
    }

    return variant, true
}

free_variant :: proc(view: Variant) -> (error: mem.Allocator_Error) {
    unimplemented()
}

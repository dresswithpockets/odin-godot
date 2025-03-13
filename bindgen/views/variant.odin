#+feature dynamic-literals
package views

import g "../graph"
import "../names"
import "core:fmt"
import "core:mem"
import "core:slice"
import "core:strings"

@(private = "file")
render_flag_map := map[names.Godot_Name]Render_Flags {
    // skip these builtins
    "bool"               = {},
    "int"                = {},
    "float"              = {},
    "Nil"                = {},

    // defined in variant/Variant.odin
    "AABB"               = Render_Flags_Native,
    "Basis"              = Render_Flags_Native,
    "Color"              = Render_Flags_Native,
    "Plane"              = Render_Flags_Native,
    "Projection"         = Render_Flags_Native,
    "Quaternion"         = Render_Flags_Native,
    "Rect2"              = Render_Flags_Native,
    "Rect2i"             = Render_Flags_Native,
    "Transform2D"        = Render_Flags_Native,
    "Transform3D"        = Render_Flags_Native,
    "Vector2"            = Render_Flags_Native,
    "Vector2i"           = Render_Flags_Native,
    "Vector3"            = Render_Flags_Native,
    "Vector3i"           = Render_Flags_Native,
    "Vector4"            = Render_Flags_Native,
    "Vector4i"           = Render_Flags_Native,

    // defined as Opaque in variant/Variant.odin
    "Array"              = Render_Flags_Opaque,
    "Callable"           = Render_Flags_Opaque,
    "Dictionary"         = Render_Flags_Opaque,
    "NodePath"           = Render_Flags_Opaque,
    "PackedByteArray"    = Render_Flags_Opaque,
    "PackedColorArray"   = Render_Flags_Opaque,
    "PackedFloat32Array" = Render_Flags_Opaque,
    "PackedFloat64Array" = Render_Flags_Opaque,
    "PackedInt32Array"   = Render_Flags_Opaque,
    "PackedInt64Array"   = Render_Flags_Opaque,
    "PackedStringArray"  = Render_Flags_Opaque,
    "PackedVector2Array" = Render_Flags_Opaque,
    "PackedVector3Array" = Render_Flags_Opaque,
    "PackedVector4Array" = Render_Flags_Opaque,
    "RID"                = Render_Flags_Opaque,
    "Signal"             = Render_Flags_Opaque,
    "String"             = Render_Flags_Opaque,
    "StringName"         = Render_Flags_Opaque,
}

Render_Flags :: bit_set[enum {
    Constructors,
    Destructor,
    Members,
    Methods,
    Operators,
}]

Render_Flags_Native: Render_Flags : {.Methods, .Operators}
Render_Flags_Opaque: Render_Flags : {.Constructors, .Destructor, .Members, .Methods, .Operators}

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

Operator :: struct {
    proc_name:    string,
    overloads:    []Operator_Overload,
    variant_name: string,
}

Operator_Overload :: struct {
    proc_name:          string,
    right_type:         Maybe(string),
    right_variant_type: string,
    return_type:        string,
}

Variant :: struct {
    imports:             map[string]Import,
    name:                string,
    snake_name:          string,
    enums:               []Enum,
    bit_sets:            []Enum,
    // constructors rendered in the template that correlate 1-to-1 with a builtin constructor in Godot
    constructors:        []Constructor,
    // special constructor names written manually, these are included in the `new_XX` overload proc
    extern_constructors: []string,
    destructor:          Maybe(string),
    members:             []Member,
    static_methods:      []Method,
    instance_methods:    []Method,
    operators:           []Operator,
}

@(private = "file")
default_import := Import{name = "__bindgen_gde", path = "../gdextension"}

@(private = "file")
imports_with_math := []Import {
    Import{name = "__bindgen_gde", path = "../gdextension"},
    Import{name = "__bindgen_math", path = "core:math"},
}

@(private = "file")
extern_constructors := map[names.Godot_Name][]string {
    "StringName" = {"new_string_name_odin", "new_string_name_cstring"},
    "String"     = {"new_string_odin", "new_string_cstring"},
}

@(private)
_class_constructor_name :: proc(snake_name: string, args: []g.Constructor_Arg) -> string {
    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    fmt.sbprint(&sb, "new_")
    fmt.sbprint(&sb, snake_name)
    if len(args) == 0 {
        fmt.sbprint(&sb, "_default")
        return strings.clone(strings.to_string(sb))
    }

    for arg in args {
        type_name := _any_to_name(arg.type) // TODO: other package modes
        if type_name == cast(names.Odin_Name)"Float" {
            type_name = cast(names.Odin_Name)"float"
        }
        snake_type := names.to_snake(type_name)
        fmt.sbprintf(&sb, "_%v", snake_type)
    }

    return strings.clone(strings.to_string(sb))
}

variant :: proc(class: ^g.Builtin_Class, allocator: mem.Allocator) -> (variant: Variant, render: bool) {
    context.allocator = allocator

    render_flags, in_flag_map := render_flag_map[class.name]
    assert(in_flag_map, fmt.tprintfln("Couldn't find render flags for class: '%v'", class.name))

    if render_flags == {} {
        return {}, false
    }

    snake_name := names.to_snake(class.name)

    constructor_count := 0
    if Render_Flags.Constructors in render_flags {
        constructor_count = len(class.constructors)
    }

    member_count := 0
    if Render_Flags.Members in render_flags {
        member_count = len(class.members)
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

    operator_count := 0
    if Render_Flags.Operators in render_flags {
        operator_names := make(map[names.Snake_Name]int)
        defer delete(operator_names)

        for class_operator in class.operators {
            operator_names[class_operator.name] = (operator_names[class_operator.name] or_else 0) + 1
        }

        operator_count = len(operator_names)
    }

    variant = Variant {
        name                = cast(string)names.to_odin(class.name),
        snake_name          = cast(string)names.to_snake(class.name),
        enums               = make([]Enum, len(class.enums)),
        bit_sets            = make([]Enum, len(class.bit_fields)),
        constructors        = make([]Constructor, constructor_count),
        extern_constructors = nil,
        destructor          = nil,
        members             = make([]Member, member_count),
        static_methods      = make([]Method, static_method_count),
        instance_methods    = make([]Method, instance_method_count),
        operators           = make([]Operator, operator_count),
    }

    variant.imports[default_import.name] = default_import

    if Render_Flags.Destructor in render_flags && class.destructor {
        variant.destructor = fmt.tprintf("free_%v", snake_name)
    }

    // N.B. some builtin classes have specialized constructors that aren't automatically generated
    if extern_constructors, has_extern_constructors := extern_constructors[class.name]; has_extern_constructors {
        variant.extern_constructors = extern_constructors
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

    if Render_Flags.Constructors in render_flags {
        for class_constructor, constructor_idx in class.constructors {
            constructor := Constructor {
                name  = _class_constructor_name(variant.snake_name, class_constructor.args),
                index = class_constructor.index,
                args  = make([]Constructor_Arg, len(class_constructor.args)),
            }

            for constructor_arg, arg_idx in class_constructor.args {
                constructor.args[arg_idx] = Constructor_Arg {
                    name = constructor_arg.name,
                    type = resolve_qualified_type(constructor_arg.type, "godot:variant"), // TODO: other package modes
                }

                ensure_imports(&variant.imports, constructor_arg.type, "godot:variant") // TODO: other package modes
            }

            variant.constructors[constructor_idx] = constructor
        }
    }

    if Render_Flags.Members in render_flags {
        for class_member, member_idx in class.members {
            variant.members[member_idx] = Member {
                name = class_member.name,
                type = resolve_qualified_type(class_member.type, "godot:variant"), // TODO: other package modes
            }

            ensure_imports(&variant.imports, class_member.type, "godot:variant") // TODO: other package modes
        }
    }

    if Render_Flags.Methods in render_flags {
        static_method_idx := 0
        instance_method_idx := 0
        for class_method, method_idx in class.methods {
            method := Method {
                name        = fmt.aprintf("%v_%v", snake_name, class_method.name),
                hash        = class_method.hash,
                args        = make([]Method_Arg, len(class_method.args)),
                vararg      = class_method.vararg,
                return_type = nil,
            }

            if class_method.return_type != nil {
                method.return_type = resolve_qualified_type(class_method.return_type, "godot:variant") // TODO: other package modes
                ensure_imports(&variant.imports, class_method.return_type, "godot:variant") // TODO: other package modes
            }

            for class_method_arg, arg_idx in class_method.args {
                method.args[arg_idx] = Method_Arg {
                    name = strings.clone(class_method_arg.name),
                    type = resolve_qualified_type(class_method_arg.type, "godot:variant"), // TODO: other package modes
                    // TODO: defaults?
                }

                ensure_imports(&variant.imports, class_method_arg.type, "godot:variant") // TODO: other package modes
            }

            if class_method.static {
                variant.static_methods[static_method_idx] = method
                static_method_idx += 1
            } else {
                variant.instance_methods[instance_method_idx] = method
                instance_method_idx += 1
            }
        }
    }

    if Render_Flags.Operators in render_flags {
        overload_map := make(map[names.Snake_Name][dynamic]Operator_Overload)
        defer delete(overload_map)

        operator_names := make([dynamic]names.Snake_Name)
        defer delete(operator_names)

        for class_operator, idx in class.operators {
            if class_operator.name not_in overload_map {
                overload_map[class_operator.name] = make([dynamic]Operator_Overload)
                append(&operator_names, class_operator.name)
            }

            overload := Operator_Overload {
                return_type = resolve_qualified_type(class_operator.return_type, "godot:variant"), // TODO: other package modes
                right_type  = nil,
            }

            ensure_imports(&variant.imports, class_operator.return_type, "godot:variant") // TODO: other package modes

            if class_operator.right_type != nil {
                ensure_imports(&variant.imports, class_operator.right_type, "godot:variant") // TODO: other package modes

                overload.right_type = cast(string)_any_to_name(class_operator.right_type) // TODO: other package modes
                overload.right_variant_type = cast(string)_any_to_variant_type(class_operator.right_type)
                overload.proc_name = fmt.aprintf(
                    "%v_%v_%v",
                    variant.snake_name,
                    class_operator.name,
                    names.to_snake(_any_to_name(class_operator.right_type)), // TODO: other package modes
                )
            } else {
                overload.proc_name = fmt.aprintf("%v_%v_default", variant.snake_name, class_operator.name)
            }

            append(&overload_map[class_operator.name], overload)
        }

        for operator_name, operator_idx in operator_names {
            overloads, ok := overload_map[operator_name]
            assert(ok, "Couldn't map operator_name to overload")

            variant.operators[operator_idx] = Operator {
                proc_name    = fmt.aprintf("%v_%v", variant.snake_name, operator_name),
                variant_name = cast(string)names.to_odin(operator_name),
                overloads    = slice.clone(overloads[:]),
            }

            delete(overloads)
        }
    }

    return variant, true
}

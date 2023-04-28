package bindgen

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
import "core:unicode"
import "core:unicode/utf8"

constructor_type :: "gdinterface.PtrConstructor"
destructor_type :: "gdinterface.PtrDestructor"
operator_evaluator_type :: "gdinterface.PtrOperatorEvaluator"
builtin_method_type :: "gdinterface.PtrBuiltInMethod"

// these are already in gdinterface
@(private)
ignore_enums_by_name :: []string{"Variant.Operator", "Variant.Type"}

@(private)
enum_prefix_alias := map[string]string {
    "Error" = "Err",
}

@(private)
pod_types :: []string{
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
}

@(private)
types_with_odin_string_constructors :: []string{"String", "StringName", "NodePath"}

generate_bindings :: proc(state: ^State) {
    sb := strings.builder_make()

    {
        fmt.sbprint(&sb, "package core\n\n")
        generate_global_enums(state, &sb)

        enums_output := strings.to_string(sb)
        os.write_entire_file("core/enums.odin", transmute([]byte)enums_output)

        strings.builder_reset(&sb)
    }

    {
        for name, class in &state.builtin_classes {
            fmt.sbprint(&sb, "package variant\n\n")

            // used in the special constructor for some string types
            if slice.contains(types_with_odin_string_constructors, name) {
                fmt.sbprint(&sb, "import \"core:strings\"\n")
            }

            // import the dependency list
            fmt.sbprint(&sb, "import \"../core\"\n")
            fmt.sbprint(&sb, "import \"../gdinterface\"\n")
            for package_name in class.depends_on_packages {
                if package_name == "core" {
                    continue
                }
                fmt.sbprintf(&sb, "import \"../%v\"\n", package_name)
            }

            fmt.sbprintln(&sb)

            generate_builtin_class(state, &class, &sb)

            class_output := strings.to_string(sb)
            file_name_parts := [?]string{"variant/", class.godot_name, ".odin"}
            file_name := strings.concatenate(file_name_parts[:])
            defer delete(file_name)
            os.write_entire_file(file_name, transmute([]byte)class_output)

            strings.builder_reset(&sb)
        }
    }

    // TODO: more gen (:

    strings.builder_destroy(&sb)
}

generate_global_enums :: proc(state: ^State, sb: ^strings.Builder) {
    for name, global_enum in state.enums {
        // we ignore some enums by name, such as those pre-implemented
        // in gdinterface
        if slice.contains(ignore_enums_by_name, name) {
            continue
        }

        // we use AcronymPascalCase in our generated code, but godot
        // uses ACRONYMPascalCase - harder to read IMO
        odin_case_name := state.type_odin_names[name]

        // godot's enums use CONST_CASE for their values, and usually
        // have a prefix. e.e `GDExtensionVariantType` uses the prefix
        // `GDEXTENSION_VARIANT_TYPE_`. The prefix gets stripped before
        // the value is generated in odin.
        const_case_prefix := odin_to_const_case(odin_case_name)
        defer delete(const_case_prefix)

        // gotta do all of that for the prefix alias if there is one
        prefix_alias, has_alias := enum_prefix_alias[name]
        const_case_prefix_alias: string
        if has_alias {
            const_case_prefix_alias = odin_to_const_case(prefix_alias)
        }
        defer if has_alias {
            delete(const_case_prefix_alias)
        }

        // godot has a convention for "Flags" enums, where the prefix used
        // by values isn't always plural. e.g `MethodFlags` has 
        // `METHOD_FLAG_NORMAL`, as well as `METHOD_FLAGS_DEFAULT`.
        // The latter will get caught by const_case_prefix, but we also
        // need to have a prefix for the singular variation of the prefix
        is_flags := strings.has_suffix(name, "Flags")
        flag_prefix: string
        without_flags_prefix: string
        if is_flags {
            // chops off the s at the end
            flag_prefix = const_case_prefix[:len(const_case_prefix) - 1]
            // also a variation for enums where the "FLAGS_" portion of the
            // value prefix is completely dropped. e.g `PropertyUsageFlags`
            // uses the prefix `PROPERTY_USAGE_` instead of `PROPERTY_USAGE_FLAG`
            without_flags_prefix = const_case_prefix[:len(const_case_prefix) - 5]
        }

        fmt.sbprintf(sb, "%v :: enum {{\n", odin_case_name)
        for value_name, value in global_enum.values {
            value_name := value_name
            if len(value_name) != len(const_case_prefix) {
                value_name = strings.trim_prefix(value_name, const_case_prefix)
            }
            if has_alias && len(value_name) != len(const_case_prefix_alias) {
                value_name = strings.trim_prefix(value_name, const_case_prefix_alias)
            }
            if is_flags {
                if len(value_name) != len(flag_prefix) {
                    value_name = strings.trim_prefix(value_name, flag_prefix)
                }
                if len(value_name) != len(without_flags_prefix) {
                    value_name = strings.trim_prefix(value_name, without_flags_prefix)
                }
            }

            // we might have a lingering _ after we removed the prefix
            if value_name[0] == '_' && len(value_name) > 1 {
                value_name = value_name[1:]
            }
            value_name = const_to_odin_case(value_name)
            fmt.sbprintf(sb, "    %v = %v,\n", value_name, value)
        }
        fmt.sbprint(sb, "}\n\n")
    }
    return
}

generate_builtin_class :: proc(state: ^State, class: ^StateBuiltinClass, sb: ^strings.Builder) {
    odin_name := state.type_odin_names[class.godot_name]
    snake_name := state.type_snake_names[class.godot_name]

    fmt.sbprintf(sb, "%v :: struct {{\n", odin_name)
    fmt.sbprintf(sb, "    _opaque: __%vOpaqueType,\n", odin_name)
    fmt.sbprint(sb, "}\n\n")

    first_config := true
    for config_name, config in state.size_configurations {
        size, in_size_config := config.sizes[class.godot_name]
        assert(in_size_config)

        if first_config {
            fmt.sbprint(sb, "when ")
            first_config = false
        } else {
            fmt.sbprint(sb, " else when ")
        }

        fmt.sbprintf(sb, "core.interface.BUILD_CONFIG == \"%v\" {{\n", config_name)
        if size != 0 && (size & (size - 1) == 0) && size < 16 {
            size *= 8
            fmt.sbprintf(sb, "    __%vOpaqueType :: u%v\n", odin_name, size)
        } else {
            fmt.sbprintf(sb, "    __%vOpaqueType :: [%v]u8\n", odin_name, size)
        }
        fmt.sbprint(sb, "}")
    }
    fmt.sbprint(sb, "\n\n")

    // generate frontend procs
    {
        // generate frontend operator procs
        for operator_name, operator in class.operators {
            for overload in operator.overloads {
                fmt.sbprintf(sb, "%v :: proc(self: %v", overload.proc_name, odin_name)
                right_type, has_right_type := overload.right_type.(string)
                if has_right_type {
                    right_type_odin_name := _get_correct_class_odin_name(state, right_type)
                    fmt.sbprintf(sb, ", other: %v", right_type_odin_name)
                }
                return_type_odin_name := _get_correct_class_odin_name(state, overload.return_type)
                fmt.sbprintf(sb, ") -> (ret: %v) {{\n", return_type_odin_name)
                fmt.sbprintln(sb, "    using gdinterface")
                fmt.sbprintln(sb, "    self := self")
                if has_right_type {
                    fmt.sbprintln(sb, "    other := other")
                }
                fmt.sbprintf(sb, "    return call_builtin_operator_ptr(%v, cast(TypePtr)&self._opaque, cast(TypePtr)", overload.backing_func_name)
                if has_right_type {
                    fmt.sbprintf(sb, "&other._opaque")
                } else {
                    fmt.sbprintf(sb, "nil")
                }
                fmt.sbprintf(sb, ", %v)\n", return_type_odin_name)
                fmt.sbprint(sb, "}\n\n")
            }

            fmt.sbprintf(sb, "%v :: proc{{\n", operator.proc_name)
            for overload in operator.overloads {
                fmt.sbprintf(sb, "    %v,\n", overload.proc_name)
            }
            fmt.sbprint(sb, "}\n\n")
        }
    }

    // TODO: generate frontend for methods
    // TODO: generate frontend for constructors
    // TODO: generate frontend for special string constructors
    if class.has_destructor {
        fmt.sbprintf(sb, "free_%v :: proc(self: %v) {{\n", snake_name, odin_name)
        fmt.sbprintln(sb, "    using gdinterface")
        fmt.sbprintln(sb, "    self := self")
        fmt.sbprintf(sb, "    __%v__destructor(cast(TypePtr)&self._opaque)\n", class.godot_name)
        fmt.sbprint(sb, "}\n\n")
    }

    // TODO: generate initialization function

    // generate backing fields
    for operator_name, operator in class.operators {
        for overload in operator.overloads {
            fmt.sbprintln(sb, "@private")
            fmt.sbprintf(sb, "%v: %v\n\n", overload.backing_func_name, operator_evaluator_type)
        }
    }

    // TODO: generate backing fields for methods
    // TODO: generate backing fields for constructors

    if class.has_destructor {
        fmt.sbprintln(sb, "@private")
        fmt.sbprintf(sb, "__%v__destructor: %v\n\n", class.godot_name, destructor_type)
    }
}

// godot uses ACRONYMPascalCase, but we use AcronymPascalCase
// return string must be freed
@(private)
godot_to_odin_case :: proc(name: string) -> (s: string) {
    assert(len(name) > 0)

    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    runes := utf8.string_to_runes(name)
    defer delete(runes)

    fmt.sbprint(&sb, unicode.to_upper(runes[0]))
    for i := 1; i < len(runes) - 1; i += 1 {
        r := runes[i]
        previous := runes[i - 1]
        next := runes[i + 1]
        if unicode.is_upper(r) &&
           (unicode.is_upper(previous) || unicode.is_number(previous)) &&
           unicode.is_upper(next) {
            fmt.sbprint(&sb, unicode.to_lower(r))
            continue
        }

        fmt.sbprint(&sb, r)
    }
    // always push the last rune as lower
    if len(runes) > 1 {
        fmt.sbprint(&sb, unicode.to_lower(runes[len(runes) - 1]))
    }

    s = strings.clone(strings.to_string(sb))
    return
}

@(private)
godot_to_snake_case :: proc(name: string) -> (s: string) {
    // lol (:
    s = odin_to_snake_case(godot_to_odin_case(name))
    return
}

@(private)
odin_to_snake_case :: proc(name: string) -> (s: string) {
    assert(len(name) > 0)

    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    runes := utf8.string_to_runes(name)
    defer delete(runes)

    fmt.sbprint(&sb, unicode.to_lower(runes[0]))
    for i := 1; i < len(runes); i += 1 {
        r := runes[i]
        if unicode.is_alpha(r) && unicode.is_upper(r) {
            fmt.sbprint(&sb, "_")
            fmt.sbprint(&sb, unicode.to_lower(r))
            continue
        }

        fmt.sbprint(&sb, unicode.to_lower(r))
    }

    s = strings.clone(strings.to_string(sb))
    return
}

@(private)
odin_to_const_case :: proc(name: string) -> (s: string) {
    assert(len(name) > 0)

    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    runes := utf8.string_to_runes(name)
    defer delete(runes)

    fmt.sbprint(&sb, runes[0])
    for i := 1; i < len(runes); i += 1 {
        r := runes[i]
        if unicode.is_alpha(r) && unicode.is_upper(r) {
            fmt.sbprint(&sb, "_")
            fmt.sbprint(&sb, r)
            continue
        }

        fmt.sbprint(&sb, unicode.to_upper(r))
    }

    s = strings.clone(strings.to_string(sb))
    return
}

@(private)
const_to_odin_case :: proc(name: string) -> (s: string) {
    assert(len(name) > 0)

    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    runes := utf8.string_to_runes(name)
    defer delete(runes)

    if unicode.is_number(runes[0]) {
        fmt.sbprint(&sb, "_")
    }

    fmt.sbprint(&sb, runes[0])
    for i := 1; i < len(runes); i += 1 {
        r := runes[i]
        if r == '_' {
            continue
        }

        previous := runes[i - 1]
        if previous == '_' {
            fmt.sbprint(&sb, r)
            continue
        }

        fmt.sbprint(&sb, unicode.to_lower(r))
    }

    s = strings.clone(strings.to_string(sb))
    return
}

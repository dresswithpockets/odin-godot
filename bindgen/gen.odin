//+private
package bindgen

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
import "core:io"

import "../temple"

constructor_type :: "gdextension.PtrConstructor"
destructor_type :: "gdextension.PtrDestructor"
operator_evaluator_type :: "gdextension.PtrOperatorEvaluator"
builtin_method_type :: "gdextension.PtrBuiltInMethod"

// these are already in gdextension
ignore_enums_by_name :: []string{"Variant.Operator", "Variant.Type"}

enum_prefix_alias := map[string]string {
    "Error" = "Err",
}

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

pod_type_map := map[string]string{
    "bool"     = "bool",
    "real_t"   = "f64",
    "float"    = "f64",
    "double"   = "f64",
    "int"      = "int",
    "int8_t"   = "i8",
    "int16_t"  = "i16",
    "int32_t"  = "i32",
    "int64_t"  = "i64",
    "uint8_t"  = "u8",
    "uint16_t" = "u16",
    "uint32_t" = "u32",
    "uint64_t" = "u64",
}

native_odin_types :: []string {
    "bool",
    "f32",
    "f64",
    "int",
    "i8",
    "i16",
    "i32",
    "i64",
    "u8",
    "u16",
    "u32",
    "u64",
}

types_with_odin_string_constructors :: []string{"String", "StringName"}

BuiltinClassStatePair :: struct {
    state: ^State,
    class: ^StateBuiltinClass,
}

ClassStatePair :: struct {
    state: ^State,
    class: ^StateClass,
}


enums_template := temple.compiled("../templates/bindgen_enums.temple.twig", ^State)
util_template := temple.compiled("../templates/bindgen_util.temple.twig", ^State)
variant_builtin_template := temple.compiled("../templates/bindgen_variant.temple.twig", ^State)
builtin_class_template := temple.compiled("../templates/bindgen_builtin_class.temple.twig", BuiltinClassStatePair)
class_template := temple.compiled("../templates/bindgen_class.temple.twig", ClassStatePair)

preprocess_state_enums :: proc(state: ^State) {
    for name, &global_enum in &state.enums {
        // we ignore some enums by name, such as those pre-implemented
        // in gdextension
        if slice.contains(ignore_enums_by_name, name) {
            global_enum.odin_skip = true
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

        global_enum.odin_case_name = odin_case_name
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
            global_enum.odin_values[value_name] = value
        }
    }
    return
}

preprocess_state_utility_functions :: proc(state: ^State) {
    // generate frontend
    for &function in &state.utility_functions {
        for &argument, i in &function.arguments {
            if pod_type, is_pod_type := argument.arg_type.pod_type.(string); is_pod_type {
                argument.arg_type_str = pod_type
            } else {
                concat_strings := [2]string { "__variant_package.", argument.arg_type.odin_type }
                argument.arg_type_str = strings.concatenate(concat_strings[:])
            }
        }
        // TODO: is_vararg
        return_type, has_return_type := function.return_type.(StateType)
        if has_return_type {
            // POD-mapped types use native odin types instead of classes
            if pod_type, is_pod_type := return_type.pod_type.(string); is_pod_type {
                function.return_type_str = pod_type
            } else {
                concat_strings := [2]string { "__variant_package.", return_type.odin_type }
                function.return_type_str = strings.concatenate(concat_strings[:])
            }
        }
    }
}

preprocess_state_builtin_classes :: proc(state: ^State) {
    for name, &class in &state.builtin_classes {
        class.is_special_string_type = slice.contains(types_with_odin_string_constructors, class.godot_name)

        // operators
        for _, &operator in &class.operators {
            for &overload in &operator.overloads {
                overload.right_variant_type_name = "Nil"
                right_state_type, has_right_type := overload.right_type.(StateType)
                if has_right_type {
                    // we dont use the prio type since this needs to be a VariantType - prio_type will use
                    // pod_type if its not nil, which will never be a VariantType.
                    overload.right_variant_type_name = right_state_type.odin_type
                }
                // Variant just gets passed to this lookup as Nil for some reason, despite
                // Nil also being used for unary operators. Godot is silly sometimes
                if overload.right_variant_type_name == "Variant" {
                    overload.right_variant_type_name = "Nil"
                }

                if has_right_type {
                    overload.right_type_str = right_state_type.prio_type
                    overload.right_type_is_native = slice.contains(native_odin_types, right_state_type.prio_type)
                } else {
                    overload.right_type_str = ""
                }

                if has_right_type && overload.right_type_is_native {
                    overload.right_type_is_ref = true
                    overload.right_type_ptr_str = "other"
                } else if has_right_type {
                    overload.right_type_is_ref = true
                    overload.right_type_ptr_str = "other._opaque"
                } else {
                    overload.right_type_ptr_str = "nil"
                }
            }
        }

        // used in the special constructor for some string types
        if slice.contains(types_with_odin_string_constructors, name) {
            class.odin_needs_strings = true
        }

        for _, &method in &class.methods {
            return_type, has_return_type := method.return_type.(StateType)
            if has_return_type {
                // POD-mapped types use native odin types instead of classes
                if pod_type, is_pod_type := return_type.pod_type.(string); is_pod_type {
                    method.return_type_str = pod_type
                } else {
                    method.return_type_str = return_type.odin_type
                }
            }

            for &argument in method.arguments {
                if pod_type, is_pod_type := argument.arg_type.pod_type.(string); is_pod_type {
                    argument.arg_type_str = pod_type
                } else {
                    argument.arg_type_str = argument.arg_type.odin_type
                }

                if default_value, has_default_value := argument.default_value.(string); has_default_value {
                    // N.B. I'm pretty sure that "null" in Godot is just a 0'd out opaque pointer, so a default of {} should
                    // work for variant types
                    if default_value == "null" {
                        argument.default_value = "{}"
                    } else if strings.has_prefix(default_value, "Vector3(") {
                        concat := []string{"new_vector3(", default_value[len("Vector3("):]}
                        argument.default_value = _builtin_class_method_default_arg_backing_field_name(method, argument)
                        argument.default_value_is_backing_field = true
                        argument.default_value_backing_field_assign = strings.concatenate(concat[:])
                    } else if strings.has_prefix(default_value, "Vector2(") {
                        concat := []string{"new_vector2(", default_value[len("Vector2("):]}
                        argument.default_value = _builtin_class_method_default_arg_backing_field_name(method, argument)
                        argument.default_value_is_backing_field = true
                        argument.default_value_backing_field_assign = strings.concatenate(concat[:])
                    } else if strings.has_prefix(default_value, "Color(") {
                        concat := []string{"new_color(", default_value[len("Color("):]}
                        argument.default_value = _builtin_class_method_default_arg_backing_field_name(method, argument)
                        argument.default_value_is_backing_field = true
                        argument.default_value_backing_field_assign = strings.concatenate(concat[:])
                    } else if strings.has_prefix(default_value, "\"") && strings.has_suffix(default_value, "\"") {
                        new_string_proc_name := "new_string_name_cstring(" if argument.arg_type_str == "StringName" else "new_string_cstring("
                        concat := []string{new_string_proc_name, default_value, ")"}
                        argument.default_value = _builtin_class_method_default_arg_backing_field_name(method, argument)
                        argument.default_value_is_backing_field = true
                        argument.default_value_backing_field_assign = strings.concatenate(concat[:])
                    }
                }
            }
        }
    }
}

_builtin_class_method_default_arg_backing_field_name :: proc(method: StateBuiltinClassMethod, argument: StateFunctionArgument) -> string{
    default_concat := []string{"__", method.backing_func_name, "__default__", argument.name, "__", argument.arg_type_str}
    return strings.concatenate(default_concat[:])
}

generate_global_enums :: proc(state: ^State) {
    fhandle, ferr := os.open("core/enums.gen.odin", os.O_CREATE | os.O_TRUNC)
    if ferr != 0 {
        fmt.eprintf("Error opening core/enums.gen.odin\n")
        return
    }
    defer os.close(fhandle)

    fstream := os.stream_from_handle(fhandle)

    enums_template.with(fstream, state)
}

generate_utility_functions :: proc(state: ^State) {
    fhandle, ferr := os.open("core/util.gen.odin", os.O_CREATE | os.O_TRUNC)
    if ferr != 0 {
        fmt.eprintf("Error opening core/util.gen.odin\n")
        return
    }
    defer os.close(fhandle)

    fstream := os.stream_from_handle(fhandle)

    util_template.with(fstream, state)
}

generate_builtin_classes :: proc(state: ^State) {
    for name, &class in &state.builtin_classes {
        // POD data types are covered by native odin types
        if slice.contains(pod_types, name) {
            continue
        }

        file_name_parts := [?]string{"variant/", class.godot_name, ".gen.odin"}
        file_name := strings.concatenate(file_name_parts[:])
        defer delete(file_name)

        fhandle, ferr := os.open(file_name, os.O_CREATE | os.O_TRUNC)
        if ferr != 0 {
            fmt.eprintf("Error opening %v\n", file_name)
            return
        }
        defer os.close(fhandle)

        fstream := os.stream_from_handle(fhandle)
        pair := BuiltinClassStatePair{state = state, class = &class}
        builtin_class_template.with(fstream, pair)
    }

    // Variant and Object are special cases which arent provided by the API
    // N.B. Object is actually a core API class and should be declared in core/, but for now isnt
    file_name := "variant/Variant.gen.odin"
    fhandle, ferr := os.open(file_name, os.O_CREATE | os.O_TRUNC)
    if ferr != 0 {
        fmt.eprintf("Error opening %v\n", file_name)
        return
    }
    defer os.close(fhandle)

    fstream := os.stream_from_handle(fhandle)
    variant_builtin_template.with(fstream, state)
}

generate_classes :: proc(state: ^State) {
    for name, &class in &state.classes {

        file_name_parts := [?]string{class.package_name, "/", class.godot_name, ".gen.odin"}
        file_name := strings.concatenate(file_name_parts[:])
        defer delete(file_name)

        fhandle, ferr := os.open(file_name, os.O_CREATE | os.O_TRUNC)
        if ferr != 0 {
            fmt.eprintf("Error opening %v\n", file_name)
            return
        }
        defer os.close(fhandle)

        fstream := os.stream_from_handle(fhandle)
        pair := ClassStatePair{state = state, class = &class}
        class_template.with(fstream, pair)
    }
}

generate_bindings :: proc(state: ^State) {
    preprocess_state_enums(state)
    preprocess_state_utility_functions(state)
    preprocess_state_builtin_classes(state)

    generate_global_enums(state)
    generate_utility_functions(state)
    generate_builtin_classes(state)
    generate_classes(state)
}

/*
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
*/

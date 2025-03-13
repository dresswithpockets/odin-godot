package bind

import "base:intrinsics"
import gd "godot:gdextension"
import var "godot:variant"

simple_property_info :: proc "contextless" (type: gd.Variant_Type, name: ^var.String_Name) -> gd.PropertyInfo {
    return gd.PropertyInfo {
        name        = name,
        type        = type,
        hint        = 0, // .None
        hint_string = var.string_empty_ref(),
        class_name  = var.string_name_empty_ref(),
        usage       = 0, // .Default
    }
}

expect_args :: proc "contextless" (
    args: [^]gd.VariantPtr,
    arg_count: i64,
    error: ^gd.CallError,
    arg_types: ..gd.Variant_Type,
) -> bool {
    if arg_count < cast(i64)len(arg_types) {
        error.error = .Too_Few_Arguments
        error.expected = cast(i32)len(arg_types)
        return false
    }

    if arg_count > cast(i64)len(arg_types) {
        error.error = .Too_Many_Arguments
        error.expected = cast(i32)len(arg_types)
        return false
    }

    for arg_type, arg_idx in arg_types {
        type := gd.variant_get_type(cast(^var.Variant)args[arg_idx])
        if type != arg_type {
            error.error = .Invalid_Argument
            error.expected = cast(i32)arg_type
            error.argument = cast(i32)arg_idx
            return false
        }
    }

    return true
}

bind_property_and_methods :: proc(
    class_name: ^var.String_Name,
    name: ^var.String_Name,
    getter_name: ^var.String_Name,
    setter_name: ^var.String_Name,
    getter: proc "contextless" (self: ^$Self) -> $Value,
    setter: proc "contextless" (self: ^Self, value: Value),
) {
    bind_returning_method_0_args(class_name, getter_name, getter)
    bind_void_method_1_args(class_name, setter_name, setter, name)

    type := var.variant_type(Value)
    info := simple_property_info(type, name)
    gd.classdb_register_extension_class_property(gd.library, class_name, &info, setter_name, getter_name)
}

bind_property :: proc(
    class_name: ^var.String_Name,
    name: ^var.String_Name,
    type: gd.Variant_Type,
    getter: ^var.String_Name,
    setter: ^var.String_Name,
) {
    info := simple_property_info(type, name)
    gd.classdb_register_extension_class_property(gd.library, class_name, &info, setter, getter)
}

// bind_void_method :: proc {
//     bind_void_method_1_args,
// }

// bind_void_method_1_args :: proc(
//     class_name: ^var.String_Name,
//     method_name: ^var.String_Name,
//     function: $P/proc(self: $Self, arg0: $Arg0),
//     arg0_name: string,
// ) {
//     ptrcall, call := get_void_calls(Self, Arg0)
//     method_info := gd.ExtensionClassMethodInfo {
//         name                   = method_name,
//         method_user_data       = function,
//         call_func              = call,
//         ptr_call_func          = ptrcall,
//         method_flags           = 0,
//         has_return_value       = false,
//         return_value_metadata  = .None,
//         argument_count         = 1,
//         default_argument_count = 0,
//     }

//     args_info := [0]gd.PropertyInfo{simple_property_info(var.variant_type(Arg0), arg0_name),}
//     args_metadata := [0]gd.ExtensionClassMethodArgumentMetadata{.None}

//     method_info.arguments_info = &args_info[0]
//     method_info.arguments_metadata = &args_metadata[0]

//     gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
// }

// bind_returning_method :: proc {
//     bind_returning_method_1_args,
// }

// bind_returning_method_1_args :: proc(
//     class_name: ^var.String_Name,
//     method_name: ^var.String_Name,
//     function: $P/proc(self: $Self, arg0: $Arg0) -> $Ret,
//     arg0_name: string,
// ) {
//     return_info := simple_property_info(var.variant_type(Ret), var.string_name_empty_ref())

//     ptrcall, call := get_void_calls(Self, Arg0)
//     method_info := gd.ExtensionClassMethodInfo {
//         name                   = method_name,
//         method_user_data       = function,
//         call_func              = call,
//         ptr_call_func          = ptrcall,
//         method_flags           = 0,
//         has_return_value       = true,
//         return_value_info      = return_info,
//         return_value_metadata  = .None,
//         argument_count         = 1,
//         default_argument_count = 0,
//     }

//     args_info := [0]gd.PropertyInfo{simple_property_info(var.variant_type(Arg0), arg0_name)}
//     args_metadata := [0]gd.ExtensionClassMethodArgumentMetadata{.None}

//     method_info.arguments_info = &args_info[0]
//     method_info.arguments_metadata = &args_metadata[0]

//     gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
// }

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

package bind

import "base:intrinsics"
import "godot:godot"
import gdext "godot:gdextension"

simple_property_info :: proc "contextless" (type: gdext.Variant_Type, name: ^godot.String_Name) -> gdext.PropertyInfo {
    return gdext.PropertyInfo {
        name        = name,
        type        = type,
        hint        = 0, // .None
        hint_string = godot.string_empty_ref(),
        class_name  = godot.string_name_empty_ref(),
        usage       = 0, // .Default
    }
}

expect_args :: proc "contextless" (
    args: [^]gdext.VariantPtr,
    arg_count: i64,
    error: ^gdext.CallError,
    arg_types: ..gdext.Variant_Type,
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
        type := gdext.variant_get_type(cast(^godot.Variant)args[arg_idx])
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
    class_name: ^godot.String_Name,
    name: ^godot.String_Name,
    getter_name: ^godot.String_Name,
    setter_name: ^godot.String_Name,
    getter: proc "contextless" (self: ^$Self) -> $Value,
    setter: proc "contextless" (self: ^Self, value: Value),
) {
    bind_returning_method_0_args(class_name, getter_name, getter)
    bind_void_method_1_args(class_name, setter_name, setter, name)

    type := godot.variant_type(Value)
    info := simple_property_info(type, name)
    gdext.classdb_register_extension_class_property(gdext.library, class_name, &info, setter_name, getter_name)
}

bind_property :: proc(
    class_name: ^godot.String_Name,
    name: ^godot.String_Name,
    type: gdext.Variant_Type,
    getter: ^godot.String_Name,
    setter: ^godot.String_Name,
) {
    info := simple_property_info(type, name)
    gdext.classdb_register_extension_class_property(gdext.library, class_name, &info, setter, getter)
}

Signal_Arg :: struct {
    name: ^godot.String_Name,
    type: gdext.Variant_Type,
}

bind_signal :: proc(class_name: ^godot.String_Name, signal_name: ^godot.String_Name, args: ..Signal_Arg) {
    if len(args) == 0 {
        gdext.classdb_register_extension_class_signal(gdext.library, class_name, signal_name, nil, 0)
        return
    }

    args_info := make([]gdext.PropertyInfo, len(args))
    defer delete(args_info)

    for arg, idx in args {
        args_info[idx] = simple_property_info(arg.type, arg.name)
    }

    gdext.classdb_register_extension_class_signal(gdext.library, class_name, signal_name, raw_data(args_info), cast(i64)len(args))
}

// bind_void_method :: proc {
//     bind_void_method_1_args,
// }

// bind_void_method_1_args :: proc(
//     class_name: ^godot.String_Name,
//     method_name: ^godot.String_Name,
//     function: $P/proc(self: $Self, arg0: $Arg0),
//     arg0_name: string,
// ) {
//     ptrcall, call := get_void_calls(Self, Arg0)
//     method_info := gdext.ExtensionClassMethodInfo {
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

//     args_info := [0]gdext.PropertyInfo{simple_property_info(godot.variant_type(Arg0), arg0_name),}
//     args_metadata := [0]gdext.ExtensionClassMethodArgumentMetadata{.None}

//     method_info.arguments_info = &args_info[0]
//     method_info.arguments_metadata = &args_metadata[0]

//     gdext.classdb_register_extension_class_method(gdext.library, class_name, &method_info)
// }

// bind_returning_method :: proc {
//     bind_returning_method_1_args,
// }

// bind_returning_method_1_args :: proc(
//     class_name: ^godot.String_Name,
//     method_name: ^godot.String_Name,
//     function: $P/proc(self: $Self, arg0: $Arg0) -> $Ret,
//     arg0_name: string,
// ) {
//     return_info := simple_property_info(godot.variant_type(Ret), godot.string_name_empty_ref())

//     ptrcall, call := get_void_calls(Self, Arg0)
//     method_info := gdext.ExtensionClassMethodInfo {
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

//     args_info := [0]gdext.PropertyInfo{simple_property_info(godot.variant_type(Arg0), arg0_name)}
//     args_metadata := [0]gdext.ExtensionClassMethodArgumentMetadata{.None}

//     method_info.arguments_info = &args_info[0]
//     method_info.arguments_metadata = &args_metadata[0]

//     gdext.classdb_register_extension_class_method(gdext.library, class_name, &method_info)
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

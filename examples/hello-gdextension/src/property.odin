package example

import gd "../../../gdextension"
import var "../../../variant"
import core "../../../core"

new_property :: proc(type: gd.VariantType, name: ^var.StringName) -> gd.PropertyInfo {
    return gd.PropertyInfo {
        name = name,
        type = type,
        hint = cast(u32)core.PropertyHint.None,
        hint_string = var.string_empty_ref(),
        class_name = var.string_name_empty_ref(),
        usage = cast(u32)core.PropertyUsageFlags.Default,
    }
}

MethodBindArgument :: struct {
    name: ^var.StringName,
    type: gd.VariantType,
}

bind_method_return :: proc(class_name: ^var.StringName, method_name: ^var.StringName, function: rawptr, return_type: gd.VariantType, call_func: gd.ExtensionClassMethodCall, ptr_call_func: gd.ExtensionClassMethodPtrCall, args: ..MethodBindArgument) {
    return_info := new_property(return_type, var.string_name_empty_ref())

    method_info := gd.ExtensionClassMethodInfo{
        name                   = method_name,
        method_user_data       = function,
        call_func              = call_func,
        ptr_call_func          = ptr_call_func,
        method_flags           = 0,
        has_return_value       = true,
        return_value_info      = &return_info,
        return_value_metadata  = .None,
        argument_count         = 0,
        default_argument_count = 0,
    }

    if len(args) > 0 {
        args_info := make([]gd.PropertyInfo, len(args))
        args_metadata := make([]gd.ExtensionClassMethodArgumentMetadata, len(args))
        for arg, idx in args {
            args_info[idx] = new_property(arg.type, arg.name)
            args_metadata[idx] = .None
        }
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

bind_method_no_return :: proc(class_name: ^var.StringName, method_name: ^var.StringName, function: rawptr, call_func: gd.ExtensionClassMethodCall, ptr_call_func: gd.ExtensionClassMethodPtrCall, args: ..MethodBindArgument) {
    method_info := gd.ExtensionClassMethodInfo{
        name                  = method_name,
        method_user_data      = function,
        call_func             = call_func,
        ptr_call_func         = ptr_call_func,
        method_flags          = 0,
        has_return_value      = false,
        argument_count        = cast(u32)len(args),
    }

    args_info: []gd.PropertyInfo
    args_metadata: []gd.ExtensionClassMethodArgumentMetadata
    if len(args) > 0 {
        args_info = make([]gd.PropertyInfo, len(args))
        args_metadata = make([]gd.ExtensionClassMethodArgumentMetadata, len(args))
        for arg, idx in args {
            args_info[idx] = new_property(arg.type, arg.name)
            args_metadata[idx] = .None
        }
        method_info.arguments_info = raw_data(args_info)
        method_info.arguments_metadata = raw_data(args_metadata)
    }

    defer if len(args) > 0 {
        delete(args_info)
        delete(args_metadata)
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

bind_property :: proc(class_name: ^var.StringName, name: ^var.StringName, type: gd.VariantType, getter: ^var.StringName, setter: ^var.StringName) {
    info := new_property(type, name)
    gd.classdb_register_extension_class_property(gd.library, class_name, &info, setter, getter)
}

bind_signal :: proc(class_name: ^var.StringName, signal_name: ^var.StringName, args: ..MethodBindArgument) {
    if len(args) == 0 {
        gd.classdb_register_extension_class_signal(gd.library, class_name, signal_name, nil, 0)
        return
    }

    args_info := make([]gd.PropertyInfo, len(args))
    defer delete(args_info)

    for arg, idx in args {
        args_info[idx] = new_property(arg.type, arg.name)
    }

    gd.classdb_register_extension_class_signal(gd.library, class_name, signal_name, raw_data(args_info), cast(i64)len(args))
}

GetterFloat :: proc "c" (instance: rawptr) -> gd.float
SetterFloat :: proc "c" (instance: rawptr, value: gd.float)

ptrcall_getter_float :: proc "c" (method_user_data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, call_return: gd.TypePtr) {
    method := cast(GetterFloat)method_user_data
    (cast(^gd.float)call_return)^ = method(instance)
}

ptrcall_setter_float :: proc "c" (method_user_data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, call_return: gd.TypePtr) {
    method := cast(SetterFloat)method_user_data
    method(instance, (cast(^gd.float)args[0])^)
}

call_getter_float :: proc "c" (method_user_data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.VariantPtr, arg_count: i64, call_return: gd.VariantPtr, error: ^gd.CallError) {
    if arg_count != 0 {
        error.error = .TooManyArguments
        error.expected = 0
        return
    }
    
    method := cast(GetterFloat)method_user_data
    result := method(instance)
    var_float_constructor := gd.get_variant_from_type_constructor(.Float)
    var_float_constructor(cast(gd.UninitializedVariantPtr)call_return, cast(gd.TypePtr)&result)
}

call_setter_float :: proc "c" (method_user_data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.VariantPtr, arg_count: i64, call_return: gd.VariantPtr, error: ^gd.CallError) {
    if arg_count < 1 {
        error.error = .TooFewArguments
        error.expected = 1
        return
    }

    if arg_count > 1 {
        error.error = .TooManyArguments
        error.expected = 1
        return
    }

    type := gd.variant_get_type(args[0])
    if type != .Float {
        error.error = .InvalidArgument
        error.expected = cast(i32)gd.VariantType.Float
        error.argument = 0
        return
    }

    arg1: f64
    float_from_var_constructor := gd.get_variant_to_type_constructor(.Float)
    float_from_var_constructor(cast(gd.TypePtr)&arg1, args[0])

    method := cast(SetterFloat)method_user_data
    method(instance, arg1)
}
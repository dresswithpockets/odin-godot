package test

import gd "godot:gdextension"
import var "godot:variant"

new_property :: proc(type: gd.VariantType, name: ^var.String_Name) -> gd.PropertyInfo {
    return gd.PropertyInfo {
        name        = name,
        type        = type,
        //hint = cast(u32)core.PropertyHint.None,
        hint        = 0,
        hint_string = var.string_empty_ref(),
        class_name  = var.string_name_empty_ref(),
        //usage = cast(u32)core.PropertyUsageFlags.Default,
        usage       = 0,
    }
}

Method_Bind_Info :: struct {
    class_name:  ^var.String_Name,
    method_name: ^var.String_Name,
    function:    rawptr,
    return_type: gd.VariantType,
    args:        []Method_Bind_Arg,
    flags:       bit_set[gd.ExtensionClassMethodFlags],
}

Method_Bind_Arg :: struct {
    name:    ^var.String_Name,
    type:    gd.VariantType,
    default: ^var.Variant,
}

MethodBindArgument :: struct {
    name: ^var.String_Name,
    type: gd.VariantType,
}

bind_method_return :: proc(
    class_name: ^var.String_Name,
    method_name: ^var.String_Name,
    function: rawptr,
    return_type: gd.VariantType,
    call_func: gd.ExtensionClassMethodCall,
    ptr_call_func: gd.ExtensionClassMethodPtrCall,
    args: ..MethodBindArgument,
) {
    return_info := new_property(return_type, var.string_name_empty_ref())

    method_info := gd.ExtensionClassMethodInfo {
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

    args_info: []gd.PropertyInfo
    args_metadata: []gd.ExtensionClassMethodArgumentMetadata
    if len(args) > 0 {
        args_info = make([]gd.PropertyInfo, len(args))
        args_metadata = make([]gd.ExtensionClassMethodArgumentMetadata, len(args))
        for arg, idx in args {
            args_info[idx] = new_property(arg.type, arg.name)
            args_metadata[idx] = .None
        }

        method_info.argument_count = cast(u32)len(args)
        method_info.arguments_info = &args_info[0]
        method_info.arguments_metadata = &args_metadata[0]
    }

    defer if len(args) > 0 {
        delete(args_info)
        delete(args_metadata)
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

bind_method_no_return :: proc(
    class_name: ^var.String_Name,
    method_name: ^var.String_Name,
    function: rawptr,
    call_func: gd.ExtensionClassMethodCall,
    ptr_call_func: gd.ExtensionClassMethodPtrCall,
    args: ..MethodBindArgument,
) {
    method_info := gd.ExtensionClassMethodInfo {
        name             = method_name,
        method_user_data = function,
        call_func        = call_func,
        ptr_call_func    = ptr_call_func,
        method_flags     = 0,
        has_return_value = false,
        argument_count   = cast(u32)len(args),
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

bind_property :: proc(
    class_name: ^var.String_Name,
    name: ^var.String_Name,
    type: gd.VariantType,
    getter: ^var.String_Name,
    setter: ^var.String_Name,
) {
    info := new_property(type, name)
    gd.classdb_register_extension_class_property(gd.library, class_name, &info, setter, getter)
}

bind_signal :: proc(class_name: ^var.String_Name, signal_name: ^var.String_Name, args: ..MethodBindArgument) {
    if len(args) == 0 {
        gd.classdb_register_extension_class_signal(gd.library, class_name, signal_name, nil, 0)
        return
    }

    args_info := make([]gd.PropertyInfo, len(args))
    defer delete(args_info)

    for arg, idx in args {
        args_info[idx] = new_property(arg.type, arg.name)
    }

    gd.classdb_register_extension_class_signal(
        gd.library,
        class_name,
        signal_name,
        raw_data(args_info),
        cast(i64)len(args),
    )
}

expect_args :: proc "contextless" (args: [^]gd.VariantPtr, arg_count: i64, error: ^gd.CallError, arg_types: ..gd.VariantType) -> bool {
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

method_no_ret :: proc {
    method_no_ret_1,
}

method_no_ret_1 :: proc "contextless" (
    $Self: typeid,
    $Arg1: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc(self: ^Self, arg1: Arg1)
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        method(cast(^Self)instance, (cast(^Arg1)args[0])^)
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(args, arg_count, error, var.variant_type(Arg1)) {
            return
        }

        context = gd.godot_context()

        arg1 := var.variant_to(cast(^var.Variant)args[0], Arg1)
        method := cast(Proc)data
        method(cast(^Self)instance, arg1)
    }
    return ptrcall, call
}

method_ret :: proc {
    method_ret_0,
    method_ret_1,
}

method_ret_0 :: proc "contextless" (
    $Self: typeid,
    $Ret: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc(self: ^Self) -> Ret
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        (cast(^Ret)ret)^ = method(cast(^Self)instance)
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(args, arg_count, error) {
            return
        }

        context = gd.godot_context()

        method := cast(Proc)data
        result := method(cast(^Self)instance)

        var.variant_into_ptr(&result, cast(^var.Variant)ret)
    }
    return ptrcall, call
}

method_ret_1 :: proc "contextless" (
    $Self: typeid,
    $Arg1: typeid,
    $Ret: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc(self: ^Self, arg1: Arg1) -> Ret
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        (cast(^Ret)ret)^ = method(cast(^Self)instance, (cast(^Arg1)args[0])^)
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(args, arg_count, error, var.variant_type(Arg1)) {
            return
        }

        context = gd.godot_context()

        arg1 := var.variant_to(cast(^var.Variant)args[0], Arg1)
        method := cast(Proc)data
        result := method(cast(^Self)instance, arg1)

        var.variant_into_ptr(&result, cast(^var.Variant)ret)
    }
    return ptrcall, call
}

package bind

import gd "godot:gdextension"
import "godot:godot"

bind_void_method :: proc {
    bind_void_method_0_args,
    bind_void_method_1_args,
    bind_void_method_2_args,
    bind_void_method_3_args,
    bind_void_method_4_args,
    bind_void_method_5_args,
    bind_void_method_6_args,
    bind_void_method_7_args,
    bind_void_method_8_args,
    bind_void_method_9_args,
    bind_void_method_10_args,
    bind_void_method_11_args,
    bind_void_method_12_args,
    bind_void_method_13_args,
    bind_void_method_14_args,
    bind_void_method_15_args,
}

bind_returning_method :: proc {
    bind_returning_method_0_args,
    bind_returning_method_1_args,
    bind_returning_method_2_args,
    bind_returning_method_3_args,
    bind_returning_method_4_args,
    bind_returning_method_5_args,
    bind_returning_method_6_args,
    bind_returning_method_7_args,
    bind_returning_method_8_args,
    bind_returning_method_9_args,
    bind_returning_method_10_args,
    bind_returning_method_11_args,
    bind_returning_method_12_args,
    bind_returning_method_13_args,
    bind_returning_method_14_args,
    bind_returning_method_15_args,
}

get_void_calls :: proc {
    get_void_calls_0_args,
    get_void_calls_1_args,
    get_void_calls_2_args,
    get_void_calls_3_args,
    get_void_calls_4_args,
    get_void_calls_5_args,
    get_void_calls_6_args,
    get_void_calls_7_args,
    get_void_calls_8_args,
    get_void_calls_9_args,
    get_void_calls_10_args,
    get_void_calls_11_args,
    get_void_calls_12_args,
    get_void_calls_13_args,
    get_void_calls_14_args,
    get_void_calls_15_args,
}

get_returning_calls :: proc {
    get_returning_calls_0_args,
    get_returning_calls_1_args,
    get_returning_calls_2_args,
    get_returning_calls_3_args,
    get_returning_calls_4_args,
    get_returning_calls_5_args,
    get_returning_calls_6_args,
    get_returning_calls_7_args,
    get_returning_calls_8_args,
    get_returning_calls_9_args,
    get_returning_calls_10_args,
    get_returning_calls_11_args,
    get_returning_calls_12_args,
    get_returning_calls_13_args,
    get_returning_calls_14_args,
    get_returning_calls_15_args,
}

bind_void_method_0_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (self: ^$Self),
) {
    ptrcall, call := get_void_calls(Self)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = false,
        return_value_metadata  = .None,
        argument_count         = 0,
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

bind_returning_method_0_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (self: ^$Self) -> $Ret,
) {
    return_info := simple_property_info(godot.variant_type(Ret), godot.string_name_empty_ref())

    ptrcall, call := get_returning_calls(Self, Ret)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = true,
        return_value_info      = &return_info,
        return_value_metadata  = .None,
        argument_count         = 0,
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

get_void_calls_0_args :: proc "contextless" (
    $Self: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (self: ^Self)
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        method(cast(^Self)instance)
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
        method(cast(^Self)instance)
    }
    return ptrcall, call
}

get_returning_calls_0_args :: proc "contextless" (
    $Self: typeid,
    $Ret: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (self: ^Self) -> Ret
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

        godot.variant_into_ptr(&result, cast(^godot.Variant)ret)
    }
    return ptrcall, call
}

get_void_calls_1_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (self: ^Self, arg0: Arg0)
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        method(cast(^Self)instance, (cast(^Arg0)args[0])^)
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(args, arg_count, error, godot.variant_type(Arg0)) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        method := cast(Proc)data
        method(cast(^Self)instance, arg0)
    }
    return ptrcall, call
}

get_returning_calls_1_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Ret: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (self: ^Self, arg0: Arg0) -> Ret
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        (cast(^Ret)ret)^ = method(cast(^Self)instance, (cast(^Arg0)args[0])^)
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(args, arg_count, error, godot.variant_type(Arg0)) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        method := cast(Proc)data
        result := method(cast(^Self)instance, arg0)

        godot.variant_into_ptr(&result, cast(^godot.Variant)ret)
    }
    return ptrcall, call
}

bind_void_method_1_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (self: ^$Self, arg0: $Arg0),
    arg0_name: ^godot.String_Name,
) {
    args_info := [1]gd.PropertyInfo{simple_property_info(godot.variant_type(Arg0), arg0_name)}
    args_metadata := [1]gd.ExtensionClassMethodArgumentMetadata{.None}

    ptrcall, call := get_void_calls(Self, Arg0)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = false,
        return_value_metadata  = .None,
        argument_count         = 1,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

bind_returning_method_1_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (self: ^$Self, arg0: $Arg0) -> $Ret,
    arg0_name: ^godot.String_Name,
) {
    args_info := [1]gd.PropertyInfo{simple_property_info(godot.variant_type(Arg0), arg0_name)}
    args_metadata := [1]gd.ExtensionClassMethodArgumentMetadata{.None}

    return_info := simple_property_info(godot.variant_type(Ret), godot.string_name_empty_ref())

    ptrcall, call := get_returning_calls(Self, Arg0, Ret)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = true,
        return_value_info      = &return_info,
        return_value_metadata  = .None,
        argument_count         = 1,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

get_void_calls_2_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (self: ^Self, arg0: Arg0, arg1: Arg1)
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        method(cast(^Self)instance, (cast(^Arg0)args[0])^, (cast(^Arg1)args[1])^)
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(args, arg_count, error, godot.variant_type(Arg0), godot.variant_type(Arg1)) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        method := cast(Proc)data
        method(cast(^Self)instance, arg0, arg1)
    }
    return ptrcall, call
}

get_returning_calls_2_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Ret: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (self: ^Self, arg0: Arg0, arg1: Arg1) -> Ret
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        (cast(^Ret)ret)^ = method(cast(^Self)instance, (cast(^Arg0)args[0])^, (cast(^Arg1)args[1])^)
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(args, arg_count, error, godot.variant_type(Arg0), godot.variant_type(Arg1)) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        method := cast(Proc)data
        result := method(cast(^Self)instance, arg0, arg1)

        godot.variant_into_ptr(&result, cast(^godot.Variant)ret)
    }
    return ptrcall, call
}

bind_void_method_2_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (self: ^$Self, arg0: $Arg0, arg1: $Arg1),
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
) {
    args_info := [2]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
    }
    args_metadata := [2]gd.ExtensionClassMethodArgumentMetadata{.None, .None}

    ptrcall, call := get_void_calls(Self, Arg0, Arg1)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = false,
        return_value_metadata  = .None,
        argument_count         = 2,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

bind_returning_method_2_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (self: ^$Self, arg0: $Arg0, arg1: $Arg1) -> $Ret,
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
) {
    args_info := [2]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
    }
    args_metadata := [2]gd.ExtensionClassMethodArgumentMetadata{.None, .None}

    return_info := simple_property_info(godot.variant_type(Ret), godot.string_name_empty_ref())

    ptrcall, call := get_returning_calls(Self, Arg0, Arg1, Ret)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = true,
        return_value_info      = &return_info,
        return_value_metadata  = .None,
        argument_count         = 2,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

get_void_calls_3_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (self: ^Self, arg0: Arg0, arg1: Arg1, arg2: Arg2)
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        method(cast(^Self)instance, (cast(^Arg0)args[0])^, (cast(^Arg1)args[1])^, (cast(^Arg2)args[2])^)
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        method := cast(Proc)data
        method(cast(^Self)instance, arg0, arg1, arg2)
    }
    return ptrcall, call
}

get_returning_calls_3_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Ret: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (self: ^Self, arg0: Arg0, arg1: Arg1, arg2: Arg2) -> Ret
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        (cast(^Ret)ret)^ = method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        method := cast(Proc)data
        result := method(cast(^Self)instance, arg0, arg1, arg2)

        godot.variant_into_ptr(&result, cast(^godot.Variant)ret)
    }
    return ptrcall, call
}

bind_void_method_3_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (self: ^$Self, arg0: $Arg0, arg1: $Arg1, arg2: $Arg2),
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
) {
    args_info := [3]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
    }
    args_metadata := [3]gd.ExtensionClassMethodArgumentMetadata{.None, .None, .None}

    ptrcall, call := get_void_calls(Self, Arg0, Arg1, Arg2)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = false,
        return_value_metadata  = .None,
        argument_count         = 3,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

bind_returning_method_3_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (self: ^$Self, arg0: $Arg0, arg1: $Arg1, arg2: $Arg2) -> $Ret,
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
) {
    args_info := [3]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
    }
    args_metadata := [3]gd.ExtensionClassMethodArgumentMetadata{.None, .None, .None}

    return_info := simple_property_info(godot.variant_type(Ret), godot.string_name_empty_ref())

    ptrcall, call := get_returning_calls(Self, Arg0, Arg1, Arg2, Ret)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = true,
        return_value_info      = &return_info,
        return_value_metadata  = .None,
        argument_count         = 3,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

get_void_calls_4_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (self: ^Self, arg0: Arg0, arg1: Arg1, arg2: Arg2, arg3: Arg3)
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        method := cast(Proc)data
        method(cast(^Self)instance, arg0, arg1, arg2, arg3)
    }
    return ptrcall, call
}

get_returning_calls_4_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Ret: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (self: ^Self, arg0: Arg0, arg1: Arg1, arg2: Arg2, arg3: Arg3) -> Ret
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        (cast(^Ret)ret)^ = method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        method := cast(Proc)data
        result := method(cast(^Self)instance, arg0, arg1, arg2, arg3)

        godot.variant_into_ptr(&result, cast(^godot.Variant)ret)
    }
    return ptrcall, call
}

bind_void_method_4_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (self: ^$Self, arg0: $Arg0, arg1: $Arg1, arg2: $Arg2, arg3: $Arg3),
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
) {
    args_info := [4]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
    }
    args_metadata := [4]gd.ExtensionClassMethodArgumentMetadata{.None, .None, .None, .None}

    ptrcall, call := get_void_calls(Self, Arg0, Arg1, Arg2, Arg3)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = false,
        return_value_metadata  = .None,
        argument_count         = 4,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

bind_returning_method_4_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (self: ^$Self, arg0: $Arg0, arg1: $Arg1, arg2: $Arg2, arg3: $Arg3) -> $Ret,
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
) {
    args_info := [4]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
    }
    args_metadata := [4]gd.ExtensionClassMethodArgumentMetadata{.None, .None, .None, .None}

    return_info := simple_property_info(godot.variant_type(Ret), godot.string_name_empty_ref())

    ptrcall, call := get_returning_calls(Self, Arg0, Arg1, Arg2, Arg3, Ret)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = true,
        return_value_info      = &return_info,
        return_value_metadata  = .None,
        argument_count         = 4,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

get_void_calls_5_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (self: ^Self, arg0: Arg0, arg1: Arg1, arg2: Arg2, arg3: Arg3, arg4: Arg4)
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        method := cast(Proc)data
        method(cast(^Self)instance, arg0, arg1, arg2, arg3, arg4)
    }
    return ptrcall, call
}

get_returning_calls_5_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Ret: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (self: ^Self, arg0: Arg0, arg1: Arg1, arg2: Arg2, arg3: Arg3, arg4: Arg4) -> Ret
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        (cast(^Ret)ret)^ = method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        method := cast(Proc)data
        result := method(cast(^Self)instance, arg0, arg1, arg2, arg3, arg4)

        godot.variant_into_ptr(&result, cast(^godot.Variant)ret)
    }
    return ptrcall, call
}

bind_void_method_5_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (self: ^$Self, arg0: $Arg0, arg1: $Arg1, arg2: $Arg2, arg3: $Arg3, arg4: $Arg4),
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
) {
    args_info := [5]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
    }
    args_metadata := [5]gd.ExtensionClassMethodArgumentMetadata{.None, .None, .None, .None, .None}

    ptrcall, call := get_void_calls(Self, Arg0, Arg1, Arg2, Arg3, Arg4)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = false,
        return_value_metadata  = .None,
        argument_count         = 5,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

bind_returning_method_5_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
    ) -> $Ret,
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
) {
    args_info := [5]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
    }
    args_metadata := [5]gd.ExtensionClassMethodArgumentMetadata{.None, .None, .None, .None, .None}

    return_info := simple_property_info(godot.variant_type(Ret), godot.string_name_empty_ref())

    ptrcall, call := get_returning_calls(Self, Arg0, Arg1, Arg2, Arg3, Arg4, Ret)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = true,
        return_value_info      = &return_info,
        return_value_metadata  = .None,
        argument_count         = 5,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

get_void_calls_6_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
    )
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        method := cast(Proc)data
        method(cast(^Self)instance, arg0, arg1, arg2, arg3, arg4, arg5)
    }
    return ptrcall, call
}

get_returning_calls_6_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
    $Ret: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
    ) -> Ret
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        (cast(^Ret)ret)^ = method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        method := cast(Proc)data
        result := method(cast(^Self)instance, arg0, arg1, arg2, arg3, arg4, arg5)

        godot.variant_into_ptr(&result, cast(^godot.Variant)ret)
    }
    return ptrcall, call
}

bind_void_method_6_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
    ),
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
) {
    args_info := [6]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
    }
    args_metadata := [6]gd.ExtensionClassMethodArgumentMetadata{.None, .None, .None, .None, .None, .None}

    ptrcall, call := get_void_calls(Self, Arg0, Arg1, Arg2, Arg3, Arg4, Arg5)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = false,
        return_value_metadata  = .None,
        argument_count         = 6,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

bind_returning_method_6_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
    ) -> $Ret,
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
) {
    args_info := [6]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
    }
    args_metadata := [6]gd.ExtensionClassMethodArgumentMetadata{.None, .None, .None, .None, .None, .None}

    return_info := simple_property_info(godot.variant_type(Ret), godot.string_name_empty_ref())

    ptrcall, call := get_returning_calls(Self, Arg0, Arg1, Arg2, Arg3, Arg4, Arg5, Ret)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = true,
        return_value_info      = &return_info,
        return_value_metadata  = .None,
        argument_count         = 6,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

get_void_calls_7_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
    $Arg6: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
        arg6: Arg6,
    )
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
            (cast(^Arg6)args[6])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
            godot.variant_type(Arg6),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        arg6 := godot.variant_to(cast(^godot.Variant)args[6], Arg6)
        method := cast(Proc)data
        method(cast(^Self)instance, arg0, arg1, arg2, arg3, arg4, arg5, arg6)
    }
    return ptrcall, call
}

get_returning_calls_7_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
    $Arg6: typeid,
    $Ret: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
        arg6: Arg6,
    ) -> Ret
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        (cast(^Ret)ret)^ = method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
            (cast(^Arg6)args[6])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
            godot.variant_type(Arg6),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        arg6 := godot.variant_to(cast(^godot.Variant)args[6], Arg6)
        method := cast(Proc)data
        result := method(cast(^Self)instance, arg0, arg1, arg2, arg3, arg4, arg5, arg6)

        godot.variant_into_ptr(&result, cast(^godot.Variant)ret)
    }
    return ptrcall, call
}

bind_void_method_7_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
        arg6: $Arg6,
    ),
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
    arg6_name: ^godot.String_Name,
) {
    args_info := [7]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
        simple_property_info(godot.variant_type(Arg6), arg6_name),
    }
    args_metadata := [7]gd.ExtensionClassMethodArgumentMetadata{.None, .None, .None, .None, .None, .None, .None}

    ptrcall, call := get_void_calls(Self, Arg0, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = false,
        return_value_metadata  = .None,
        argument_count         = 7,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

bind_returning_method_7_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
        arg6: $Arg6,
    ) -> $Ret,
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
    arg6_name: ^godot.String_Name,
) {
    args_info := [7]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
        simple_property_info(godot.variant_type(Arg6), arg6_name),
    }
    args_metadata := [7]gd.ExtensionClassMethodArgumentMetadata{.None, .None, .None, .None, .None, .None, .None}

    return_info := simple_property_info(godot.variant_type(Ret), godot.string_name_empty_ref())

    ptrcall, call := get_returning_calls(Self, Arg0, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Ret)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = true,
        return_value_info      = &return_info,
        return_value_metadata  = .None,
        argument_count         = 7,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

get_void_calls_8_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
    $Arg6: typeid,
    $Arg7: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
        arg6: Arg6,
        arg7: Arg7,
    )
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
            (cast(^Arg6)args[6])^,
            (cast(^Arg7)args[7])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
            godot.variant_type(Arg6),
            godot.variant_type(Arg7),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        arg6 := godot.variant_to(cast(^godot.Variant)args[6], Arg6)
        arg7 := godot.variant_to(cast(^godot.Variant)args[7], Arg7)
        method := cast(Proc)data
        method(cast(^Self)instance, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    }
    return ptrcall, call
}

get_returning_calls_8_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
    $Arg6: typeid,
    $Arg7: typeid,
    $Ret: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
        arg6: Arg6,
        arg7: Arg7,
    ) -> Ret
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        (cast(^Ret)ret)^ = method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
            (cast(^Arg6)args[6])^,
            (cast(^Arg7)args[7])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
            godot.variant_type(Arg6),
            godot.variant_type(Arg7),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        arg6 := godot.variant_to(cast(^godot.Variant)args[6], Arg6)
        arg7 := godot.variant_to(cast(^godot.Variant)args[7], Arg7)
        method := cast(Proc)data
        result := method(cast(^Self)instance, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7)

        godot.variant_into_ptr(&result, cast(^godot.Variant)ret)
    }
    return ptrcall, call
}

bind_void_method_8_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
        arg6: $Arg6,
        arg7: $Arg7,
    ),
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
    arg6_name: ^godot.String_Name,
    arg7_name: ^godot.String_Name,
) {
    args_info := [8]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
        simple_property_info(godot.variant_type(Arg6), arg6_name),
        simple_property_info(godot.variant_type(Arg7), arg7_name),
    }
    args_metadata := [8]gd.ExtensionClassMethodArgumentMetadata{.None, .None, .None, .None, .None, .None, .None, .None}

    ptrcall, call := get_void_calls(Self, Arg0, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = false,
        return_value_metadata  = .None,
        argument_count         = 8,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

bind_returning_method_8_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
        arg6: $Arg6,
        arg7: $Arg7,
    ) -> $Ret,
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
    arg6_name: ^godot.String_Name,
    arg7_name: ^godot.String_Name,
) {
    args_info := [8]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
        simple_property_info(godot.variant_type(Arg6), arg6_name),
        simple_property_info(godot.variant_type(Arg7), arg7_name),
    }
    args_metadata := [8]gd.ExtensionClassMethodArgumentMetadata{.None, .None, .None, .None, .None, .None, .None, .None}

    return_info := simple_property_info(godot.variant_type(Ret), godot.string_name_empty_ref())

    ptrcall, call := get_returning_calls(Self, Arg0, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Ret)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = true,
        return_value_info      = &return_info,
        return_value_metadata  = .None,
        argument_count         = 8,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

get_void_calls_9_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
    $Arg6: typeid,
    $Arg7: typeid,
    $Arg8: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
        arg6: Arg6,
        arg7: Arg7,
        arg8: Arg8,
    )
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
            (cast(^Arg6)args[6])^,
            (cast(^Arg7)args[7])^,
            (cast(^Arg8)args[8])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
            godot.variant_type(Arg6),
            godot.variant_type(Arg7),
            godot.variant_type(Arg8),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        arg6 := godot.variant_to(cast(^godot.Variant)args[6], Arg6)
        arg7 := godot.variant_to(cast(^godot.Variant)args[7], Arg7)
        arg8 := godot.variant_to(cast(^godot.Variant)args[8], Arg8)
        method := cast(Proc)data
        method(cast(^Self)instance, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    }
    return ptrcall, call
}

get_returning_calls_9_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
    $Arg6: typeid,
    $Arg7: typeid,
    $Arg8: typeid,
    $Ret: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
        arg6: Arg6,
        arg7: Arg7,
        arg8: Arg8,
    ) -> Ret
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        (cast(^Ret)ret)^ = method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
            (cast(^Arg6)args[6])^,
            (cast(^Arg7)args[7])^,
            (cast(^Arg8)args[8])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
            godot.variant_type(Arg6),
            godot.variant_type(Arg7),
            godot.variant_type(Arg8),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        arg6 := godot.variant_to(cast(^godot.Variant)args[6], Arg6)
        arg7 := godot.variant_to(cast(^godot.Variant)args[7], Arg7)
        arg8 := godot.variant_to(cast(^godot.Variant)args[8], Arg8)
        method := cast(Proc)data
        result := method(cast(^Self)instance, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)

        godot.variant_into_ptr(&result, cast(^godot.Variant)ret)
    }
    return ptrcall, call
}

bind_void_method_9_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
        arg6: $Arg6,
        arg7: $Arg7,
        arg8: $Arg8,
    ),
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
    arg6_name: ^godot.String_Name,
    arg7_name: ^godot.String_Name,
    arg8_name: ^godot.String_Name,
) {
    args_info := [9]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
        simple_property_info(godot.variant_type(Arg6), arg6_name),
        simple_property_info(godot.variant_type(Arg7), arg7_name),
        simple_property_info(godot.variant_type(Arg8), arg8_name),
    }
    args_metadata := [9]gd.ExtensionClassMethodArgumentMetadata {
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
    }

    ptrcall, call := get_void_calls(Self, Arg0, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = false,
        return_value_metadata  = .None,
        argument_count         = 9,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

bind_returning_method_9_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
        arg6: $Arg6,
        arg7: $Arg7,
        arg8: $Arg8,
    ) -> $Ret,
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
    arg6_name: ^godot.String_Name,
    arg7_name: ^godot.String_Name,
    arg8_name: ^godot.String_Name,
) {
    args_info := [9]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
        simple_property_info(godot.variant_type(Arg6), arg6_name),
        simple_property_info(godot.variant_type(Arg7), arg7_name),
        simple_property_info(godot.variant_type(Arg8), arg8_name),
    }
    args_metadata := [9]gd.ExtensionClassMethodArgumentMetadata {
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
    }

    return_info := simple_property_info(godot.variant_type(Ret), godot.string_name_empty_ref())

    ptrcall, call := get_returning_calls(Self, Arg0, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Ret)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = true,
        return_value_info      = &return_info,
        return_value_metadata  = .None,
        argument_count         = 9,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

get_void_calls_10_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
    $Arg6: typeid,
    $Arg7: typeid,
    $Arg8: typeid,
    $Arg9: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
        arg6: Arg6,
        arg7: Arg7,
        arg8: Arg8,
        arg9: Arg9,
    )
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
            (cast(^Arg6)args[6])^,
            (cast(^Arg7)args[7])^,
            (cast(^Arg8)args[8])^,
            (cast(^Arg9)args[9])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
            godot.variant_type(Arg6),
            godot.variant_type(Arg7),
            godot.variant_type(Arg8),
            godot.variant_type(Arg9),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        arg6 := godot.variant_to(cast(^godot.Variant)args[6], Arg6)
        arg7 := godot.variant_to(cast(^godot.Variant)args[7], Arg7)
        arg8 := godot.variant_to(cast(^godot.Variant)args[8], Arg8)
        arg9 := godot.variant_to(cast(^godot.Variant)args[9], Arg9)
        method := cast(Proc)data
        method(cast(^Self)instance, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    }
    return ptrcall, call
}

get_returning_calls_10_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
    $Arg6: typeid,
    $Arg7: typeid,
    $Arg8: typeid,
    $Arg9: typeid,
    $Ret: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
        arg6: Arg6,
        arg7: Arg7,
        arg8: Arg8,
        arg9: Arg9,
    ) -> Ret
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        (cast(^Ret)ret)^ = method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
            (cast(^Arg6)args[6])^,
            (cast(^Arg7)args[7])^,
            (cast(^Arg8)args[8])^,
            (cast(^Arg9)args[9])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
            godot.variant_type(Arg6),
            godot.variant_type(Arg7),
            godot.variant_type(Arg8),
            godot.variant_type(Arg9),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        arg6 := godot.variant_to(cast(^godot.Variant)args[6], Arg6)
        arg7 := godot.variant_to(cast(^godot.Variant)args[7], Arg7)
        arg8 := godot.variant_to(cast(^godot.Variant)args[8], Arg8)
        arg9 := godot.variant_to(cast(^godot.Variant)args[9], Arg9)
        method := cast(Proc)data
        result := method(cast(^Self)instance, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)

        godot.variant_into_ptr(&result, cast(^godot.Variant)ret)
    }
    return ptrcall, call
}

bind_void_method_10_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
        arg6: $Arg6,
        arg7: $Arg7,
        arg8: $Arg8,
        arg9: $Arg9,
    ),
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
    arg6_name: ^godot.String_Name,
    arg7_name: ^godot.String_Name,
    arg8_name: ^godot.String_Name,
    arg9_name: ^godot.String_Name,
) {
    args_info := [10]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
        simple_property_info(godot.variant_type(Arg6), arg6_name),
        simple_property_info(godot.variant_type(Arg7), arg7_name),
        simple_property_info(godot.variant_type(Arg8), arg8_name),
        simple_property_info(godot.variant_type(Arg9), arg9_name),
    }
    args_metadata := [10]gd.ExtensionClassMethodArgumentMetadata {
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
    }

    ptrcall, call := get_void_calls(Self, Arg0, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = false,
        return_value_metadata  = .None,
        argument_count         = 10,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

bind_returning_method_10_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
        arg6: $Arg6,
        arg7: $Arg7,
        arg8: $Arg8,
        arg9: $Arg9,
    ) -> $Ret,
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
    arg6_name: ^godot.String_Name,
    arg7_name: ^godot.String_Name,
    arg8_name: ^godot.String_Name,
    arg9_name: ^godot.String_Name,
) {
    args_info := [10]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
        simple_property_info(godot.variant_type(Arg6), arg6_name),
        simple_property_info(godot.variant_type(Arg7), arg7_name),
        simple_property_info(godot.variant_type(Arg8), arg8_name),
        simple_property_info(godot.variant_type(Arg9), arg9_name),
    }
    args_metadata := [10]gd.ExtensionClassMethodArgumentMetadata {
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
    }

    return_info := simple_property_info(godot.variant_type(Ret), godot.string_name_empty_ref())

    ptrcall, call := get_returning_calls(Self, Arg0, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Ret)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = true,
        return_value_info      = &return_info,
        return_value_metadata  = .None,
        argument_count         = 10,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

get_void_calls_11_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
    $Arg6: typeid,
    $Arg7: typeid,
    $Arg8: typeid,
    $Arg9: typeid,
    $Arg10: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
        arg6: Arg6,
        arg7: Arg7,
        arg8: Arg8,
        arg9: Arg9,
        arg10: Arg10,
    )
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
            (cast(^Arg6)args[6])^,
            (cast(^Arg7)args[7])^,
            (cast(^Arg8)args[8])^,
            (cast(^Arg9)args[9])^,
            (cast(^Arg10)args[10])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
            godot.variant_type(Arg6),
            godot.variant_type(Arg7),
            godot.variant_type(Arg8),
            godot.variant_type(Arg9),
            godot.variant_type(Arg10),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        arg6 := godot.variant_to(cast(^godot.Variant)args[6], Arg6)
        arg7 := godot.variant_to(cast(^godot.Variant)args[7], Arg7)
        arg8 := godot.variant_to(cast(^godot.Variant)args[8], Arg8)
        arg9 := godot.variant_to(cast(^godot.Variant)args[9], Arg9)
        arg10 := godot.variant_to(cast(^godot.Variant)args[10], Arg10)
        method := cast(Proc)data
        method(cast(^Self)instance, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    }
    return ptrcall, call
}

get_returning_calls_11_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
    $Arg6: typeid,
    $Arg7: typeid,
    $Arg8: typeid,
    $Arg9: typeid,
    $Arg10: typeid,
    $Ret: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
        arg6: Arg6,
        arg7: Arg7,
        arg8: Arg8,
        arg9: Arg9,
        arg10: Arg10,
    ) -> Ret
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        (cast(^Ret)ret)^ = method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
            (cast(^Arg6)args[6])^,
            (cast(^Arg7)args[7])^,
            (cast(^Arg8)args[8])^,
            (cast(^Arg9)args[9])^,
            (cast(^Arg10)args[10])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
            godot.variant_type(Arg6),
            godot.variant_type(Arg7),
            godot.variant_type(Arg8),
            godot.variant_type(Arg9),
            godot.variant_type(Arg10),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        arg6 := godot.variant_to(cast(^godot.Variant)args[6], Arg6)
        arg7 := godot.variant_to(cast(^godot.Variant)args[7], Arg7)
        arg8 := godot.variant_to(cast(^godot.Variant)args[8], Arg8)
        arg9 := godot.variant_to(cast(^godot.Variant)args[9], Arg9)
        arg10 := godot.variant_to(cast(^godot.Variant)args[10], Arg10)
        method := cast(Proc)data
        result := method(cast(^Self)instance, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)

        godot.variant_into_ptr(&result, cast(^godot.Variant)ret)
    }
    return ptrcall, call
}

bind_void_method_11_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
        arg6: $Arg6,
        arg7: $Arg7,
        arg8: $Arg8,
        arg9: $Arg9,
        arg10: $Arg10,
    ),
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
    arg6_name: ^godot.String_Name,
    arg7_name: ^godot.String_Name,
    arg8_name: ^godot.String_Name,
    arg9_name: ^godot.String_Name,
    arg10_name: ^godot.String_Name,
) {
    args_info := [11]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
        simple_property_info(godot.variant_type(Arg6), arg6_name),
        simple_property_info(godot.variant_type(Arg7), arg7_name),
        simple_property_info(godot.variant_type(Arg8), arg8_name),
        simple_property_info(godot.variant_type(Arg9), arg9_name),
        simple_property_info(godot.variant_type(Arg10), arg10_name),
    }
    args_metadata := [11]gd.ExtensionClassMethodArgumentMetadata {
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
    }

    ptrcall, call := get_void_calls(Self, Arg0, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = false,
        return_value_metadata  = .None,
        argument_count         = 11,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

bind_returning_method_11_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
        arg6: $Arg6,
        arg7: $Arg7,
        arg8: $Arg8,
        arg9: $Arg9,
        arg10: $Arg10,
    ) -> $Ret,
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
    arg6_name: ^godot.String_Name,
    arg7_name: ^godot.String_Name,
    arg8_name: ^godot.String_Name,
    arg9_name: ^godot.String_Name,
    arg10_name: ^godot.String_Name,
) {
    args_info := [11]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
        simple_property_info(godot.variant_type(Arg6), arg6_name),
        simple_property_info(godot.variant_type(Arg7), arg7_name),
        simple_property_info(godot.variant_type(Arg8), arg8_name),
        simple_property_info(godot.variant_type(Arg9), arg9_name),
        simple_property_info(godot.variant_type(Arg10), arg10_name),
    }
    args_metadata := [11]gd.ExtensionClassMethodArgumentMetadata {
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
    }

    return_info := simple_property_info(godot.variant_type(Ret), godot.string_name_empty_ref())

    ptrcall, call := get_returning_calls(Self, Arg0, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10, Ret)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = true,
        return_value_info      = &return_info,
        return_value_metadata  = .None,
        argument_count         = 11,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

get_void_calls_12_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
    $Arg6: typeid,
    $Arg7: typeid,
    $Arg8: typeid,
    $Arg9: typeid,
    $Arg10: typeid,
    $Arg11: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
        arg6: Arg6,
        arg7: Arg7,
        arg8: Arg8,
        arg9: Arg9,
        arg10: Arg10,
        arg11: Arg11,
    )
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
            (cast(^Arg6)args[6])^,
            (cast(^Arg7)args[7])^,
            (cast(^Arg8)args[8])^,
            (cast(^Arg9)args[9])^,
            (cast(^Arg10)args[10])^,
            (cast(^Arg11)args[11])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
            godot.variant_type(Arg6),
            godot.variant_type(Arg7),
            godot.variant_type(Arg8),
            godot.variant_type(Arg9),
            godot.variant_type(Arg10),
            godot.variant_type(Arg11),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        arg6 := godot.variant_to(cast(^godot.Variant)args[6], Arg6)
        arg7 := godot.variant_to(cast(^godot.Variant)args[7], Arg7)
        arg8 := godot.variant_to(cast(^godot.Variant)args[8], Arg8)
        arg9 := godot.variant_to(cast(^godot.Variant)args[9], Arg9)
        arg10 := godot.variant_to(cast(^godot.Variant)args[10], Arg10)
        arg11 := godot.variant_to(cast(^godot.Variant)args[11], Arg11)
        method := cast(Proc)data
        method(cast(^Self)instance, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
    }
    return ptrcall, call
}

get_returning_calls_12_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
    $Arg6: typeid,
    $Arg7: typeid,
    $Arg8: typeid,
    $Arg9: typeid,
    $Arg10: typeid,
    $Arg11: typeid,
    $Ret: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
        arg6: Arg6,
        arg7: Arg7,
        arg8: Arg8,
        arg9: Arg9,
        arg10: Arg10,
        arg11: Arg11,
    ) -> Ret
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        (cast(^Ret)ret)^ = method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
            (cast(^Arg6)args[6])^,
            (cast(^Arg7)args[7])^,
            (cast(^Arg8)args[8])^,
            (cast(^Arg9)args[9])^,
            (cast(^Arg10)args[10])^,
            (cast(^Arg11)args[11])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
            godot.variant_type(Arg6),
            godot.variant_type(Arg7),
            godot.variant_type(Arg8),
            godot.variant_type(Arg9),
            godot.variant_type(Arg10),
            godot.variant_type(Arg11),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        arg6 := godot.variant_to(cast(^godot.Variant)args[6], Arg6)
        arg7 := godot.variant_to(cast(^godot.Variant)args[7], Arg7)
        arg8 := godot.variant_to(cast(^godot.Variant)args[8], Arg8)
        arg9 := godot.variant_to(cast(^godot.Variant)args[9], Arg9)
        arg10 := godot.variant_to(cast(^godot.Variant)args[10], Arg10)
        arg11 := godot.variant_to(cast(^godot.Variant)args[11], Arg11)
        method := cast(Proc)data
        result := method(cast(^Self)instance, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)

        godot.variant_into_ptr(&result, cast(^godot.Variant)ret)
    }
    return ptrcall, call
}

bind_void_method_12_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
        arg6: $Arg6,
        arg7: $Arg7,
        arg8: $Arg8,
        arg9: $Arg9,
        arg10: $Arg10,
        arg11: $Arg11,
    ),
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
    arg6_name: ^godot.String_Name,
    arg7_name: ^godot.String_Name,
    arg8_name: ^godot.String_Name,
    arg9_name: ^godot.String_Name,
    arg10_name: ^godot.String_Name,
    arg11_name: ^godot.String_Name,
) {
    args_info := [12]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
        simple_property_info(godot.variant_type(Arg6), arg6_name),
        simple_property_info(godot.variant_type(Arg7), arg7_name),
        simple_property_info(godot.variant_type(Arg8), arg8_name),
        simple_property_info(godot.variant_type(Arg9), arg9_name),
        simple_property_info(godot.variant_type(Arg10), arg10_name),
        simple_property_info(godot.variant_type(Arg11), arg11_name),
    }
    args_metadata := [12]gd.ExtensionClassMethodArgumentMetadata {
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
    }

    ptrcall, call := get_void_calls(Self, Arg0, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10, Arg11)
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = false,
        return_value_metadata  = .None,
        argument_count         = 12,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

bind_returning_method_12_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
        arg6: $Arg6,
        arg7: $Arg7,
        arg8: $Arg8,
        arg9: $Arg9,
        arg10: $Arg10,
        arg11: $Arg11,
    ) -> $Ret,
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
    arg6_name: ^godot.String_Name,
    arg7_name: ^godot.String_Name,
    arg8_name: ^godot.String_Name,
    arg9_name: ^godot.String_Name,
    arg10_name: ^godot.String_Name,
    arg11_name: ^godot.String_Name,
) {
    args_info := [12]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
        simple_property_info(godot.variant_type(Arg6), arg6_name),
        simple_property_info(godot.variant_type(Arg7), arg7_name),
        simple_property_info(godot.variant_type(Arg8), arg8_name),
        simple_property_info(godot.variant_type(Arg9), arg9_name),
        simple_property_info(godot.variant_type(Arg10), arg10_name),
        simple_property_info(godot.variant_type(Arg11), arg11_name),
    }
    args_metadata := [12]gd.ExtensionClassMethodArgumentMetadata {
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
    }

    return_info := simple_property_info(godot.variant_type(Ret), godot.string_name_empty_ref())

    ptrcall, call := get_returning_calls(
        Self,
        Arg0,
        Arg1,
        Arg2,
        Arg3,
        Arg4,
        Arg5,
        Arg6,
        Arg7,
        Arg8,
        Arg9,
        Arg10,
        Arg11,
        Ret,
    )
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = true,
        return_value_info      = &return_info,
        return_value_metadata  = .None,
        argument_count         = 12,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

get_void_calls_13_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
    $Arg6: typeid,
    $Arg7: typeid,
    $Arg8: typeid,
    $Arg9: typeid,
    $Arg10: typeid,
    $Arg11: typeid,
    $Arg12: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
        arg6: Arg6,
        arg7: Arg7,
        arg8: Arg8,
        arg9: Arg9,
        arg10: Arg10,
        arg11: Arg11,
        arg12: Arg12,
    )
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
            (cast(^Arg6)args[6])^,
            (cast(^Arg7)args[7])^,
            (cast(^Arg8)args[8])^,
            (cast(^Arg9)args[9])^,
            (cast(^Arg10)args[10])^,
            (cast(^Arg11)args[11])^,
            (cast(^Arg12)args[12])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
            godot.variant_type(Arg6),
            godot.variant_type(Arg7),
            godot.variant_type(Arg8),
            godot.variant_type(Arg9),
            godot.variant_type(Arg10),
            godot.variant_type(Arg11),
            godot.variant_type(Arg12),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        arg6 := godot.variant_to(cast(^godot.Variant)args[6], Arg6)
        arg7 := godot.variant_to(cast(^godot.Variant)args[7], Arg7)
        arg8 := godot.variant_to(cast(^godot.Variant)args[8], Arg8)
        arg9 := godot.variant_to(cast(^godot.Variant)args[9], Arg9)
        arg10 := godot.variant_to(cast(^godot.Variant)args[10], Arg10)
        arg11 := godot.variant_to(cast(^godot.Variant)args[11], Arg11)
        arg12 := godot.variant_to(cast(^godot.Variant)args[12], Arg12)
        method := cast(Proc)data
        method(cast(^Self)instance, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)
    }
    return ptrcall, call
}

get_returning_calls_13_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
    $Arg6: typeid,
    $Arg7: typeid,
    $Arg8: typeid,
    $Arg9: typeid,
    $Arg10: typeid,
    $Arg11: typeid,
    $Arg12: typeid,
    $Ret: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
        arg6: Arg6,
        arg7: Arg7,
        arg8: Arg8,
        arg9: Arg9,
        arg10: Arg10,
        arg11: Arg11,
        arg12: Arg12,
    ) -> Ret
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        (cast(^Ret)ret)^ = method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
            (cast(^Arg6)args[6])^,
            (cast(^Arg7)args[7])^,
            (cast(^Arg8)args[8])^,
            (cast(^Arg9)args[9])^,
            (cast(^Arg10)args[10])^,
            (cast(^Arg11)args[11])^,
            (cast(^Arg12)args[12])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
            godot.variant_type(Arg6),
            godot.variant_type(Arg7),
            godot.variant_type(Arg8),
            godot.variant_type(Arg9),
            godot.variant_type(Arg10),
            godot.variant_type(Arg11),
            godot.variant_type(Arg12),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        arg6 := godot.variant_to(cast(^godot.Variant)args[6], Arg6)
        arg7 := godot.variant_to(cast(^godot.Variant)args[7], Arg7)
        arg8 := godot.variant_to(cast(^godot.Variant)args[8], Arg8)
        arg9 := godot.variant_to(cast(^godot.Variant)args[9], Arg9)
        arg10 := godot.variant_to(cast(^godot.Variant)args[10], Arg10)
        arg11 := godot.variant_to(cast(^godot.Variant)args[11], Arg11)
        arg12 := godot.variant_to(cast(^godot.Variant)args[12], Arg12)
        method := cast(Proc)data
        result := method(
            cast(^Self)instance,
            arg0,
            arg1,
            arg2,
            arg3,
            arg4,
            arg5,
            arg6,
            arg7,
            arg8,
            arg9,
            arg10,
            arg11,
            arg12,
        )

        godot.variant_into_ptr(&result, cast(^godot.Variant)ret)
    }
    return ptrcall, call
}

bind_void_method_13_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
        arg6: $Arg6,
        arg7: $Arg7,
        arg8: $Arg8,
        arg9: $Arg9,
        arg10: $Arg10,
        arg11: $Arg11,
        arg12: $Arg12,
    ),
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
    arg6_name: ^godot.String_Name,
    arg7_name: ^godot.String_Name,
    arg8_name: ^godot.String_Name,
    arg9_name: ^godot.String_Name,
    arg10_name: ^godot.String_Name,
    arg11_name: ^godot.String_Name,
    arg12_name: ^godot.String_Name,
) {
    args_info := [13]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
        simple_property_info(godot.variant_type(Arg6), arg6_name),
        simple_property_info(godot.variant_type(Arg7), arg7_name),
        simple_property_info(godot.variant_type(Arg8), arg8_name),
        simple_property_info(godot.variant_type(Arg9), arg9_name),
        simple_property_info(godot.variant_type(Arg10), arg10_name),
        simple_property_info(godot.variant_type(Arg11), arg11_name),
        simple_property_info(godot.variant_type(Arg12), arg12_name),
    }
    args_metadata := [13]gd.ExtensionClassMethodArgumentMetadata {
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
    }

    ptrcall, call := get_void_calls(
        Self,
        Arg0,
        Arg1,
        Arg2,
        Arg3,
        Arg4,
        Arg5,
        Arg6,
        Arg7,
        Arg8,
        Arg9,
        Arg10,
        Arg11,
        Arg12,
    )
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = false,
        return_value_metadata  = .None,
        argument_count         = 13,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

bind_returning_method_13_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
        arg6: $Arg6,
        arg7: $Arg7,
        arg8: $Arg8,
        arg9: $Arg9,
        arg10: $Arg10,
        arg11: $Arg11,
        arg12: $Arg12,
    ) -> $Ret,
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
    arg6_name: ^godot.String_Name,
    arg7_name: ^godot.String_Name,
    arg8_name: ^godot.String_Name,
    arg9_name: ^godot.String_Name,
    arg10_name: ^godot.String_Name,
    arg11_name: ^godot.String_Name,
    arg12_name: ^godot.String_Name,
) {
    args_info := [13]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
        simple_property_info(godot.variant_type(Arg6), arg6_name),
        simple_property_info(godot.variant_type(Arg7), arg7_name),
        simple_property_info(godot.variant_type(Arg8), arg8_name),
        simple_property_info(godot.variant_type(Arg9), arg9_name),
        simple_property_info(godot.variant_type(Arg10), arg10_name),
        simple_property_info(godot.variant_type(Arg11), arg11_name),
        simple_property_info(godot.variant_type(Arg12), arg12_name),
    }
    args_metadata := [13]gd.ExtensionClassMethodArgumentMetadata {
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
    }

    return_info := simple_property_info(godot.variant_type(Ret), godot.string_name_empty_ref())

    ptrcall, call := get_returning_calls(
        Self,
        Arg0,
        Arg1,
        Arg2,
        Arg3,
        Arg4,
        Arg5,
        Arg6,
        Arg7,
        Arg8,
        Arg9,
        Arg10,
        Arg11,
        Arg12,
        Ret,
    )
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = true,
        return_value_info      = &return_info,
        return_value_metadata  = .None,
        argument_count         = 13,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

get_void_calls_14_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
    $Arg6: typeid,
    $Arg7: typeid,
    $Arg8: typeid,
    $Arg9: typeid,
    $Arg10: typeid,
    $Arg11: typeid,
    $Arg12: typeid,
    $Arg13: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
        arg6: Arg6,
        arg7: Arg7,
        arg8: Arg8,
        arg9: Arg9,
        arg10: Arg10,
        arg11: Arg11,
        arg12: Arg12,
        arg13: Arg13,
    )
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
            (cast(^Arg6)args[6])^,
            (cast(^Arg7)args[7])^,
            (cast(^Arg8)args[8])^,
            (cast(^Arg9)args[9])^,
            (cast(^Arg10)args[10])^,
            (cast(^Arg11)args[11])^,
            (cast(^Arg12)args[12])^,
            (cast(^Arg13)args[13])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
            godot.variant_type(Arg6),
            godot.variant_type(Arg7),
            godot.variant_type(Arg8),
            godot.variant_type(Arg9),
            godot.variant_type(Arg10),
            godot.variant_type(Arg11),
            godot.variant_type(Arg12),
            godot.variant_type(Arg13),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        arg6 := godot.variant_to(cast(^godot.Variant)args[6], Arg6)
        arg7 := godot.variant_to(cast(^godot.Variant)args[7], Arg7)
        arg8 := godot.variant_to(cast(^godot.Variant)args[8], Arg8)
        arg9 := godot.variant_to(cast(^godot.Variant)args[9], Arg9)
        arg10 := godot.variant_to(cast(^godot.Variant)args[10], Arg10)
        arg11 := godot.variant_to(cast(^godot.Variant)args[11], Arg11)
        arg12 := godot.variant_to(cast(^godot.Variant)args[12], Arg12)
        arg13 := godot.variant_to(cast(^godot.Variant)args[13], Arg13)
        method := cast(Proc)data
        method(
            cast(^Self)instance,
            arg0,
            arg1,
            arg2,
            arg3,
            arg4,
            arg5,
            arg6,
            arg7,
            arg8,
            arg9,
            arg10,
            arg11,
            arg12,
            arg13,
        )
    }
    return ptrcall, call
}

get_returning_calls_14_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
    $Arg6: typeid,
    $Arg7: typeid,
    $Arg8: typeid,
    $Arg9: typeid,
    $Arg10: typeid,
    $Arg11: typeid,
    $Arg12: typeid,
    $Arg13: typeid,
    $Ret: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
        arg6: Arg6,
        arg7: Arg7,
        arg8: Arg8,
        arg9: Arg9,
        arg10: Arg10,
        arg11: Arg11,
        arg12: Arg12,
        arg13: Arg13,
    ) -> Ret
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        (cast(^Ret)ret)^ = method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
            (cast(^Arg6)args[6])^,
            (cast(^Arg7)args[7])^,
            (cast(^Arg8)args[8])^,
            (cast(^Arg9)args[9])^,
            (cast(^Arg10)args[10])^,
            (cast(^Arg11)args[11])^,
            (cast(^Arg12)args[12])^,
            (cast(^Arg13)args[13])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
            godot.variant_type(Arg6),
            godot.variant_type(Arg7),
            godot.variant_type(Arg8),
            godot.variant_type(Arg9),
            godot.variant_type(Arg10),
            godot.variant_type(Arg11),
            godot.variant_type(Arg12),
            godot.variant_type(Arg13),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        arg6 := godot.variant_to(cast(^godot.Variant)args[6], Arg6)
        arg7 := godot.variant_to(cast(^godot.Variant)args[7], Arg7)
        arg8 := godot.variant_to(cast(^godot.Variant)args[8], Arg8)
        arg9 := godot.variant_to(cast(^godot.Variant)args[9], Arg9)
        arg10 := godot.variant_to(cast(^godot.Variant)args[10], Arg10)
        arg11 := godot.variant_to(cast(^godot.Variant)args[11], Arg11)
        arg12 := godot.variant_to(cast(^godot.Variant)args[12], Arg12)
        arg13 := godot.variant_to(cast(^godot.Variant)args[13], Arg13)
        method := cast(Proc)data
        result := method(
            cast(^Self)instance,
            arg0,
            arg1,
            arg2,
            arg3,
            arg4,
            arg5,
            arg6,
            arg7,
            arg8,
            arg9,
            arg10,
            arg11,
            arg12,
            arg13,
        )

        godot.variant_into_ptr(&result, cast(^godot.Variant)ret)
    }
    return ptrcall, call
}

bind_void_method_14_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
        arg6: $Arg6,
        arg7: $Arg7,
        arg8: $Arg8,
        arg9: $Arg9,
        arg10: $Arg10,
        arg11: $Arg11,
        arg12: $Arg12,
        arg13: $Arg13,
    ),
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
    arg6_name: ^godot.String_Name,
    arg7_name: ^godot.String_Name,
    arg8_name: ^godot.String_Name,
    arg9_name: ^godot.String_Name,
    arg10_name: ^godot.String_Name,
    arg11_name: ^godot.String_Name,
    arg12_name: ^godot.String_Name,
    arg13_name: ^godot.String_Name,
) {
    args_info := [14]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
        simple_property_info(godot.variant_type(Arg6), arg6_name),
        simple_property_info(godot.variant_type(Arg7), arg7_name),
        simple_property_info(godot.variant_type(Arg8), arg8_name),
        simple_property_info(godot.variant_type(Arg9), arg9_name),
        simple_property_info(godot.variant_type(Arg10), arg10_name),
        simple_property_info(godot.variant_type(Arg11), arg11_name),
        simple_property_info(godot.variant_type(Arg12), arg12_name),
        simple_property_info(godot.variant_type(Arg13), arg13_name),
    }
    args_metadata := [14]gd.ExtensionClassMethodArgumentMetadata {
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
    }

    ptrcall, call := get_void_calls(
        Self,
        Arg0,
        Arg1,
        Arg2,
        Arg3,
        Arg4,
        Arg5,
        Arg6,
        Arg7,
        Arg8,
        Arg9,
        Arg10,
        Arg11,
        Arg12,
        Arg13,
    )
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = false,
        return_value_metadata  = .None,
        argument_count         = 14,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

bind_returning_method_14_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
        arg6: $Arg6,
        arg7: $Arg7,
        arg8: $Arg8,
        arg9: $Arg9,
        arg10: $Arg10,
        arg11: $Arg11,
        arg12: $Arg12,
        arg13: $Arg13,
    ) -> $Ret,
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
    arg6_name: ^godot.String_Name,
    arg7_name: ^godot.String_Name,
    arg8_name: ^godot.String_Name,
    arg9_name: ^godot.String_Name,
    arg10_name: ^godot.String_Name,
    arg11_name: ^godot.String_Name,
    arg12_name: ^godot.String_Name,
    arg13_name: ^godot.String_Name,
) {
    args_info := [14]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
        simple_property_info(godot.variant_type(Arg6), arg6_name),
        simple_property_info(godot.variant_type(Arg7), arg7_name),
        simple_property_info(godot.variant_type(Arg8), arg8_name),
        simple_property_info(godot.variant_type(Arg9), arg9_name),
        simple_property_info(godot.variant_type(Arg10), arg10_name),
        simple_property_info(godot.variant_type(Arg11), arg11_name),
        simple_property_info(godot.variant_type(Arg12), arg12_name),
        simple_property_info(godot.variant_type(Arg13), arg13_name),
    }
    args_metadata := [14]gd.ExtensionClassMethodArgumentMetadata {
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
    }

    return_info := simple_property_info(godot.variant_type(Ret), godot.string_name_empty_ref())

    ptrcall, call := get_returning_calls(
        Self,
        Arg0,
        Arg1,
        Arg2,
        Arg3,
        Arg4,
        Arg5,
        Arg6,
        Arg7,
        Arg8,
        Arg9,
        Arg10,
        Arg11,
        Arg12,
        Arg13,
        Ret,
    )
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = true,
        return_value_info      = &return_info,
        return_value_metadata  = .None,
        argument_count         = 14,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

get_void_calls_15_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
    $Arg6: typeid,
    $Arg7: typeid,
    $Arg8: typeid,
    $Arg9: typeid,
    $Arg10: typeid,
    $Arg11: typeid,
    $Arg12: typeid,
    $Arg13: typeid,
    $Arg14: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
        arg6: Arg6,
        arg7: Arg7,
        arg8: Arg8,
        arg9: Arg9,
        arg10: Arg10,
        arg11: Arg11,
        arg12: Arg12,
        arg13: Arg13,
        arg14: Arg14,
    )
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
            (cast(^Arg6)args[6])^,
            (cast(^Arg7)args[7])^,
            (cast(^Arg8)args[8])^,
            (cast(^Arg9)args[9])^,
            (cast(^Arg10)args[10])^,
            (cast(^Arg11)args[11])^,
            (cast(^Arg12)args[12])^,
            (cast(^Arg13)args[13])^,
            (cast(^Arg14)args[14])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
            godot.variant_type(Arg6),
            godot.variant_type(Arg7),
            godot.variant_type(Arg8),
            godot.variant_type(Arg9),
            godot.variant_type(Arg10),
            godot.variant_type(Arg11),
            godot.variant_type(Arg12),
            godot.variant_type(Arg13),
            godot.variant_type(Arg14),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        arg6 := godot.variant_to(cast(^godot.Variant)args[6], Arg6)
        arg7 := godot.variant_to(cast(^godot.Variant)args[7], Arg7)
        arg8 := godot.variant_to(cast(^godot.Variant)args[8], Arg8)
        arg9 := godot.variant_to(cast(^godot.Variant)args[9], Arg9)
        arg10 := godot.variant_to(cast(^godot.Variant)args[10], Arg10)
        arg11 := godot.variant_to(cast(^godot.Variant)args[11], Arg11)
        arg12 := godot.variant_to(cast(^godot.Variant)args[12], Arg12)
        arg13 := godot.variant_to(cast(^godot.Variant)args[13], Arg13)
        arg14 := godot.variant_to(cast(^godot.Variant)args[14], Arg14)
        method := cast(Proc)data
        method(
            cast(^Self)instance,
            arg0,
            arg1,
            arg2,
            arg3,
            arg4,
            arg5,
            arg6,
            arg7,
            arg8,
            arg9,
            arg10,
            arg11,
            arg12,
            arg13,
            arg14,
        )
    }
    return ptrcall, call
}

get_returning_calls_15_args :: proc "contextless" (
    $Self: typeid,
    $Arg0: typeid,
    $Arg1: typeid,
    $Arg2: typeid,
    $Arg3: typeid,
    $Arg4: typeid,
    $Arg5: typeid,
    $Arg6: typeid,
    $Arg7: typeid,
    $Arg8: typeid,
    $Arg9: typeid,
    $Arg10: typeid,
    $Arg11: typeid,
    $Arg12: typeid,
    $Arg13: typeid,
    $Arg14: typeid,
    $Ret: typeid,
) -> (
    gd.ExtensionClassMethodPtrCall,
    gd.ExtensionClassMethodCall,
) {
    Proc :: #type proc "contextless" (
        self: ^Self,
        arg0: Arg0,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        arg4: Arg4,
        arg5: Arg5,
        arg6: Arg6,
        arg7: Arg7,
        arg8: Arg8,
        arg9: Arg9,
        arg10: Arg10,
        arg11: Arg11,
        arg12: Arg12,
        arg13: Arg13,
        arg14: Arg14,
    ) -> Ret
    ptrcall :: proc "c" (data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
        context = gd.godot_context()

        method := cast(Proc)data
        (cast(^Ret)ret)^ = method(
            cast(^Self)instance,
            (cast(^Arg0)args[0])^,
            (cast(^Arg1)args[1])^,
            (cast(^Arg2)args[2])^,
            (cast(^Arg3)args[3])^,
            (cast(^Arg4)args[4])^,
            (cast(^Arg5)args[5])^,
            (cast(^Arg6)args[6])^,
            (cast(^Arg7)args[7])^,
            (cast(^Arg8)args[8])^,
            (cast(^Arg9)args[9])^,
            (cast(^Arg10)args[10])^,
            (cast(^Arg11)args[11])^,
            (cast(^Arg12)args[12])^,
            (cast(^Arg13)args[13])^,
            (cast(^Arg14)args[14])^,
        )
    }
    call :: proc "c" (
        data: rawptr,
        instance: gd.ExtensionClassInstancePtr,
        args: [^]gd.VariantPtr,
        arg_count: i64,
        ret: gd.VariantPtr,
        error: ^gd.CallError,
    ) {
        if !expect_args(
            args,
            arg_count,
            error,
            godot.variant_type(Arg0),
            godot.variant_type(Arg1),
            godot.variant_type(Arg2),
            godot.variant_type(Arg3),
            godot.variant_type(Arg4),
            godot.variant_type(Arg5),
            godot.variant_type(Arg6),
            godot.variant_type(Arg7),
            godot.variant_type(Arg8),
            godot.variant_type(Arg9),
            godot.variant_type(Arg10),
            godot.variant_type(Arg11),
            godot.variant_type(Arg12),
            godot.variant_type(Arg13),
            godot.variant_type(Arg14),
        ) {
            return
        }

        context = gd.godot_context()

        arg0 := godot.variant_to(cast(^godot.Variant)args[0], Arg0)
        arg1 := godot.variant_to(cast(^godot.Variant)args[1], Arg1)
        arg2 := godot.variant_to(cast(^godot.Variant)args[2], Arg2)
        arg3 := godot.variant_to(cast(^godot.Variant)args[3], Arg3)
        arg4 := godot.variant_to(cast(^godot.Variant)args[4], Arg4)
        arg5 := godot.variant_to(cast(^godot.Variant)args[5], Arg5)
        arg6 := godot.variant_to(cast(^godot.Variant)args[6], Arg6)
        arg7 := godot.variant_to(cast(^godot.Variant)args[7], Arg7)
        arg8 := godot.variant_to(cast(^godot.Variant)args[8], Arg8)
        arg9 := godot.variant_to(cast(^godot.Variant)args[9], Arg9)
        arg10 := godot.variant_to(cast(^godot.Variant)args[10], Arg10)
        arg11 := godot.variant_to(cast(^godot.Variant)args[11], Arg11)
        arg12 := godot.variant_to(cast(^godot.Variant)args[12], Arg12)
        arg13 := godot.variant_to(cast(^godot.Variant)args[13], Arg13)
        arg14 := godot.variant_to(cast(^godot.Variant)args[14], Arg14)
        method := cast(Proc)data
        result := method(
            cast(^Self)instance,
            arg0,
            arg1,
            arg2,
            arg3,
            arg4,
            arg5,
            arg6,
            arg7,
            arg8,
            arg9,
            arg10,
            arg11,
            arg12,
            arg13,
            arg14,
        )

        godot.variant_into_ptr(&result, cast(^godot.Variant)ret)
    }
    return ptrcall, call
}

bind_void_method_15_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
        arg6: $Arg6,
        arg7: $Arg7,
        arg8: $Arg8,
        arg9: $Arg9,
        arg10: $Arg10,
        arg11: $Arg11,
        arg12: $Arg12,
        arg13: $Arg13,
        arg14: $Arg14,
    ),
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
    arg6_name: ^godot.String_Name,
    arg7_name: ^godot.String_Name,
    arg8_name: ^godot.String_Name,
    arg9_name: ^godot.String_Name,
    arg10_name: ^godot.String_Name,
    arg11_name: ^godot.String_Name,
    arg12_name: ^godot.String_Name,
    arg13_name: ^godot.String_Name,
    arg14_name: ^godot.String_Name,
) {
    args_info := [15]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
        simple_property_info(godot.variant_type(Arg6), arg6_name),
        simple_property_info(godot.variant_type(Arg7), arg7_name),
        simple_property_info(godot.variant_type(Arg8), arg8_name),
        simple_property_info(godot.variant_type(Arg9), arg9_name),
        simple_property_info(godot.variant_type(Arg10), arg10_name),
        simple_property_info(godot.variant_type(Arg11), arg11_name),
        simple_property_info(godot.variant_type(Arg12), arg12_name),
        simple_property_info(godot.variant_type(Arg13), arg13_name),
        simple_property_info(godot.variant_type(Arg14), arg14_name),
    }
    args_metadata := [15]gd.ExtensionClassMethodArgumentMetadata {
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
    }

    ptrcall, call := get_void_calls(
        Self,
        Arg0,
        Arg1,
        Arg2,
        Arg3,
        Arg4,
        Arg5,
        Arg6,
        Arg7,
        Arg8,
        Arg9,
        Arg10,
        Arg11,
        Arg12,
        Arg13,
        Arg14,
    )
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = false,
        return_value_metadata  = .None,
        argument_count         = 15,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

bind_returning_method_15_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (
        self: ^$Self,
        arg0: $Arg0,
        arg1: $Arg1,
        arg2: $Arg2,
        arg3: $Arg3,
        arg4: $Arg4,
        arg5: $Arg5,
        arg6: $Arg6,
        arg7: $Arg7,
        arg8: $Arg8,
        arg9: $Arg9,
        arg10: $Arg10,
        arg11: $Arg11,
        arg12: $Arg12,
        arg13: $Arg13,
        arg14: $Arg14,
    ) -> $Ret,
    arg0_name: ^godot.String_Name,
    arg1_name: ^godot.String_Name,
    arg2_name: ^godot.String_Name,
    arg3_name: ^godot.String_Name,
    arg4_name: ^godot.String_Name,
    arg5_name: ^godot.String_Name,
    arg6_name: ^godot.String_Name,
    arg7_name: ^godot.String_Name,
    arg8_name: ^godot.String_Name,
    arg9_name: ^godot.String_Name,
    arg10_name: ^godot.String_Name,
    arg11_name: ^godot.String_Name,
    arg12_name: ^godot.String_Name,
    arg13_name: ^godot.String_Name,
    arg14_name: ^godot.String_Name,
) {
    args_info := [15]gd.PropertyInfo {
        simple_property_info(godot.variant_type(Arg0), arg0_name),
        simple_property_info(godot.variant_type(Arg1), arg1_name),
        simple_property_info(godot.variant_type(Arg2), arg2_name),
        simple_property_info(godot.variant_type(Arg3), arg3_name),
        simple_property_info(godot.variant_type(Arg4), arg4_name),
        simple_property_info(godot.variant_type(Arg5), arg5_name),
        simple_property_info(godot.variant_type(Arg6), arg6_name),
        simple_property_info(godot.variant_type(Arg7), arg7_name),
        simple_property_info(godot.variant_type(Arg8), arg8_name),
        simple_property_info(godot.variant_type(Arg9), arg9_name),
        simple_property_info(godot.variant_type(Arg10), arg10_name),
        simple_property_info(godot.variant_type(Arg11), arg11_name),
        simple_property_info(godot.variant_type(Arg12), arg12_name),
        simple_property_info(godot.variant_type(Arg13), arg13_name),
        simple_property_info(godot.variant_type(Arg14), arg14_name),
    }
    args_metadata := [15]gd.ExtensionClassMethodArgumentMetadata {
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
        .None,
    }

    return_info := simple_property_info(godot.variant_type(Ret), godot.string_name_empty_ref())

    ptrcall, call := get_returning_calls(
        Self,
        Arg0,
        Arg1,
        Arg2,
        Arg3,
        Arg4,
        Arg5,
        Arg6,
        Arg7,
        Arg8,
        Arg9,
        Arg10,
        Arg11,
        Arg12,
        Arg13,
        Arg14,
        Ret,
    )
    method_info := gd.ExtensionClassMethodInfo {
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = true,
        return_value_info      = &return_info,
        return_value_metadata  = .None,
        argument_count         = 15,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }

    gd.classdb_register_extension_class_method(gd.library, class_name, &method_info)
}

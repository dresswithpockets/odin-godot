package libgd

import gd "../gdextension"

GetterFloat :: proc(instance: rawptr) -> gd.float
SetterFloat :: proc(instance: rawptr, value: gd.float)

ptrcall_getter_float :: proc "c" (
    method_user_data: rawptr,
    instance: gd.ExtensionClassInstancePtr,
    args: [^]gd.TypePtr,
    call_return: gd.TypePtr,
) {
    context = gd.godot_context()
    method := cast(GetterFloat)method_user_data
    (cast(^gd.float)call_return)^ = method(instance)
}

ptrcall_setter_float :: proc "c" (
    method_user_data: rawptr,
    instance: gd.ExtensionClassInstancePtr,
    args: [^]gd.TypePtr,
    call_return: gd.TypePtr,
) {
    context = gd.godot_context()
    method := cast(SetterFloat)method_user_data
    method(instance, (cast(^gd.float)args[0])^)
}

call_getter_float :: proc "c" (
    method_user_data: rawptr,
    instance: gd.ExtensionClassInstancePtr,
    args: [^]gd.VariantPtr,
    arg_count: i64,
    call_return: gd.VariantPtr,
    error: ^gd.CallError,
) {
    if arg_count != 0 {
        error.error = .TooManyArguments
        error.expected = 0
        return
    }

    context = gd.godot_context()
    method := cast(GetterFloat)method_user_data
    result := method(instance)
    var_float_constructor := gd.get_variant_from_type_constructor(.Float)
    var_float_constructor(cast(gd.UninitializedVariantPtr)call_return, cast(gd.TypePtr)&result)
}

call_setter_float :: proc "c" (
    method_user_data: rawptr,
    instance: gd.ExtensionClassInstancePtr,
    args: [^]gd.VariantPtr,
    arg_count: i64,
    call_return: gd.VariantPtr,
    error: ^gd.CallError,
) {
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

    context = gd.godot_context()
    method := cast(SetterFloat)method_user_data
    method(instance, arg1)
}
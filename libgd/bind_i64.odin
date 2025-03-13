package libgd

import gd "../gdextension"

@(private = "file")
GetterInt64 :: proc(instance: rawptr) -> i64

@(private = "file")
SetterInt64 :: proc(instance: rawptr, value: i64)

ptrcall_getter_i64 :: proc "c" (
    method_user_data: rawptr,
    instance: gd.ExtensionClassInstancePtr,
    args: [^]gd.TypePtr,
    call_return: gd.TypePtr,
) {
    context = gd.godot_context()
    method := cast(GetterInt64)method_user_data
    (cast(^i64)call_return)^ = method(instance)
}

ptrcall_setter_i64 :: proc "c" (
    method_user_data: rawptr,
    instance: gd.ExtensionClassInstancePtr,
    args: [^]gd.TypePtr,
    call_return: gd.TypePtr,
) {
    context = gd.godot_context()
    method := cast(SetterInt64)method_user_data
    method(instance, (cast(^i64)args[0])^)
}

call_getter_i64 :: proc "c" (
    method_user_data: rawptr,
    instance: gd.ExtensionClassInstancePtr,
    args: [^]gd.VariantPtr,
    arg_count: i64,
    call_return: gd.VariantPtr,
    error: ^gd.CallError,
) {
    if arg_count != 0 {
        error.error = .Too_Many_Arguments
        error.expected = 0
        return
    }

    context = gd.godot_context()

    method := cast(GetterInt64)method_user_data
    result := method(instance)
    constructor := gd.get_variant_from_type_constructor(.Int)
    constructor(cast(gd.UninitializedVariantPtr)call_return, cast(gd.TypePtr)&result)
}

call_setter_i64 :: proc "c" (
    method_user_data: rawptr,
    instance: gd.ExtensionClassInstancePtr,
    args: [^]gd.VariantPtr,
    arg_count: i64,
    call_return: gd.VariantPtr,
    error: ^gd.CallError,
) {
    if arg_count < 1 {
        error.error = .Too_Few_Arguments
        error.expected = 1
        return
    }

    if arg_count > 1 {
        error.error = .Too_Many_Arguments
        error.expected = 1
        return
    }

    type := gd.variant_get_type(args[0])
    if type != .Int {
        error.error = .Invalid_Argument
        error.expected = cast(i32)gd.Variant_Type.Int
        error.argument = 0
        return
    }

    arg1: i64
    constructor := gd.get_variant_to_type_constructor(.Int)
    constructor(cast(gd.TypePtr)&arg1, args[0])

    context = gd.godot_context()

    method := cast(SetterInt64)method_user_data
    method(instance, arg1)
}

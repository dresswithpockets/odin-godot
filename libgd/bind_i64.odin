package libgd

import gdext "godot:gdextension"

@(private = "file")
GetterInt64 :: proc(instance: rawptr) -> i64

@(private = "file")
SetterInt64 :: proc(instance: rawptr, value: i64)

ptrcall_getter_i64 :: proc "c" (
    method_user_data: rawptr,
    instance: gdext.ExtensionClassInstancePtr,
    args: [^]gdext.TypePtr,
    call_return: gdext.TypePtr,
) {
    context = gdext.godot_context()
    method := cast(GetterInt64)method_user_data
    (cast(^i64)call_return)^ = method(instance)
}

ptrcall_setter_i64 :: proc "c" (
    method_user_data: rawptr,
    instance: gdext.ExtensionClassInstancePtr,
    args: [^]gdext.TypePtr,
    call_return: gdext.TypePtr,
) {
    context = gdext.godot_context()
    method := cast(SetterInt64)method_user_data
    method(instance, (cast(^i64)args[0])^)
}

call_getter_i64 :: proc "c" (
    method_user_data: rawptr,
    instance: gdext.ExtensionClassInstancePtr,
    args: [^]gdext.VariantPtr,
    arg_count: i64,
    call_return: gdext.VariantPtr,
    error: ^gdext.CallError,
) {
    if arg_count != 0 {
        error.error = .Too_Many_Arguments
        error.expected = 0
        return
    }

    context = gdext.godot_context()

    method := cast(GetterInt64)method_user_data
    result := method(instance)
    constructor := gdext.get_variant_from_type_constructor(.Int)
    constructor(call_return, &result)
}

call_setter_i64 :: proc "c" (
    method_user_data: rawptr,
    instance: gdext.ExtensionClassInstancePtr,
    args: [^]gdext.VariantPtr,
    arg_count: i64,
    call_return: gdext.VariantPtr,
    error: ^gdext.CallError,
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

    type := gdext.variant_get_type(args[0])
    if type != .Int {
        error.error = .Invalid_Argument
        error.expected = cast(i32)gdext.Variant_Type.Int
        error.argument = 0
        return
    }

    arg1: i64
    constructor := gdext.get_variant_to_type_constructor(.Int)
    constructor(cast(gdext.TypePtr)&arg1, args[0])

    context = gdext.godot_context()

    method := cast(SetterInt64)method_user_data
    method(instance, arg1)
}

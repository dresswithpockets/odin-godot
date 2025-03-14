package libgd

import "godot:godot"
import gdext "godot:gdextension"

GetterFloat :: proc(instance: rawptr) -> godot.Float
SetterFloat :: proc(instance: rawptr, value: godot.Float)

ptrcall_getter_float :: proc "c" (
    method_user_data: rawptr,
    instance: gdext.ExtensionClassInstancePtr,
    args: [^]gdext.TypePtr,
    call_return: gdext.TypePtr,
) {
    context = gdext.godot_context()
    method := cast(GetterFloat)method_user_data
    (cast(^godot.Float)call_return)^ = method(instance)
}

ptrcall_setter_float :: proc "c" (
    method_user_data: rawptr,
    instance: gdext.ExtensionClassInstancePtr,
    args: [^]gdext.TypePtr,
    call_return: gdext.TypePtr,
) {
    context = gdext.godot_context()
    method := cast(SetterFloat)method_user_data
    method(instance, (cast(^godot.Float)args[0])^)
}

call_getter_float :: proc "c" (
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
    method := cast(GetterFloat)method_user_data
    result := method(instance)
    var_float_constructor := gdext.get_variant_from_type_constructor(.Float)
    var_float_constructor(call_return, cast(gdext.TypePtr)&result)
}

call_setter_float :: proc "c" (
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
    if type != .Float {
        error.error = .Invalid_Argument
        error.expected = cast(i32)gdext.Variant_Type.Float
        error.argument = 0
        return
    }

    arg1: f64
    float_from_var_constructor := gdext.get_variant_to_type_constructor(.Float)
    float_from_var_constructor(cast(gdext.TypePtr)&arg1, args[0])

    context = gdext.godot_context()
    method := cast(SetterFloat)method_user_data
    method(instance, arg1)
}
package example

import gd "../../../gdextension"
import var "../../../variant"
import core "../../../core"

new_property :: proc {new_property_simple, new_property_detailed}

new_property_simple :: proc(type: gd.VariantType, name: cstring) -> gd.PropertyInfo {
    return new_property_detailed(type, name, cast(u32)core.PropertyHint.None, "", "", cast(u32)core.PropertyUsageFlags.Default)
}

new_property_detailed :: proc(
    type: gd.VariantType,
    name: cstring,
    hint: u32,
    hint_string: cstring,
    class_name: cstring,
    usage_flags: u32) -> gd.PropertyInfo
{
    prop_name := new(var.StringName)
    gd.string_name_new_with_latin1_chars(cast(gd.StringNamePtr)prop_name, name, false)

    prop_hint_string := new(var.String)
    gd.string_new_with_latin1_chars(cast(gd.StringPtr)prop_hint_string, hint_string)

    prop_class_name := new(var.StringName)
    gd.string_name_new_with_latin1_chars(cast(gd.StringNamePtr)prop_class_name, class_name, false)

    return gd.PropertyInfo{
        name = cast(gd.StringNamePtr)prop_name,
        type = type,
        hint = hint,
        hint_string = cast(gd.StringPtr)prop_hint_string,
        class_name = cast(gd.StringNamePtr)prop_class_name,
        usage = usage_flags,
    }
}

free_property :: proc(prop: ^gd.PropertyInfo) {
    // TODO: _ptr variants for String and StringName destructors
    //       alternatively, maybe StringNamePtr and StringPtr just isnt needed...
    var.free_string_name((cast(^var.StringName)prop.name)^)
    var.free_string((cast(^var.String)prop.hint_string)^)
    var.free_string_name((cast(^var.StringName)prop.class_name)^)
    free(prop.name)
    free(prop.hint_string)
    free(prop.class_name)
}

bind_method_return :: proc(class_name: cstring, method_name: cstring, function: rawptr, return_type: gd.VariantType, call_func: gd.ExtensionClassMethodCall, ptr_call_func: gd.ExtensionClassMethodPtrCall, args: ..MethodBindArgument) {
    method_name_string := var.StringName{}
    gd.string_name_new_with_latin1_chars(cast(gd.StringNamePtr)&method_name_string, method_name, false)
    defer var.free_string_name(method_name_string)

    return_info := new_property(return_type, "")
    defer free_property(&return_info)

    method_info := gd.ExtensionClassMethodInfo{
        name                   = cast(gd.StringNamePtr)&method_name_string,
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

    class_name_string := var.StringName{}
    gd.string_name_new_with_latin1_chars(cast(gd.StringNamePtr)&class_name_string, class_name, false)
    defer var.free_string_name(class_name_string)

    gd.classdb_register_extension_class_method(gd.library, cast(gd.StringNamePtr)&class_name_string, &method_info)
}

MethodBindArgument :: struct {
    name: cstring,
    type: gd.VariantType,
}

bind_method_1_no_return :: proc(class_name: cstring, method_name: cstring, function: rawptr, call_func: gd.ExtensionClassMethodCall, ptr_call_func: gd.ExtensionClassMethodPtrCall, arg_type: gd.VariantType, arg_name: cstring) {
    method_name_string := var.StringName{}
    gd.string_name_new_with_latin1_chars(cast(gd.StringNamePtr)&method_name_string, method_name, false)
    defer var.free_string_name(method_name_string)

    args_info := [1]gd.PropertyInfo {
        new_property(arg_type, arg_name)
    }
    defer free_property(&args_info[0])

    args_metadata := [1]gd.ExtensionClassMethodArgumentMetadata {
        .None
    }

    method_info := gd.ExtensionClassMethodInfo{
        name                   = cast(gd.StringNamePtr)&method_name_string,
        method_user_data       = function,
        call_func              = call_func,
        ptr_call_func          = ptr_call_func,
        method_flags           = cast(u32)core.MethodFlags.Default,
        has_return_value       = false,
        argument_count         = 1,
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
        default_arguments      = nil,
    }

    class_name_string := var.StringName{}
    gd.string_name_new_with_latin1_chars(cast(gd.StringNamePtr)&class_name_string, class_name, false)
    defer var.free_string_name(class_name_string)

    gd.classdb_register_extension_class_method(gd.library, cast(gd.StringNamePtr)&class_name_string, &method_info)
}

bind_method_no_return :: proc(class_name: cstring, method_name: cstring, function: rawptr, call_func: gd.ExtensionClassMethodCall, ptr_call_func: gd.ExtensionClassMethodPtrCall, args: ..MethodBindArgument) {
    method_name_string := var.StringName{}
    gd.string_name_new_with_latin1_chars(cast(gd.StringNamePtr)&method_name_string, method_name, false)
    defer var.free_string_name(method_name_string)

    method_info := gd.ExtensionClassMethodInfo{
        name                  = cast(gd.StringNamePtr)&method_name_string,
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

    class_name_string := var.StringName{}
    gd.string_name_new_with_latin1_chars(cast(gd.StringNamePtr)&class_name_string, class_name, false)
    defer var.free_string_name(class_name_string)

    gd.classdb_register_extension_class_method(gd.library, cast(gd.StringNamePtr)&class_name_string, &method_info)
}

bind_property :: proc(class_name: cstring, name: cstring, type: gd.VariantType, getter: cstring, setter: cstring) {
    class_name_string := var.StringName{}
    gd.string_name_new_with_latin1_chars(cast(gd.StringNamePtr)&class_name_string, class_name, false)
    defer var.free_string_name(class_name_string)

    info := new_property(type, name)

    getter_name := var.StringName{}
    gd.string_name_new_with_latin1_chars(cast(gd.StringNamePtr)&getter_name, getter, false)
    defer var.free_string_name(getter_name)

    setter_name := var.StringName{}
    gd.string_name_new_with_latin1_chars(cast(gd.StringNamePtr)&setter_name, setter, false)
    defer var.free_string_name(setter_name)

    gd.classdb_register_extension_class_property(gd.library, cast(gd.StringNamePtr)&class_name_string, &info, cast(gd.StringNamePtr)&setter_name, cast(gd.StringNamePtr)&getter_name)
}
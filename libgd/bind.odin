package libgd

import "godot:godot"
import gdext "godot:gdextension"

@(private = "file")
new_property :: proc(type: gdext.Variant_Type, name: ^godot.String_Name) -> gdext.PropertyInfo {
    return gdext.PropertyInfo {
        name = name,
        type = type,
        hint = cast(u32)godot.Property_Hint.None,
        hint_string = godot.string_empty_ref(),
        class_name = godot.string_name_empty_ref(),
        usage = cast(u32)godot.Property_Usage_Flags.Property_Usage_Default,
    }
}

MethodBindArgument :: struct {
    name: string,
    type: gdext.Variant_Type,
}

bind_signal :: proc(class_name: ^godot.String_Name, name: string, args: ..MethodBindArgument) {
    signal_name := godot.new_string_name_odin(name)
    defer godot.free_string_name(signal_name)

    if len(args) == 0 {
        gdext.classdb_register_extension_class_signal(gdext.library, class_name, &signal_name, nil, 0)
        return
    }

    args_info := make([]gdext.PropertyInfo, len(args))
    defer delete(args_info)

    for arg, idx in args {
        arg_name := godot.new_string_name_odin(arg.name)
        args_info[idx] = new_property(arg.type, &arg_name)
    }
    defer for arg in args_info {
        arg_name := cast(^godot.String_Name)arg.name
        godot.free_string_name(arg_name^)
    }

    gdext.classdb_register_extension_class_signal(
        gdext.library,
        class_name,
        &signal_name,
        raw_data(args_info),
        cast(i64)len(args),
    )
}

@(private = "file")
get_prop_ptrcall :: proc($V: typeid) -> (get: gdext.ExtensionClassMethodPtrCall, set: gdext.ExtensionClassMethodPtrCall) {
    if V == f64 {
        return ptrcall_getter_float, ptrcall_setter_float
    } else if V == i64 {
        return ptrcall_getter_i64, ptrcall_setter_i64
    }

    return nil, nil
}

@(private = "file")
get_prop_call :: proc($V: typeid) -> (get: gdext.ExtensionClassMethodCall, set: gdext.ExtensionClassMethodCall) {
    if V == f64 {
        return call_getter_float, call_setter_float
    } else if V == i64 {
        return call_getter_i64, call_setter_i64
    }

    return nil, nil
}

@(private = "file")
get_prop_type :: proc($V: typeid) -> gdext.Variant_Type {
    if V == f64 {
        return .Float
    } else if V == i64 {
        return .Int
    }

    return .Object
}

bind_property_group :: proc(class_name: ^godot.String_Name, name: string, prefix: string) {
    name_str := godot.new_string_odin(name)
    defer godot.free_string(name_str)

    prefix_str := godot.new_string_odin(prefix)
    defer godot.free_string(prefix_str)

    gdext.classdb_register_extension_class_property_group(gdext.library, class_name, &name_str, &prefix_str)
}

bind_property_subgroup :: proc(class_name: ^godot.String_Name, name: string, prefix: string) {
    name_str := godot.new_string_odin(name)
    defer godot.free_string(name_str)

    prefix_str := godot.new_string_odin(prefix)
    defer godot.free_string(prefix_str)

    gdext.classdb_register_extension_class_property_subgroup(gdext.library, class_name, &name_str, &prefix_str)
}

bind_auto_property :: proc(
    class_name: ^godot.String_Name,
    prop_name: string,
    getter_name: string,
    getter_proc: proc(self: ^$T) -> $V,
    setter_name: string,
    setter_proc: proc(self: ^$ST/T, value: $SV/V),
) {
    property_name := godot.new_string_name_odin(prop_name)
    defer godot.free_string_name(property_name)

    getter_method_name := godot.new_string_name_odin(getter_name)
    defer godot.free_string_name(getter_method_name)

    setter_method_name := godot.new_string_name_odin(setter_name)
    defer godot.free_string_name(setter_method_name)

    property_type := get_prop_type(V)
    getter_call, setter_call := get_prop_call(V)
    getter_ptrcall, setter_ptrcall := get_prop_ptrcall(V)

    // getter
    {
        return_info := new_property(property_type, godot.string_name_empty_ref())
        method_info := gdext.ExtensionClassMethodInfo {
            name                   = &getter_method_name,
            method_user_data       = cast(rawptr)getter_proc,
            call_func              = getter_call,
            ptr_call_func          = getter_ptrcall,
            method_flags           = 0,
            has_return_value       = true,
            return_value_info      = &return_info,
            return_value_metadata  = .None,
            argument_count         = 0,
            default_argument_count = 0,
        }

        gdext.classdb_register_extension_class_method(gdext.library, class_name, &method_info)
    }

    // setter
    {
        args_info := new_property(property_type, &property_name)
        args_metadata := gdext.ExtensionClassMethodArgumentMetadata.None
        method_info := gdext.ExtensionClassMethodInfo {
            name               = &setter_method_name,
            method_user_data   = cast(rawptr)setter_proc,
            call_func          = setter_call,
            ptr_call_func      = setter_ptrcall,
            method_flags       = 0,
            has_return_value   = false,
            argument_count     = 1,
            arguments_info     = &args_info,
            arguments_metadata = &args_metadata,
        }

        gdext.classdb_register_extension_class_method(gdext.library, class_name, &method_info)
    }

    // property
    {
        info := new_property(property_type, &property_name)
        gdext.classdb_register_extension_class_property(gdext.library, class_name, &info, &setter_method_name, &getter_method_name)
    }
}

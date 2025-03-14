get_void_calls_template = """
get_void_calls_{arg_count}_args :: proc "contextless" (
    $Self: typeid,{arg_typeid_decls}
) -> (
    gdext.ExtensionClassMethodPtrCall,
    gdext.ExtensionClassMethodCall,
) {{
    Proc :: #type proc "contextless" (self: ^Self{proc_arg_decls})
    ptrcall :: proc "c" (data: rawptr, instance: gdext.ExtensionClassInstancePtr, args: [^]gdext.TypePtr, ret: gdext.TypePtr) {{
        context = gdext.godot_context()

        method := cast(Proc)data
        method(cast(^Self)instance{ptrcall_arg_invokes})
    }}
    call :: proc "c" (
        data: rawptr,
        instance: gdext.ExtensionClassInstancePtr,
        args: [^]gdext.VariantPtr,
        arg_count: i64,
        ret: gdext.VariantPtr,
        error: ^gdext.CallError,
    ) {{
        if !expect_args(args, arg_count, error{expect_args_params}) {{
            return
        }}

        context = gdext.godot_context()
{call_arg_inits}
        method := cast(Proc)data
        method(cast(^Self)instance{call_arg_invokes})
    }}
    return ptrcall, call
}}
"""

get_returning_calls_template = """
get_returning_calls_{arg_count}_args :: proc "contextless" (
    $Self: typeid,{arg_typeid_decls}
    $Ret: typeid,
) -> (
    gdext.ExtensionClassMethodPtrCall,
    gdext.ExtensionClassMethodCall,
) {{
    Proc :: #type proc "contextless" (self: ^Self{proc_arg_decls}) -> Ret
    ptrcall :: proc "c" (data: rawptr, instance: gdext.ExtensionClassInstancePtr, args: [^]gdext.TypePtr, ret: gdext.TypePtr) {{
        context = gdext.godot_context()

        method := cast(Proc)data
        (cast(^Ret)ret)^ = method(cast(^Self)instance{ptrcall_arg_invokes})
    }}
    call :: proc "c" (
        data: rawptr,
        instance: gdext.ExtensionClassInstancePtr,
        args: [^]gdext.VariantPtr,
        arg_count: i64,
        ret: gdext.VariantPtr,
        error: ^gdext.CallError,
    ) {{
        if !expect_args(args, arg_count, error{expect_args_params}) {{
            return
        }}

        context = gdext.godot_context()
{call_arg_inits}
        method := cast(Proc)data
        result := method(cast(^Self)instance{call_arg_invokes})

        godot.variant_into_ptr(&result, cast(^godot.Variant)ret)
    }}
    return ptrcall, call
}}
"""

bind_void_method_0_args_template = """
bind_void_method_0_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (self: ^$Self),
) {
    ptrcall, call := get_void_calls(Self)
    method_info := gdext.ExtensionClassMethodInfo {
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

    gdext.classdb_register_extension_class_method(gdext.library, class_name, &method_info)
}
"""

bind_void_method_template = """
bind_void_method_{arg_count}_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (self: ^$Self{bind_proc_arg_decls}),{arg_name_decls}
) {{
    args_info := [{arg_count}]gdext.PropertyInfo{{ {arg_property_infos} }}
    args_metadata := [{arg_count}]gdext.ExtensionClassMethodArgumentMetadata{{ {arg_metadata} }}

    ptrcall, call := get_void_calls(Self{get_calls_args})
    method_info := gdext.ExtensionClassMethodInfo {{
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = false,
        return_value_metadata  = .None,
        argument_count         = {arg_count},
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }}

    gdext.classdb_register_extension_class_method(gdext.library, class_name, &method_info)
}}
"""

bind_returning_method_0_args_template = """
bind_returning_method_0_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (self: ^$Self) -> $Ret,
) {
    return_info := simple_property_info(godot.variant_type(Ret), godot.string_name_empty_ref())

    ptrcall, call := get_returning_calls(Self, Ret)
    method_info := gdext.ExtensionClassMethodInfo {
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

    gdext.classdb_register_extension_class_method(gdext.library, class_name, &method_info)
}
"""

bind_returning_method_template = """
bind_returning_method_{arg_count}_args :: proc "contextless" (
    class_name: ^godot.String_Name,
    method_name: ^godot.String_Name,
    function: $P/proc "contextless" (self: ^$Self{bind_proc_arg_decls}) -> $Ret,{arg_name_decls}
) {{
    args_info := [{arg_count}]gdext.PropertyInfo{{ {arg_property_infos} }}
    args_metadata := [{arg_count}]gdext.ExtensionClassMethodArgumentMetadata{{ {arg_metadata} }}

    return_info := simple_property_info(godot.variant_type(Ret), godot.string_name_empty_ref())

    ptrcall, call := get_returning_calls(Self{get_calls_args}, Ret)
    method_info := gdext.ExtensionClassMethodInfo {{
        name                   = method_name,
        method_user_data       = cast(rawptr)function,
        call_func              = call,
        ptr_call_func          = ptrcall,
        method_flags           = 0,
        has_return_value       = true,
        return_value_info      = &return_info,
        return_value_metadata  = .None,
        argument_count         = {arg_count},
        arguments_info         = &args_info[0],
        arguments_metadata     = &args_metadata[0],
        default_argument_count = 0,
    }}

    gdext.classdb_register_extension_class_method(gdext.library, class_name, &method_info)
}}
"""

def main():
    max_arg_count = 16

    print("package classdb")
    print()

    print("import \"godot:gdext\"")
    print("import \"godot:godot\"")
    print()

    print("bind_void_method :: proc {")
    for arg_count in range(max_arg_count):
        print(f"    bind_void_method_{arg_count}_args,")
    print("}")
    print()

    print("bind_returning_method :: proc {")
    for arg_count in range(max_arg_count):
        print(f"    bind_returning_method_{arg_count}_args,")
    print("}")
    print()
    
    print("get_void_calls :: proc {")
    for arg_count in range(max_arg_count):
        print(f"    get_void_calls_{arg_count}_args,")
    print("}")
    print()

    print("get_returning_calls :: proc {")
    for arg_count in range(max_arg_count):
        print(f"    get_returning_calls_{arg_count}_args,")
    print("}")
    print()

    print(bind_void_method_0_args_template)
    print(bind_returning_method_0_args_template)

    for arg_count in range(max_arg_count):
        arg_typeid_decls = ""
        proc_arg_decls = ""
        ptrcall_arg_invokes = ""
        expect_args_params = ""
        call_arg_inits = ""
        call_arg_invokes = ""

        bind_proc_arg_decls = ""
        arg_name_decls = ""
        arg_property_infos = ""
        arg_metadata = ""
        get_calls_args = ""

        for arg_idx in range(arg_count):
            arg_typeid_decls += f"\n    $Arg{arg_idx}: typeid,"
            proc_arg_decls += f", arg{arg_idx}: Arg{arg_idx}"
            ptrcall_arg_invokes += f", (cast(^Arg{arg_idx})args[{arg_idx}])^"
            expect_args_params += f", godot.variant_type(Arg{arg_idx})"
            call_arg_inits += f"\n        arg{arg_idx} := godot.variant_to(cast(^godot.Variant)args[{arg_idx}], Arg{arg_idx})"
            call_arg_invokes += f", arg{arg_idx}"

            bind_proc_arg_decls += f", arg{arg_idx}: $Arg{arg_idx}"
            arg_name_decls += f"\n    arg{arg_idx}_name: ^godot.String_Name,"
            arg_property_infos += f"simple_property_info(godot.variant_type(Arg{arg_idx}), arg{arg_idx}_name),"
            arg_metadata += ".None,"
            get_calls_args += f", Arg{arg_idx}"

        print(get_void_calls_template.format(
            arg_count = arg_count,
            arg_typeid_decls = arg_typeid_decls,
            proc_arg_decls = proc_arg_decls,
            ptrcall_arg_invokes = ptrcall_arg_invokes,
            expect_args_params = expect_args_params,
            call_arg_inits = call_arg_inits,
            call_arg_invokes = call_arg_invokes,
        ))

        print(get_returning_calls_template.format(
            arg_count = arg_count,
            arg_typeid_decls = arg_typeid_decls,
            proc_arg_decls = proc_arg_decls,
            ptrcall_arg_invokes = ptrcall_arg_invokes,
            expect_args_params = expect_args_params,
            call_arg_inits = call_arg_inits,
            call_arg_invokes = call_arg_invokes,
        ))

        if arg_count > 0:
            print(bind_void_method_template.format(
                arg_count = arg_count,
                bind_proc_arg_decls = bind_proc_arg_decls,
                arg_name_decls = arg_name_decls,
                arg_property_infos = arg_property_infos,
                arg_metadata = arg_metadata,
                get_calls_args = get_calls_args,
            ))

            print(bind_returning_method_template.format(
                arg_count = arg_count,
                bind_proc_arg_decls = bind_proc_arg_decls,
                arg_name_decls = arg_name_decls,
                arg_property_infos = arg_property_infos,
                arg_metadata = arg_metadata,
                get_calls_args = get_calls_args,
            ))


if __name__ == "__main__":
    main()

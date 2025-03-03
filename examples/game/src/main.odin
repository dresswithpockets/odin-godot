package game

import gd "../../../gdextension"
import var "../../../variant"
import core "../../../core"
import "core:strings"
import "core:c"
import "core:fmt"

// see gd.InitializationFunction
@(export)
game_init :: proc "c" (
    get_proc_address: gd.ExtensionInterfaceGetProcAddress,
    library: gd.ExtensionClassLibraryPtr,
    initialization: ^gd.Initialization,
) -> bool {
    gd.init(library, get_proc_address)
    var.init()

    initialization.initialize = initialize_game_module
    initialization.deinitialize = uninitialize_game_module
    initialization.user_data = nil
    initialization.minimum_initialization_level = .Core

    return true
}

initialize_game_module :: proc "c" (user_data: rawptr, level: gd.InitializationLevel) {
    // context = gd.godot_context()

    if level != .Scene {
        return
    }

    {
        node_classname: var.StringName
        gd.string_name_new_with_latin1_chars(&node_classname, "Node", true);

        get_node_methodname: var.StringName
        gd.string_name_new_with_latin1_chars(&get_node_methodname, "get_node", true);

        get_node_method_bind = gd.classdb_get_method_bind(&node_classname, &get_node_methodname, get_node_hash);
    }

    {
        print_name: var.StringName
        gd.string_name_new_with_latin1_chars(&print_name, "print", true);

        print_ptr = gd.variant_get_ptr_utility_function(&print_name, 2648703342);
    }

    // core.init()
    player_class_register()
}

uninitialize_game_module :: proc "c" (user_data: rawptr, level: gd.InitializationLevel) {
    // context = gd.godot_context()

    if level != .Scene {
        return
    }
}

call_builtin_op_bool :: proc "c" (op: gd.PtrOperatorEvaluator, a: gd.TypePtr, b: gd.TypePtr) -> bool {
    result: bool
    op(a, b, &result)
    return result
}

print_object :: proc "c" (object: gd.TypePtr) {
    var_from_obj := gd.get_variant_from_type_constructor(.Object)
    as_var: var.Variant
    var_from_obj(&as_var, object)

    args := [1]gd.TypePtr{ &as_var }
    print_ptr(nil, &args[0], 1)
}

// utils
print_ptr: gd.PtrUtilityFunction

// hashes & method binds
get_node_hash :: 2734337346
get_node_method_bind: gd.MethodBindPtr

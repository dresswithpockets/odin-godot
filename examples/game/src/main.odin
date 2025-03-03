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
    ext_library = library
    ext_get_proc_address = get_proc_address
    // gd.init(library, get_proc_address)
    // var.init()

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

    gd_alloc = cast(gd.ExtensionInterfaceMemAlloc)ext_get_proc_address("mem_alloc")
    gd_free = cast(gd.ExtensionInterfaceMemFree)ext_get_proc_address("mem_free")
    string_name_new_with_latin1_chars = cast(gd.ExtensionInterfaceStringNameNewWithLatin1Chars)ext_get_proc_address("string_name_new_with_latin1_chars")
    string_new_with_latin1_chars = cast(gd.ExtensionInterfaceStringNewWithLatin1Chars)ext_get_proc_address("string_new_with_latin1_chars")
    classdb_get_method_bind = cast(gd.ExtensionInterfaceClassdbGetMethodBind)ext_get_proc_address("classdb_get_method_bind")
    global_get_singleton = cast(gd.ExtensionInterfaceGlobalGetSingleton)ext_get_proc_address("global_get_singleton")
    classdb_construct_object = cast(gd.ExtensionInterfaceClassdbConstructObject)ext_get_proc_address("classdb_construct_object")
    object_set_instance = cast(gd.ExtensionInterfaceObjectSetInstance)ext_get_proc_address("object_set_instance")
    object_set_instance_binding = cast(gd.ExtensionInterfaceObjectSetInstanceBinding)ext_get_proc_address("object_set_instance_binding")
    classdb_register_extension_class3 = cast(gd.ExtensionInterfaceClassdbRegisterExtensionClass3)ext_get_proc_address("classdb_register_extension_class3")
    object_method_bind_ptrcall = cast(gd.ExtensionInterfaceObjectMethodBindPtrcall)ext_get_proc_address("object_method_bind_ptrcall")
    variant_get_ptr_utility_function = cast(gd.ExtensionInterfaceVariantGetPtrUtilityFunction)ext_get_proc_address("variant_get_ptr_utility_function")
    variant_get_ptr_operator_evaluator = cast(gd.ExtensionInterfaceVariantGetPtrOperatorEvaluator)ext_get_proc_address("variant_get_ptr_operator_evaluator")
    variant_get_ptr_constructor = cast(gd.ExtensionInterfaceVariantGetPtrConstructor)ext_get_proc_address("variant_get_ptr_constructor")
    get_variant_from_type_constructor = cast(gd.ExtensionInterfaceGetVariantFromTypeConstructor)ext_get_proc_address("get_variant_from_type_constructor")

    {
        node_classname: StringName
        string_name_new_with_latin1_chars(&node_classname, "Node", true);

        get_node_methodname: StringName
        string_name_new_with_latin1_chars(&get_node_methodname, "get_node", true);

        get_node_method_bind = classdb_get_method_bind(&node_classname, &get_node_methodname, get_node_hash);
    }

    StringName_eq_StringName_op = variant_get_ptr_operator_evaluator(.Equal, .StringName, .StringName);
    node_path_from_string = variant_get_ptr_constructor(.NodePath, 2);

    {
        print_name: StringName
        string_name_new_with_latin1_chars(&print_name, "print", true);

        print_ptr = variant_get_ptr_utility_function(&print_name, 2648703342);
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
    var_from_obj := get_variant_from_type_constructor(.Object)
    as_var: Variant
    var_from_obj(&as_var, object)

    args := [1]gd.TypePtr{ &as_var }
    print_ptr(nil, &args[0], 1)
}

// extension
ext_library: gd.ExtensionClassLibraryPtr
ext_get_proc_address: gd.ExtensionInterfaceGetProcAddress

// interface procs
gd_alloc: gd.ExtensionInterfaceMemAlloc
gd_free: gd.ExtensionInterfaceMemFree
string_name_new_with_latin1_chars: gd.ExtensionInterfaceStringNameNewWithLatin1Chars
string_new_with_latin1_chars: gd.ExtensionInterfaceStringNewWithLatin1Chars
classdb_get_method_bind: gd.ExtensionInterfaceClassdbGetMethodBind
global_get_singleton: gd.ExtensionInterfaceGlobalGetSingleton
classdb_construct_object: gd.ExtensionInterfaceClassdbConstructObject
object_set_instance: gd.ExtensionInterfaceObjectSetInstance
object_set_instance_binding: gd.ExtensionInterfaceObjectSetInstanceBinding
classdb_register_extension_class3: gd.ExtensionInterfaceClassdbRegisterExtensionClass3
object_method_bind_ptrcall: gd.ExtensionInterfaceObjectMethodBindPtrcall
variant_get_ptr_utility_function: gd.ExtensionInterfaceVariantGetPtrUtilityFunction
variant_get_ptr_operator_evaluator: gd.ExtensionInterfaceVariantGetPtrOperatorEvaluator
variant_get_ptr_constructor: gd.ExtensionInterfaceVariantGetPtrConstructor
get_variant_from_type_constructor: gd.ExtensionInterfaceGetVariantFromTypeConstructor

// utils
print_ptr: gd.PtrUtilityFunction

// constructors
node_path_from_string: gd.PtrConstructor

// hashes & method binds
get_node_hash :: 2734337346
get_node_method_bind: gd.MethodBindPtr

// operators
StringName_eq_StringName_op: gd.PtrOperatorEvaluator
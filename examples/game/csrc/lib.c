#include <stdbool.h>

#include "lib.h"
#include "player.h"

GDExtensionClassLibraryPtr ext_library;

// ext interface
GDExtensionInterfaceGetProcAddress ext_get_proc_address;
GDExtensionInterfaceMemAlloc gd_alloc;
GDExtensionInterfaceMemFree gd_free;
GDExtensionInterfaceStringNameNewWithLatin1Chars string_name_new_with_latin1_chars;
GDExtensionInterfaceStringNewWithLatin1Chars string_new_with_latin1_chars;
GDExtensionInterfaceClassdbGetMethodBind classdb_get_method_bind;
GDExtensionInterfaceGlobalGetSingleton global_get_singleton;
GDExtensionInterfaceClassdbConstructObject classdb_construct_object;
GDExtensionInterfaceObjectSetInstance object_set_instance;
GDExtensionInterfaceObjectSetInstanceBinding object_set_instance_binding;
GDExtensionInterfaceClassdbRegisterExtensionClass3 classdb_register_extension_class3;
GDExtensionInterfaceObjectMethodBindPtrcall object_method_bind_ptrcall;
GDExtensionInterfaceVariantGetPtrUtilityFunction variant_get_ptr_utility_function;
GDExtensionInterfaceVariantGetPtrOperatorEvaluator variant_get_ptr_operator_evaluator;
GDExtensionInterfaceVariantGetPtrConstructor variant_get_ptr_constructor;
GDExtensionInterfaceGetVariantFromTypeConstructor get_variant_from_type_constructor;

// utils
GDExtensionPtrUtilityFunction print_ptr;

// constructors
GDExtensionPtrConstructor node_path_from_string;

// hashes & method binds
const GDExtensionInt get_node_hash = 2734337346;
GDExtensionMethodBindPtr get_node_method_bind;

// operators
GDExtensionPtrOperatorEvaluator StringName_eq_StringName_op;

void __cdecl initialize_game_module(void* user_data, GDExtensionInitializationLevel level) {
    if (level != GDEXTENSION_INITIALIZATION_SCENE) {
        return;
    }

    gd_alloc = (GDExtensionInterfaceMemAlloc)ext_get_proc_address("mem_alloc");
    gd_free = (GDExtensionInterfaceMemFree)ext_get_proc_address("mem_free");
    string_name_new_with_latin1_chars = (GDExtensionInterfaceStringNameNewWithLatin1Chars)ext_get_proc_address("string_name_new_with_latin1_chars");
    string_new_with_latin1_chars = (GDExtensionInterfaceStringNewWithLatin1Chars)ext_get_proc_address("string_new_with_latin1_chars");
    classdb_get_method_bind = (GDExtensionInterfaceClassdbGetMethodBind)ext_get_proc_address("classdb_get_method_bind");
    global_get_singleton = (GDExtensionInterfaceGlobalGetSingleton)ext_get_proc_address("global_get_singleton");
    classdb_construct_object = (GDExtensionInterfaceClassdbConstructObject)ext_get_proc_address("classdb_construct_object");
    object_set_instance = (GDExtensionInterfaceObjectSetInstance)ext_get_proc_address("object_set_instance");
    object_set_instance_binding = (GDExtensionInterfaceObjectSetInstanceBinding)ext_get_proc_address("object_set_instance_binding");
    classdb_register_extension_class3 = (GDExtensionInterfaceClassdbRegisterExtensionClass3)ext_get_proc_address("classdb_register_extension_class3");
    object_method_bind_ptrcall = (GDExtensionInterfaceObjectMethodBindPtrcall)ext_get_proc_address("object_method_bind_ptrcall");
    variant_get_ptr_utility_function = (GDExtensionInterfaceVariantGetPtrUtilityFunction)ext_get_proc_address("variant_get_ptr_utility_function");
    variant_get_ptr_operator_evaluator = (GDExtensionInterfaceVariantGetPtrOperatorEvaluator)ext_get_proc_address("variant_get_ptr_operator_evaluator");
    variant_get_ptr_constructor = (GDExtensionInterfaceVariantGetPtrConstructor)ext_get_proc_address("variant_get_ptr_constructor");
    get_variant_from_type_constructor = (GDExtensionInterfaceGetVariantFromTypeConstructor)ext_get_proc_address("get_variant_from_type_constructor");

    {
        StringName node_classname;
        string_name_new_with_latin1_chars(&node_classname, "Node", true);

        StringName get_node_methodname;
        string_name_new_with_latin1_chars(&get_node_methodname, "get_node", true);

        get_node_method_bind = classdb_get_method_bind(&node_classname, &get_node_methodname, get_node_hash);
    }

    StringName_eq_StringName_op = variant_get_ptr_operator_evaluator(GDEXTENSION_VARIANT_OP_EQUAL, GDEXTENSION_VARIANT_TYPE_STRING_NAME, GDEXTENSION_VARIANT_TYPE_STRING_NAME);
    node_path_from_string = variant_get_ptr_constructor(GDEXTENSION_VARIANT_TYPE_NODE_PATH, 2);

    {
        StringName print_name;
        string_name_new_with_latin1_chars(&print_name, "print", true);

        print_ptr = variant_get_ptr_utility_function(&print_name, 2648703342);
    }

    player_class_register();
}

void __cdecl deinitialize_game_module(void* user_data, GDExtensionInitializationLevel level) {
    if (level != GDEXTENSION_INITIALIZATION_SCENE) {
        return;
    }
}

__declspec(dllexport) GDExtensionBool __cdecl game_init(
    GDExtensionInterfaceGetProcAddress get_proc_address,
    GDExtensionClassLibraryPtr library,
    GDExtensionInitialization* initialization)
{
    ext_get_proc_address = get_proc_address;
    ext_library = library;

    initialization->initialize = initialize_game_module;
    initialization->deinitialize = deinitialize_game_module;
    initialization->userdata = NULL;
    initialization->minimum_initialization_level = GDEXTENSION_INITIALIZATION_CORE;

    return 1;
}

GDExtensionBool call_builtin_op_bool(GDExtensionPtrOperatorEvaluator op, GDExtensionConstTypePtr a, GDExtensionConstTypePtr b) {
    GDExtensionBool result;
    op(a, b, &result);
    return result;
}

void print_object(GDExtensionTypePtr object) {
    GDExtensionVariantFromTypeConstructorFunc var_from_obj = get_variant_from_type_constructor(GDEXTENSION_VARIANT_TYPE_OBJECT);
    Variant as_variant;
    var_from_obj(&as_variant, object);

    GDExtensionConstTypePtr args[1] = { &as_variant };
    print_ptr(NULL, args, 1);
}

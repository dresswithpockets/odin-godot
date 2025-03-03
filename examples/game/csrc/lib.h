#pragma once
#include "../../../godot-cpp/gdextension/gdextension_interface.h"

typedef uint8_t NodePath[8];
typedef uint8_t StringName[8];
typedef uint8_t String[8];
typedef uint8_t Variant[24];

enum InitializationLevel {
    InitializationLevelCore,
    InitializationLevelServers,
    InitializationLevelScene,
    InitializationLevelEditor,
    InitializationLevelMax,
};

typedef void* (*ExtensionInterfaceGetProcAddress)(char* function_name);
typedef void (*InitializeProc)(void* user_data, GDExtensionInitializationLevel level);

typedef struct {
    enum InitializationLevel minimum_initialization_level;
    void* user_data;
    InitializeProc initialize;
    InitializeProc deinitialize;
} Initialization;

extern GDExtensionInterfaceMemAlloc gd_alloc;
extern GDExtensionInterfaceMemFree gd_free;
extern GDExtensionInterfaceGetProcAddress ext_get_proc_address;
extern GDExtensionClassLibraryPtr ext_library;
extern GDExtensionInterfaceStringNameNewWithLatin1Chars string_name_new_with_latin1_chars;
extern GDExtensionInterfaceStringNewWithLatin1Chars string_new_with_latin1_chars;
extern GDExtensionInterfaceClassdbGetMethodBind classdb_get_method_bind;
extern GDExtensionInterfaceGlobalGetSingleton global_get_singleton;
extern GDExtensionInterfaceClassdbConstructObject classdb_construct_object;
extern GDExtensionInterfaceObjectSetInstance object_set_instance;
extern GDExtensionInterfaceObjectSetInstanceBinding object_set_instance_binding;
extern GDExtensionInterfaceClassdbRegisterExtensionClass3 classdb_register_extension_class3;
extern GDExtensionInterfaceObjectMethodBindPtrcall object_method_bind_ptrcall;

// constructors
extern GDExtensionPtrConstructor node_path_from_string;

// hashes & method binds
extern const GDExtensionInt get_node_hash;
extern GDExtensionMethodBindPtr get_node_method_bind;

// operators
extern GDExtensionPtrOperatorEvaluator StringName_eq_StringName_op;

// helpers
GDExtensionBool call_builtin_op_bool(GDExtensionPtrOperatorEvaluator op, GDExtensionConstTypePtr a, GDExtensionConstTypePtr b);
void print_object(GDExtensionTypePtr object);

// string_name_new_with_latin1_chars = cast(ExtensionInterfaceStringNameNewWithLatin1Chars)get_proc_address("string_name_new_with_latin1_chars")


// InitializationLevel :: enum {
//     Core,
//     Servers,
//     Scene,
//     Editor,
//     Max,
// }
// ExtensionInterfaceGetProcAddress :: #type proc "c" (function_name: cstring) -> rawptr
// ExtensionClassLibraryPtr :: distinct rawptr
// Initialization :: struct {
//     minimum_initialization_level: InitializationLevel,
//     user_data:                    rawptr,
//     initialize:                   proc "c" (user_data: rawptr, level: InitializationLevel),
//     deinitialize:                 proc "c" (user_data: rawptr, level: InitializationLevel),
// }

typedef void*(*InterfaceGetProcAddress)(const char* function_name);

enum InitializationLevel {
    InitializationLevelCore = 0,
    InitializationLevelServers = 1,
    InitializationLevelScene = 2,
    InitializationLevelEditor = 3,
    InitializationLevelMax = 4,
};

struct Initialization {
    enum InitializationLevel minimum_initialization_level;
    void*                    user_data;
    void (*initialize)  (void* user_data, enum InitializationLevel level);
    void (*deinitialize)(void* user_data, enum InitializationLevel level);
};

void __cdecl initialize_example_module(void* user_data, enum InitializationLevel level)
{
    if (level != InitializationLevelScene)
    {
        return;
    }
}

void __cdecl deinitialize_example_module(void* user_data, enum InitializationLevel level)
{
    if (level != InitializationLevelScene)
    {
        return;
    }
}

__declspec(dllexport) int __cdecl example_library_init(
    InterfaceGetProcAddress get_proc_address,
    void* library,
    struct Initialization* initialization)
{
    initialization->initialize = &initialize_example_module;
    initialization->deinitialize = &deinitialize_example_module;
    return 1;
}

package test

import "godot:gdext"

// see gdext.InitializationFunction
@(export)
tests_library_init :: proc "c" (
    get_proc_address: gdext.ExtensionInterfaceGetProcAddress,
    library: gdext.ExtensionClassLibraryPtr,
    initialization: ^gdext.Initialization,
) -> bool {
    gdext.init(library, get_proc_address)

    initialization.initialize = init_module
    initialization.deinitialize = uninit_module
    initialization.user_data = nil
    initialization.minimum_initialization_level = .Scene

    return true
}

init_module :: proc "c" (user_data: rawptr, level: gdext.InitializationLevel) {
    context = gdext.godot_context()

    if level != .Scene {
        return
    }

    test_class_register()
}

uninit_module :: proc "c" (user_data: rawptr, level: gdext.InitializationLevel) {
    context = gdext.godot_context()

    if level != .Scene {
        return
    }
}
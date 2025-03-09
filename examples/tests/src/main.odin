package test

import gd "godot:gdextension"
import var "godot:variant"
import "core:strings"
import "core:c"
import "core:fmt"

// see gd.InitializationFunction
@(export)
tests_library_init :: proc "c" (
    get_proc_address: gd.ExtensionInterfaceGetProcAddress,
    library: gd.ExtensionClassLibraryPtr,
    initialization: ^gd.Initialization,
) -> bool {
    gd.init(library, get_proc_address)

    initialization.initialize = init_module
    initialization.deinitialize = uninit_module
    initialization.user_data = nil
    initialization.minimum_initialization_level = .Scene

    return true
}

init_module :: proc "c" (user_data: rawptr, level: gd.InitializationLevel) {
    context = gd.godot_context()

    if level != .Scene {
        return
    }

    test_class_register()
}

uninit_module :: proc "c" (user_data: rawptr, level: gd.InitializationLevel) {
    context = gd.godot_context()

    if level != .Scene {
        return
    }
}
package example

import gd "../../../gdextension"
import var "../../../variant"
import core "../../../core"
import "core:strings"
import "core:c"
import "core:fmt"

// see gd.InitializationFunction
@(export)
example_library_init :: proc "c" (
    get_proc_address: gd.ExtensionInterfaceGetProcAddress,
    library: gd.ExtensionClassLibraryPtr,
    initialization: ^gd.Initialization,
) -> bool {
    gd.library = library
    // gdextension procs MUST be initialized before using the binding!
    gd.initialize_procs(get_proc_address)

    // MUST be called before using any global scope utility functions in core
    core.init_utility_functions()

    // MUST be called before using any variant types
    var.init()

    initialization.initialize = initialize_example_module
    initialization.deinitialize = uninitialize_example_module
    initialization.user_data = nil
    initialization.minimum_initialization_level = .Scene

    return true
}

initialize_example_module :: proc "c" (user_data: rawptr, level: gd.InitializationLevel) {
    context = gd.godot_context()

    if level != .Scene {
        return
    }

    example_class_register()
}

uninitialize_example_module :: proc "c" (user_data: rawptr, level: gd.InitializationLevel) {
    context = gd.godot_context()

    if level != .Scene {
        return
    }
}
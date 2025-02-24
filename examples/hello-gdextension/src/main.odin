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
    gd.initialize_procs(get_proc_address)
    context = gd.godot_context()

    // TODO: we need to init all types, e.g.:
    var.__StringName_init()
    var.__String_init()

    core.init_utility_functions()

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
package game

import "godot:godot"
import "godot:gdext"

@(export)
game_init :: proc "c" (
    get_proc_address: gdext.ExtensionInterfaceGetProcAddress,
    library: gdext.ExtensionClassLibraryPtr,
    initialization: ^gdext.Initialization,
) -> bool {
    gdext.init(library, get_proc_address)
    godot.init()

    initialization.initialize = initialize_game_module
    initialization.deinitialize = uninitialize_game_module
    initialization.user_data = nil
    initialization.minimum_initialization_level = .Core

    return true
}

initialize_game_module :: proc "c" (user_data: rawptr, level: gdext.InitializationLevel) {
    if level != .Scene {
        return
    }

    context = gdext.godot_context()

    player_class_register()
}

uninitialize_game_module :: proc "c" (user_data: rawptr, level: gdext.InitializationLevel) {
    if level != .Scene {
        return
    }

    player_class_unregister()
}

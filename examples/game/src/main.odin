package game

import "godot:core"
import "godot:core/init"
import gd "godot:gdextension"
import var "godot:variant"
import "core:strings"
import "core:c"
import "core:fmt"

@(export)
game_init :: proc "c" (
    get_proc_address: gd.ExtensionInterfaceGetProcAddress,
    library: gd.ExtensionClassLibraryPtr,
    initialization: ^gd.Initialization,
) -> bool {
    gd.init(library, get_proc_address)
    init.init()

    initialization.initialize = initialize_game_module
    initialization.deinitialize = uninitialize_game_module
    initialization.user_data = nil
    initialization.minimum_initialization_level = .Core

    return true
}

initialize_game_module :: proc "c" (user_data: rawptr, level: gd.InitializationLevel) {
    if level != .Scene {
        return
    }

    context = gd.godot_context()

    player_class_register()
}

uninitialize_game_module :: proc "c" (user_data: rawptr, level: gd.InitializationLevel) {
    if level != .Scene {
        return
    }

    player_class_unregister()
}

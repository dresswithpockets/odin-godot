package game

import gd "../../../gdextension"
import var "../../../variant"
import core "../../../core"
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
    var.init()

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

    core.init()
    player_class_register()
}

uninitialize_game_module :: proc "c" (user_data: rawptr, level: gd.InitializationLevel) {
    if level != .Scene {
        return
    }
}

package example

import gd "../gdinterface"
import core "../core"

@(export)
example_init :: proc "c" (
    interface: ^gd.Interface,
    library: gd.ExtensionClassLibraryPtr,
    initialization: ^gd.Initialization,
) -> bool {
    // do usual initialization

    core.interface = interface
    context = core.godot_context()

    message: cstring = "Hello from Odin!"
    interface.print_warning(message, nil, nil, -1, false)
    return true
}

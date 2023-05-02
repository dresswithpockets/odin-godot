package example

import gd "../gdinterface"
import core "../core"
import var "../variant"

@(export)
example_init :: proc "c" (
    interface: ^gd.Interface,
    library: gd.ExtensionClassLibraryPtr,
    initialization: ^gd.Initialization,
) -> bool {
    // do usual initialization


    core.interface = interface
    core.library = library

    initialization.initialize = initialize_example_module
    initialization.deinitialize = uninitialize_example_module
    initialization.minimum_initialization_level = .Core
    
    return true
}

initialize_example_module :: proc "c" (user_data: rawptr, level: gd.InitializationLevel) {
    context = core.godot_context()

    if level == .Core {
        core.interface.print_warning("variant_get_ptr_constructor(StringName, 0)", nil, nil, -1, true)
        string_name_constructor := core.interface.variant_get_ptr_constructor(gd.VariantType.StringName, 0)

        core.interface.print_warning("variant_get_ptr_destructor(StringName)", nil, nil, -1, true)
        string_name_destructor := core.interface.variant_get_ptr_destructor(gd.VariantType.StringName)

        core.interface.print_warning("invoking string_name_constructor", nil, nil, -1, true)
        string_name := var.StringName{}
        string_name_constructor(cast(gd.TypePtr)&string_name._opaque, nil)

        core.interface.print_warning("invoking string_name_destructor", nil, nil, -1, true)
        string_name_destructor(cast(gd.TypePtr)&string_name._opaque)

        core.interface.print_warning("new_string_name_default", nil, nil, -1, true)
        name := var.new_string_name_cstring("ExampleClass")
        
        class_info := gd.ExtensionClassCreationInfo{}
        core.interface.print_warning("classdb_register_extension_class", nil, nil, -1, true)
        core.interface.classdb_register_extension_class(core.library, cast(gd.StringNamePtr)&name._opaque, nil, &class_info)
        // core.interface.print_warning("free_string_name", nil, nil, -1, true)
        // string_name_destructor(cast(gd.TypePtr)&name._opaque)
    }
    
    // core.interface.classdb_register_extension_class(core.library, cast(gd.StringNamePtr)&name._opaque, nil, nil)

}

uninitialize_example_module :: proc "c" (user_data: rawptr, level: gd.InitializationLevel) {
    context = core.godot_context()

    if level == .Core {
        core.interface.print_warning("new_string_name_default", nil, nil, -1, true)
        name := var.new_string_name_cstring("ExampleClass")
        
        core.interface.print_warning("classdb_register_extension_class", nil, nil, -1, true)
        core.interface.classdb_register_extension_class(core.library, cast(gd.StringNamePtr)&name._opaque, nil, nil)
    }
}

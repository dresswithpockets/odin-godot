package example

import gd "../../gdextension"
import var "../../variant"



// TODO: add class gen
// TODO: add static method gen
// TODO: add method gen
// TODO: add property get gen
// TODO: add property set gen
// TODO: add property get+set gen
// TODO: add enum gen

//+class ExampleClass extends Sprite2D
ExampleClass :: struct {
    _owner: gd.ObjectPtr,

    thing: i64,
    
    // +signal(ExampleClass) on_thing(a: String, b: ExampleClass)
    // +group(ExampleClass) Test group: group_
    // +subgroup(ExampleClass) Test subgroup: group_subgroup_
}

// +static method(ExampleClass) do_thing_static(a: int, b: int) -> int
example_class_do_thing_static :: proc(a, b: i64) -> i64 {
    return a + b
}

// +method(ExampleClass) do_thing()
example_class_do_thing :: proc(self: ^ExampleClass) {
    self.thing -= 50
}

// +property(ExampleClass) thing get: int
example_class_get_thing :: proc(self: ^ExampleClass) -> i64 {
    return self.thing
}

// +property(ExampleClass) thing set: int
example_class_set_thing :: proc(self: ^ExampleClass, value: i64) {
    self.thing = value
}

// +enum(ExampleClass) ExampleEnum
ExampleEnum :: enum {
    A,
    B,
    C,
    D,
}



@(export)
example_library_init :: proc "c" (
    interface: ^gd.Interface,
    library: gd.ExtensionClassLibraryPtr,
    initialization: ^gd.Initialization,
) -> bool {
    // do usual initialization
    gd.interface = interface
    gd.library = library

    context = gd.godot_context()
    var.init_string_constructors()
    var.init_string_name_constructors()
    var.init_string_bindings()
    var.init_string_name_bindings()

    initialization.initialize = initialize_example_module
    initialization.deinitialize = uninitialize_example_module
    initialization.minimum_initialization_level = .Core

    return true
}

initialize_example_module :: proc "c" (user_data: rawptr, level: gd.InitializationLevel) {
    context = gd.godot_context()

    if level != .Scene {
        return
    }

    init_example_class_bindings()
}

uninitialize_example_module :: proc "c" (user_data: rawptr, level: gd.InitializationLevel) {
    context = gd.godot_context()

    if level != .Scene {
        return
    }
    
}

// initialize_example_module :: proc "c" (user_data: rawptr, level: gd.InitializationLevel) {
//     context = gd.godot_context()

//     if level != .Scene {
//         return
//     }

//     class_name := var.new_string_name_cstring("ExampleClass")
//     parent_name := var.new_string_name_cstring("Node2D")

//     class_info := gd.ExtensionClassCreationInfo {
//         is_virtual               = false,
//         is_abstract              = false,
//         set_func                 = example_class_set,
//         get_func                 = example_class_get,
//         get_property_list_func   = example_class_get_property_list,
//         free_property_list_func  = example_class_free_property_list,
//         property_can_revert_func = example_class_property_can_revert,
//         property_get_revert_func = example_class_property_get_revert,
//         notification_func        = example_class_notification_func,
//         to_string_func           = example_class_to_string,
//         reference_func           = nil,
//         unreference_func         = nil,
//         create_instance_func     = example_class_create,
//         free_instance_func       = example_class_free,
//         get_virtual_func         = class_db_get_virtual_func,
//         get_rid_func             = nil,
//         class_user_data          = nil,
//     }
//     gd.interface.classdb_register_extension_class(
//         gd.library,
//         cast(gd.StringNamePtr)&class_name._opaque,
//         cast(gd.StringNamePtr)&parent_name._opaque,
//         &class_info,
//     )
// }

// uninitialize_example_module :: proc "c" (user_data: rawptr, level: gd.InitializationLevel) {
//     context = gd.godot_context()

//     if level != .Scene {
//         return
//     }

//     class_name := var.new_string_name_cstring("ExampleClass")
//     gd.interface.classdb_unregister_extension_class(gd.library, cast(gd.StringNamePtr)&class_name)
// }

// example_class_set :: proc "c" (
//     instance: gd.ExtensionClassInstancePtr,
//     name: gd.StringNamePtr,
//     value: gd.VariantPtr,
// ) -> bool {
//     context = gd.godot_context()
//     return false
// }

// example_class_get :: proc "c" (
//     instance: gd.ExtensionClassInstancePtr,
//     name: gd.StringNamePtr,
//     ret: gd.VariantPtr,
// ) -> bool {
//     context = gd.godot_context()
//     return false
// }

// example_class_get_property_list :: proc "c" (
//     instance: gd.ExtensionClassInstancePtr,
//     count: ^u32,
// ) -> [^]gd.PropertyInfo {
//     context = gd.godot_context()
//     return nil
// }

// example_class_free_property_list :: proc "c" (instance: gd.ExtensionClassInstancePtr, list: ^gd.PropertyInfo) {
//     context = gd.godot_context()

// }

// example_class_property_can_revert :: proc "c" (
//     instance: gd.ExtensionClassInstancePtr,
//     name: gd.StringNamePtr,
// ) -> bool {
//     context = gd.godot_context()
//     return false
// }

// example_class_property_get_revert :: proc "c" (
//     instance: gd.ExtensionClassInstancePtr,
//     name: gd.StringNamePtr,
//     ret: gd.VariantPtr,
// ) -> bool {
//     context = gd.godot_context()
//     return false
// }

// example_class_notification_func :: proc "c" (instance: gd.ExtensionClassInstancePtr, what: i32) {
//     context = gd.godot_context()
// }

// example_class_to_string :: proc "c" (instance: gd.ExtensionClassInstancePtr, is_valid: ^bool, out: gd.StringPtr) {
//     context = gd.godot_context()
// }

// example_class_create :: proc "c" (user_data: rawptr) -> gd.ObjectPtr {
//     context = gd.godot_context()
//     return nil
// }

// example_class_free :: proc "c" (user_data: rawptr, instance: gd.ExtensionClassInstancePtr) {
//     context = gd.godot_context()
// }

// class_db_get_virtual_func :: proc "c" (user_data: rawptr, name: gd.StringNamePtr) -> gd.ExtensionClassCallVirtual {
//     context = gd.godot_context()
//     return nil
// }

package test

import gd "godot:gdextension"
import "godot:gdextension/bind"
import var "godot:variant"

@(private = "file")
test_class_name: var.String_Name

@(private = "file")
node_class_name: var.String_Name

@(private = "file")
object_class_name: var.String_Name

Test_Class :: struct {
    object: gd.ObjectPtr,
    vector: var.Vector2,
}

@(private = "file")
set_vector :: proc "contextless" (self: ^Test_Class, vector: var.Vector2) {
    self.vector = vector
}

@(private = "file")
get_vector :: proc "contextless" (self: ^Test_Class) -> var.Vector2 {
    return self.vector
}

@(private = "file")
vector_eq :: proc "contextless" (self: ^Test_Class, other: var.Vector2) -> bool {
    return self.vector == other
}

@(private = "file")
vector_neq :: proc "contextless" (self: ^Test_Class, other: var.Vector2) -> bool {
    return self.vector != other
}

@(private = "file")
vector_add :: proc "contextless" (self: ^Test_Class, other: var.Vector2) -> var.Vector2 {
    return self.vector + other
}

@(private = "file")
vector_sub :: proc "contextless" (self: ^Test_Class, other: var.Vector2) -> var.Vector2 {
    return self.vector - other
}

@(private = "file")
get_virtual_with_data :: proc "c" (class_user_data: rawptr, name: gd.StringNamePtr) -> rawptr {
    return nil
}

@(private = "file")
call_virtual_with_data :: proc "c" (
    instance: gd.ExtensionClassInstancePtr,
    name: gd.StringNamePtr,
    virtual_call_user_data: rawptr,
    args: [^]gd.TypePtr,
    ret: gd.TypePtr,
) {}

@(private = "file")
binding_callbacks := gd.InstanceBindingCallbacks{}

@(private = "file")
create_instance :: proc "c" (class_user_data: rawptr) -> gd.ObjectPtr {
    context = gd.godot_context()

    object := gd.classdb_construct_object(&node_class_name)

    self := new(Test_Class)
    self.object = object

    gd.object_set_instance(object, &test_class_name, self)
    gd.object_set_instance_binding(object, gd.library, self, &binding_callbacks)

    return object
}

@(private = "file")
free_instance :: proc "c" (class_user_data: rawptr, instance: gd.ExtensionClassInstancePtr) {
    context = gd.godot_context()

    if instance == nil {
        return
    }

    self := cast(^Test_Class)instance
    free(self)
}

test_class_register :: proc() {
    test_class_name = var.new_string_name_cstring("Test", true)
    node_class_name = var.new_string_name_cstring("Node", true)
    object_class_name = var.new_string_name_cstring("Object", true)

    class_info := gd.ExtensionClassCreationInfo2 {
        is_virtual                  = false,
        is_abstract                 = false,
        is_exposed                  = true,
        set_func                    = nil,
        get_func                    = nil,
        get_property_list_func      = nil,
        free_property_list_func     = nil,
        property_can_revert_func    = nil,
        property_get_revert_func    = nil,
        validate_property_func      = nil,
        notification_func           = nil,
        to_string_func              = nil,
        reference_func              = nil,
        unreference_func            = nil,
        create_instance_func        = create_instance,
        free_instance_func          = free_instance,
        recreate_instance_func      = nil,
        get_virtual_func            = nil,
        get_virtual_call_data_func  = get_virtual_with_data,
        call_virtual_with_data_func = call_virtual_with_data,
        get_rid_func                = nil,
        class_userdata              = nil,
    }

    gd.classdb_register_extension_class2(gd.library, &test_class_name, &node_class_name, &class_info)

    get_vector_name := var.new_string_name_cstring("get_vector", true)
    set_vector_name := var.new_string_name_cstring("set_vector", true)
    vector_name := var.new_string_name_cstring("vector", true)
    bind.bind_property_and_methods(
        &test_class_name,
        &vector_name,
        &get_vector_name,
        &set_vector_name,
        get_vector,
        set_vector,
    )

    other_name := var.new_string_name_cstring("other", true)
    vector_eq_name := var.new_string_name_cstring("vector_eq", true)
    bind.bind_returning_method(&test_class_name, &vector_eq_name, vector_eq, &other_name)

    vector_neq_name := var.new_string_name_cstring("vector_neq", true)
    bind.bind_returning_method(&test_class_name, &vector_neq_name, vector_neq, &other_name)

    vector_add_name := var.new_string_name_cstring("vector_add", true)
    bind.bind_returning_method(&test_class_name, &vector_add_name, vector_add, &other_name)

    vector_sub_name := var.new_string_name_cstring("vector_sub", true)
    bind.bind_returning_method(&test_class_name, &vector_sub_name, vector_sub, &other_name)
}

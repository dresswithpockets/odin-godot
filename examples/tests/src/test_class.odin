package test

import "godot:gdext"
import "godot:libgd/classdb"
import "godot:godot"

@(private = "file")
test_class_name: godot.String_Name

@(private = "file")
node_class_name: godot.String_Name

@(private = "file")
object_class_name: godot.String_Name

Test_Class :: struct {
    object: gdext.ObjectPtr,
    vector: godot.Vector2,
}

@(private = "file")
set_vector :: proc "contextless" (self: ^Test_Class, vector: godot.Vector2) {
    self.vector = vector
}

@(private = "file")
get_vector :: proc "contextless" (self: ^Test_Class) -> godot.Vector2 {
    return self.vector
}

@(private = "file")
vector_eq :: proc "contextless" (self: ^Test_Class, other: godot.Vector2) -> bool {
    return self.vector == other
}

@(private = "file")
vector_neq :: proc "contextless" (self: ^Test_Class, other: godot.Vector2) -> bool {
    return self.vector != other
}

@(private = "file")
vector_add :: proc "contextless" (self: ^Test_Class, other: godot.Vector2) -> godot.Vector2 {
    return self.vector + other
}

@(private = "file")
vector_sub :: proc "contextless" (self: ^Test_Class, other: godot.Vector2) -> godot.Vector2 {
    return self.vector - other
}

@(private = "file")
get_virtual_with_data :: proc "c" (class_user_data: rawptr, name: gdext.StringNamePtr) -> rawptr {
    return nil
}

@(private = "file")
call_virtual_with_data :: proc "c" (
    instance: gdext.ExtensionClassInstancePtr,
    name: gdext.StringNamePtr,
    virtual_call_user_data: rawptr,
    args: [^]gdext.TypePtr,
    ret: gdext.TypePtr,
) {}

@(private = "file")
binding_callbacks := gdext.InstanceBindingCallbacks{}

@(private = "file")
create_instance :: proc "c" (class_user_data: rawptr) -> gdext.ObjectPtr {
    context = gdext.godot_context()

    object := gdext.classdb_construct_object(&node_class_name)

    self := new(Test_Class)
    self.object = object

    gdext.object_set_instance(object, &test_class_name, self)
    gdext.object_set_instance_binding(object, gdext.library, self, &binding_callbacks)

    return object
}

@(private = "file")
free_instance :: proc "c" (class_user_data: rawptr, instance: gdext.ExtensionClassInstancePtr) {
    context = gdext.godot_context()

    if instance == nil {
        return
    }

    self := cast(^Test_Class)instance
    free(self)
}

test_class_register :: proc() {
    test_class_name = godot.new_string_name_cstring("Test", true)
    node_class_name = godot.new_string_name_cstring("Node", true)
    object_class_name = godot.new_string_name_cstring("Object", true)

    class_info := gdext.ExtensionClassCreationInfo2 {
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

    gdext.classdb_register_extension_class2(gdext.library, &test_class_name, &node_class_name, &class_info)

    get_vector_name := godot.new_string_name_cstring("get_vector", true)
    set_vector_name := godot.new_string_name_cstring("set_vector", true)
    vector_name := godot.new_string_name_cstring("vector", true)
    classdb.bind_property_and_methods(
        &test_class_name,
        &vector_name,
        &get_vector_name,
        &set_vector_name,
        get_vector,
        set_vector,
    )

    other_name := godot.new_string_name_cstring("other", true)
    vector_eq_name := godot.new_string_name_cstring("vector_eq", true)
    classdb.bind_returning_method(&test_class_name, &vector_eq_name, vector_eq, &other_name)

    vector_neq_name := godot.new_string_name_cstring("vector_neq", true)
    classdb.bind_returning_method(&test_class_name, &vector_neq_name, vector_neq, &other_name)

    vector_add_name := godot.new_string_name_cstring("vector_add", true)
    classdb.bind_returning_method(&test_class_name, &vector_add_name, vector_add, &other_name)

    vector_sub_name := godot.new_string_name_cstring("vector_sub", true)
    classdb.bind_returning_method(&test_class_name, &vector_sub_name, vector_sub, &other_name)
}

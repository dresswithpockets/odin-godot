package example

import gd "../../../gdextension"
import var "../../../variant"

ExampleClass :: struct {
    amplitude: gd.float,
    speed:     gd.float,

    time_emit:   gd.float,
    time_passed: gd.float,
    
    time_passed_signal: var.StringName,

    object: gd.ObjectPtr,
}

example_class_constructor :: proc "c" (self: ^ExampleClass) {
    self.amplitude = 1.0
    self.speed = 1.0
    self.time_passed = 0.0
    self.time_emit = 5.0

    gd.string_name_new_with_latin1_chars(cast(gd.StringNamePtr)&self.time_passed_signal, "time_passed", false)
}

example_class_destructor :: proc "c" (self: ^ExampleClass) {
    var.free_string_name(self.time_passed_signal)
}

example_class_set_amplitude :: proc "c" (self: ^ExampleClass, amplitude: gd.float) {
    self.amplitude = amplitude
}

example_class_get_amplitude :: proc "c" (self: ^ExampleClass) -> gd.float {
    return self.amplitude
}

example_class_set_speed :: proc "c" (self: ^ExampleClass, speed: gd.float) {
    self.speed = speed
}

example_class_get_speed :: proc "c" (self: ^ExampleClass) -> gd.float {
    return self.speed
}

example_class_process :: proc "c" (self: ^ExampleClass, delta: gd.float) {
    self.time_passed += self.speed * delta

    if self.time_passed >= self.time_emit {
        example_class_emit_time_passed(self, self.time_passed)
        self.time_passed -= self.time_emit
    }
}

example_class_emit_time_passed :: proc "contextless" (self: ^ExampleClass, time_passed: gd.float) {
    object_name := var.StringName{}
    gd.string_name_new_with_latin1_chars(cast(gd.StringNamePtr)&object_name, "Object", false)
    defer var.free_string_name(object_name)

    method_name := var.StringName{}
    gd.string_name_new_with_latin1_chars(cast(gd.StringNamePtr)&method_name, "emit_signal", false)
    defer var.free_string_name(method_name)

    object_emit_signal := gd.classdb_get_method_bind(cast(gd.StringNamePtr)&object_name, cast(gd.StringNamePtr)&method_name, 4047867050)

    variant_from_string_name := gd.get_variant_from_type_constructor(.StringName)
    signal_name_argument := var.Variant{}
    variant_from_string_name(cast(gd.UninitializedVariantPtr)&signal_name_argument, cast(gd.TypePtr)&self.time_passed_signal)
    
    variant_from_float := gd.get_variant_from_type_constructor(.Float)
    time_passed_argument := var.Variant{}
    variant_from_float(cast(gd.UninitializedVariantPtr)&time_passed_argument, cast(gd.TypePtr)&self.time_passed)

    args := [2]gd.VariantPtr{
        cast(gd.VariantPtr)&signal_name_argument,
        cast(gd.VariantPtr)&time_passed_argument,
    }

    ret := var.Variant{}
    gd.object_method_bind_call(object_emit_signal, self.object, &args[0], 2, cast(gd.VariantPtr)&ret, nil)
    defer gd.variant_destroy(cast(gd.VariantPtr)&ret)

    //gd.call_method_ptr_no_ret(object_emit_signal, self.object, cast(gd.TypePtr)&signal_name_argument, cast(gd.TypePtr)&time_passed_argument)
}

example_class_get_virtual_with_data :: proc "c" (class_user_data: rawptr, name: gd.StringNamePtr) -> rawptr {
    process_string_name := var.StringName{}
    gd.string_name_new_with_latin1_chars(cast(gd.StringNamePtr)&process_string_name, "_process", false)
    defer var.free_string_name(process_string_name)

    name_string_name := cast(^var.StringName)name
    if var.string_name_equal(name_string_name^, process_string_name) {
        return cast(rawptr)example_class_process
    }

    return nil
}

example_class_call_virtual_with_data :: proc "c" (instance: gd.ExtensionClassInstancePtr, name: gd.StringNamePtr, virtual_call_user_data: rawptr, args: [^]gd.TypePtr, ret: gd.TypePtr) {
    if virtual_call_user_data == cast(rawptr)example_class_process {
        ptrcall_setter_float(virtual_call_user_data, instance, args, ret)
    }
}

example_class_bind_methods :: proc() {
    bind_method_return("ExampleClass", "get_amplitude", cast(rawptr)example_class_get_amplitude, .Float, call_getter_float, ptrcall_getter_float)
    bind_method_no_return("ExampleClass", "set_amplitude", cast(rawptr)example_class_set_amplitude, call_setter_float, ptrcall_setter_float, MethodBindArgument{ name = "amplitude", type = .Float })
    bind_property("ExampleClass", "amplitude", .Float, "get_amplitude", "set_amplitude")

    bind_method_return("ExampleClass", "get_speed", cast(rawptr)example_class_get_speed, .Float, call_getter_float, ptrcall_getter_float)
    bind_method_no_return("ExampleClass", "set_speed", cast(rawptr)example_class_set_speed, call_setter_float, ptrcall_setter_float, MethodBindArgument{ name = "speed", type = .Float })
    bind_property("ExampleClass", "speed", .Float, "get_speed", "set_speed")

    bind_signal("ExampleClass", "time_passed", MethodBindArgument { name = "time_passed", type = .Float })
}

example_class_binding_callbacks := gd.InstanceBindingCallbacks{
    create = nil,
    free = nil,
    reference = nil,
}

example_class_create_instance :: proc "c" (class_user_data: rawptr) -> gd.ObjectPtr {
    context = gd.godot_context()

    class_name := var.StringName{}
    gd.string_name_new_with_latin1_chars(cast(gd.StringNamePtr)&class_name, "Sprite2D", false)
    object := gd.classdb_construct_object(cast(gd.StringNamePtr)&class_name)
    var.free_string_name(class_name)
    
    self := new(ExampleClass)
    example_class_constructor(self)
    self.object = object

    gd.string_name_new_with_latin1_chars(cast(gd.StringNamePtr)&class_name, "ExampleClass", false)
    gd.object_set_instance(object, cast(gd.StringNamePtr)&class_name, cast(gd.ExtensionClassInstancePtr)self)
    gd.object_set_instance_binding(object, gd.library, self, &example_class_binding_callbacks)
    var.free_string_name(class_name)

    return object
}

example_class_free_instance :: proc "c" (class_user_data: rawptr, instance: gd.ExtensionClassInstancePtr) {
    context = gd.godot_context()

    if instance == nil {
        return
    }

    self := cast(^ExampleClass)instance
    example_class_destructor(self)
    free(self)
}

example_class_register :: proc "c" () {
    context = gd.godot_context()

    class_name := var.StringName{}
    gd.string_name_new_with_latin1_chars(cast(gd.StringNamePtr)&class_name, "ExampleClass", false)
    parent_class_name := var.StringName{}
    gd.string_name_new_with_latin1_chars(cast(gd.StringNamePtr)&parent_class_name, "Sprite2D", false)
    
    class_info := gd.ExtensionClassCreationInfo2{
        is_virtual = false,
        is_abstract = false,
        is_exposed = true,
        set_func = nil,
        get_func = nil,
        get_property_list_func = nil,
        free_property_list_func = nil,
        property_can_revert_func = nil,
        property_get_revert_func = nil,
        validate_property_func = nil,
        notification_func = nil,
        to_string_func = nil,
        reference_func = nil,
        unreference_func = nil,
        create_instance_func = example_class_create_instance,
        free_instance_func = example_class_free_instance,
        recreate_instance_func = nil,
        get_virtual_func = nil,
        get_virtual_call_data_func = example_class_get_virtual_with_data,
        call_virtual_with_data_func = example_class_call_virtual_with_data,
        get_rid_func = nil,
        class_userdata = nil,
    }

    gd.classdb_register_extension_class2(
        gd.library,
        cast(gd.StringNamePtr)&class_name,
        cast(gd.StringNamePtr)&parent_class_name,
        &class_info)
    
    example_class_bind_methods()

    var.free_string_name(class_name)
    var.free_string_name(parent_class_name)
}
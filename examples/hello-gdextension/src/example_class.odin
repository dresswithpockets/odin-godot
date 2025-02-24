package example

import gd "../../../gdextension"
import var "../../../variant"

ExampleClass :: struct {
    amplitude: f64,
    speed:     f64,

    object: gd.ObjectPtr,
}

example_class_constructor :: proc "c" (self: ^ExampleClass) {
    self.amplitude = 1.0
    self.speed = 1.0
}

example_class_destructor :: proc "c" (self: ^ExampleClass) {

}

GetterFloat :: proc "c" (instance: rawptr) -> gd.float
SetterFloat :: proc "c" (instance: rawptr, value: gd.float)

ptrcall_getter_float :: proc "c" (method_user_data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, call_return: gd.TypePtr) {
    method := cast(GetterFloat)method_user_data
    (cast(^gd.float)call_return)^ = method(instance)
}

ptrcall_setter_float :: proc "c" (method_user_data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.TypePtr, call_return: gd.TypePtr) {
    method := cast(SetterFloat)method_user_data
    method(instance, (cast(^gd.float)args[0])^)
}

call_getter_float :: proc "c" (method_user_data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.VariantPtr, arg_count: i64, call_return: gd.VariantPtr, error: ^gd.CallError) {
    if arg_count != 0 {
        error.error = .TooManyArguments
        error.expected = 0
        return
    }
    
    method := cast(GetterFloat)method_user_data
    result := method(instance)
    var_float_constructor := gd.get_variant_from_type_constructor(.Float)
    var_float_constructor(cast(gd.UninitializedVariantPtr)call_return, cast(gd.TypePtr)&result)
}

call_setter_float :: proc "c" (method_user_data: rawptr, instance: gd.ExtensionClassInstancePtr, args: [^]gd.VariantPtr, arg_count: i64, call_return: gd.VariantPtr, error: ^gd.CallError) {
    if arg_count < 1 {
        error.error = .TooFewArguments
        error.expected = 1
        return
    }

    if arg_count > 1 {
        error.error = .TooManyArguments
        error.expected = 1
        return
    }

    type := gd.variant_get_type(args[0])
    if type != .Float {
        error.error = .InvalidArgument
        error.expected = cast(i32)gd.VariantType.Float
        error.argument = 0
        return
    }

    arg1: f64
    float_from_var_constructor := gd.get_variant_to_type_constructor(.Float)
    float_from_var_constructor(cast(gd.TypePtr)&arg1, args[0])

    method := cast(SetterFloat)method_user_data
    method(instance, arg1)
}

example_class_set_amplitude :: proc "c" (self: ^ExampleClass, amplitude: f64) {
    self.amplitude = amplitude
}

example_class_get_amplitude :: proc "c" (self: ^ExampleClass) -> gd.float {
    return self.amplitude
}

example_class_set_speed :: proc "c" (self: ^ExampleClass, speed: f64) {
    self.speed = speed
}

example_class_get_speed :: proc "c" (self: ^ExampleClass) -> f64 {
    return self.speed
}

example_class_bind_methods :: proc() {
    bind_method_return("ExampleClass", "get_amplitude", cast(rawptr)example_class_get_amplitude, .Float, call_getter_float, ptrcall_getter_float)
    bind_method_no_return("ExampleClass", "set_amplitude", cast(rawptr)example_class_set_amplitude, call_setter_float, ptrcall_setter_float, MethodBindArgument{ name = "amplitude", type = .Float })

    bind_method_return("ExampleClass", "get_speed", cast(rawptr)example_class_get_speed, .Float, call_getter_float, ptrcall_getter_float)
    bind_method_no_return("ExampleClass", "set_speed", cast(rawptr)example_class_set_speed, call_setter_float, ptrcall_setter_float, MethodBindArgument{ name = "speed", type = .Float })
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

    // TODO: destructors
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
        get_virtual_call_data_func = nil,
        call_virtual_with_data_func = nil,
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
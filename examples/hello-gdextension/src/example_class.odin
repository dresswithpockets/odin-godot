package example

import gd "godot:gdextension"
import var "godot:variant"

ExampleClassString_Name := var.String_Name{}
ObjectClassString_Name := var.String_Name{}
Sprite2DClassString_Name := var.String_Name{}
ProcessVirtualString_Name := var.String_Name{}
TimePassedSignalString_Name := var.String_Name{}
EmitSignalMethodString_Name := var.String_Name{}

GetAmplitudeString_Name := var.String_Name{}
SetAmplitudeString_Name := var.String_Name{}
AmplitudeString_Name := var.String_Name{}
GetSpeedString_Name := var.String_Name{}
SetSpeedString_Name := var.String_Name{}
SpeedString_Name := var.String_Name{}
TimePassedString_Name := var.String_Name{}

ExampleClass :: struct {
    amplitude: gd.Float,
    speed:     gd.Float,

    time_emit:   gd.Float,
    time_passed: gd.Float,

    object: gd.ObjectPtr,
}

example_class_constructor :: proc "c" (self: ^ExampleClass) {
    self.amplitude = 1.0
    self.speed = 1.0
    self.time_passed = 0.0
    self.time_emit = 5.0
}

example_class_destructor :: proc "c" (self: ^ExampleClass) {

}

example_class_set_amplitude :: proc "c" (self: ^ExampleClass, amplitude: gd.Float) {
    self.amplitude = amplitude
}

example_class_get_amplitude :: proc "c" (self: ^ExampleClass) -> gd.Float {
    return self.amplitude
}

example_class_set_speed :: proc "c" (self: ^ExampleClass, speed: gd.Float) {
    self.speed = speed
}

example_class_get_speed :: proc "c" (self: ^ExampleClass) -> gd.Float {
    return self.speed
}

example_class_process :: proc "c" (self: ^ExampleClass, delta: gd.Float) {
    self.time_passed += self.speed * delta

    if self.time_passed >= self.time_emit {
        example_class_emit_time_passed(self, self.time_passed)
        self.time_passed -= self.time_emit
    }
}

example_class_emit_time_passed :: proc "contextless" (self: ^ExampleClass, time_passed: gd.Float) {

    object_emit_signal := gd.classdb_get_method_bind(&ObjectClassString_Name, &EmitSignalMethodString_Name, 4047867050)

    signal_name_argument := var.variant_from(&TimePassedSignalString_Name)
    time_passed_argument := var.variant_from(&self.time_passed)

    args := [2]gd.VariantPtr{ &signal_name_argument, &time_passed_argument }

    ret := var.Variant{}
    gd.object_method_bind_call(object_emit_signal, self.object, &args[0], len(args), &ret, nil)
    defer gd.variant_destroy(&ret)
}

example_class_get_virtual_with_data :: proc "c" (class_user_data: rawptr, name: gd.StringNamePtr) -> rawptr {
    name := cast(^var.String_Name)name
    if var.string_name_equal(name^, ProcessVirtualString_Name) {
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
    bind_method_return(&ExampleClassString_Name, &GetAmplitudeString_Name, cast(rawptr)example_class_get_amplitude, .Float, call_getter_float, ptrcall_getter_float)
    bind_method_no_return(&ExampleClassString_Name, &SetAmplitudeString_Name, cast(rawptr)example_class_set_amplitude, call_setter_float, ptrcall_setter_float, MethodBindArgument{ name = &AmplitudeString_Name, type = .Float })
    bind_property(&ExampleClassString_Name, &AmplitudeString_Name, .Float, &GetAmplitudeString_Name, &SetAmplitudeString_Name)

    bind_method_return(&ExampleClassString_Name, &GetSpeedString_Name, cast(rawptr)example_class_get_speed, .Float, call_getter_float, ptrcall_getter_float)
    bind_method_no_return(&ExampleClassString_Name, &SetSpeedString_Name, cast(rawptr)example_class_set_speed, call_setter_float, ptrcall_setter_float, MethodBindArgument{ name = &SpeedString_Name, type = .Float })
    bind_property(&ExampleClassString_Name, &SpeedString_Name, .Float, &GetSpeedString_Name, &SetSpeedString_Name)

    bind_signal(&ExampleClassString_Name, &TimePassedSignalString_Name, MethodBindArgument { name = &TimePassedString_Name, type = .Float })
}

example_class_binding_callbacks := gd.InstanceBindingCallbacks{
    create = nil,
    free = nil,
    reference = nil,
}

example_class_create_instance :: proc "c" (class_user_data: rawptr) -> gd.ObjectPtr {
    context = gd.godot_context()

    object := gd.classdb_construct_object(&Sprite2DClassString_Name)
    
    self := new(ExampleClass)
    example_class_constructor(self)
    self.object = object

    gd.object_set_instance(object, &ExampleClassString_Name, self)
    gd.object_set_instance_binding(object, gd.library, self, &example_class_binding_callbacks)

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

example_class_register :: proc() {
    // we use string_name_new_with_latin1_chars because we know the lifetime of the string literal to be static
    gd.string_name_new_with_latin1_chars(&ExampleClassString_Name, "ExampleClass", true)
    gd.string_name_new_with_latin1_chars(&ObjectClassString_Name, "Object", true)
    gd.string_name_new_with_latin1_chars(&Sprite2DClassString_Name, "Sprite2D", true)
    gd.string_name_new_with_latin1_chars(&ProcessVirtualString_Name, "_process", true)
    gd.string_name_new_with_latin1_chars(&TimePassedSignalString_Name, "time_passed", true)
    gd.string_name_new_with_latin1_chars(&EmitSignalMethodString_Name, "emit_signal", true)
    
    gd.string_name_new_with_latin1_chars(&GetAmplitudeString_Name, "get_amplitude", true)
    gd.string_name_new_with_latin1_chars(&SetAmplitudeString_Name, "set_amplitude", true)
    gd.string_name_new_with_latin1_chars(&AmplitudeString_Name, "amplitude", true)
    gd.string_name_new_with_latin1_chars(&GetSpeedString_Name, "get_speed", true)
    gd.string_name_new_with_latin1_chars(&SetSpeedString_Name, "set_speed", true)
    gd.string_name_new_with_latin1_chars(&SpeedString_Name, "speed", true)
    gd.string_name_new_with_latin1_chars(&TimePassedString_Name, "time_passed", true)
    
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

    gd.classdb_register_extension_class2(gd.library, &ExampleClassString_Name, &Sprite2DClassString_Name, &class_info)

    example_class_bind_methods()
}
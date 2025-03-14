package example

import "godot:gdext"
import "godot:libgd/classdb"
import "godot:godot"

@(private = "file")
example_class_name: godot.String_Name
time_passed_name := godot.String_Name{}
emit_signal_name := godot.String_Name{}

ExampleClass :: struct {
    amplitude:   f64,
    speed:       f64,
    time_emit:   f64,
    time_passed: f64,
    object:      ^godot.Object,
}

set_amplitude :: proc "contextless" (self: ^ExampleClass, amplitude: f64) {
    self.amplitude = amplitude
}

get_amplitude :: proc "contextless" (self: ^ExampleClass) -> f64 {
    return self.amplitude
}

set_speed :: proc "contextless" (self: ^ExampleClass, speed: f64) {
    self.speed = speed

    msg := godot.new_string_cstring("set_speed")
    defer godot.free_string(msg)

    godot.gd_print(godot.variant_from(&msg))
    godot.gd_print(godot.variant_from(&self.speed))
}

get_speed :: proc "contextless" (self: ^ExampleClass) -> f64 {
    return self.speed
}

process :: proc "contextless" (self: ^ExampleClass, delta: f64) {
    self.time_passed += self.speed * delta

    if self.time_passed >= self.time_emit {
        emit_time_passed(self, self.time_passed)
        self.time_passed -= self.time_emit
    }
}

emit_time_passed :: proc "contextless" (self: ^ExampleClass, time_passed: f64) {
    object_emit_signal := gdext.classdb_get_method_bind(
        godot.object_name_ref(),
        &emit_signal_name,
        4047867050,
    )

    signal_name_argument := godot.variant_from(&time_passed_name)
    time_passed_argument := godot.variant_from(&self.time_passed)

    args := [2]gdext.VariantPtr{&signal_name_argument, &time_passed_argument}
    ret := godot.Variant{}
    gdext.object_method_bind_call(object_emit_signal, self.object, &args[0], len(args), &ret, nil)
    defer gdext.variant_destroy(&ret)
}

get_virtual_with_data :: proc "c" (class_user_data: rawptr, name: gdext.StringNamePtr) -> rawptr {
    name := cast(^godot.String_Name)name
    process_name := godot.new_string_name_cstring("_process", true)
    if godot.string_name_equal(name^, process_name) {
        return cast(rawptr)process
    }

    return nil
}

call_virtual_with_data :: proc "c" (
    instance: gdext.ExtensionClassInstancePtr,
    name: gdext.StringNamePtr,
    virtual_call_user_data: rawptr,
    args: [^]gdext.TypePtr,
    ret: gdext.TypePtr,
) {
    if virtual_call_user_data == cast(rawptr)process {
        delta := cast(^f64)args[0]
        process(cast(^ExampleClass)instance, delta^)
    }
}

example_class_binding_callbacks := gdext.InstanceBindingCallbacks {
    create    = nil,
    free      = nil,
    reference = nil,
}

create_instance :: proc "c" (class_user_data: rawptr) -> gdext.ObjectPtr {
    context = gdext.godot_context()

    object := gdext.classdb_construct_object(godot.sprite2d_name_ref())

    self := new_clone(
        ExampleClass {
            object = cast(^godot.Object)object,
            amplitude = 1.0,
            speed = 1.0,
            time_passed = 0.0,
            time_emit = 5.0,
        },
    )

    gdext.object_set_instance(object, &example_class_name, self)
    gdext.object_set_instance_binding(object, gdext.library, self, &example_class_binding_callbacks)

    return object
}

free_instance :: proc "c" (class_user_data: rawptr, instance: gdext.ExtensionClassInstancePtr) {
    context = gdext.godot_context()

    if instance == nil {
        return
    }

    self := cast(^ExampleClass)instance
    free(self)
}

example_class_register :: proc() {
    // we use string_name_new_with_latin1_chars because we know the lifetime of the string literal to be static
    gdext.string_name_new_with_latin1_chars(&example_class_name, "ExampleClass", true)
    gdext.string_name_new_with_latin1_chars(&time_passed_name, "time_passed", true)
    gdext.string_name_new_with_latin1_chars(&emit_signal_name, "emit_signal", true)

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

    gdext.classdb_register_extension_class2(
        gdext.library,
        &example_class_name,
        godot.sprite2d_name_ref(),
        &class_info,
    )

    amplitdue_name := godot.new_string_name_cstring("amplitude", true)
    get_amplitdue_name := godot.new_string_name_cstring("get_amplitude", true)
    set_amplitdue_name := godot.new_string_name_cstring("set_amplitude", true)
    classdb.bind_property_and_methods(
        &example_class_name,
        &amplitdue_name,
        &get_amplitdue_name,
        &set_amplitdue_name,
        get_amplitude,
        set_amplitude,
    )

    speed_name := godot.new_string_name_cstring("speed", true)
    get_speed_name := godot.new_string_name_cstring("get_speed", true)
    set_speed_name := godot.new_string_name_cstring("set_speed", true)
    classdb.bind_property_and_methods(
        &example_class_name,
        &speed_name,
        &get_speed_name,
        &set_speed_name,
        get_speed,
        set_speed,
    )

    classdb.bind_signal(
        &example_class_name,
        &time_passed_name,
        classdb.Signal_Arg{name = &time_passed_name, type = .Float},
    )
}

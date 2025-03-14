package game

import "core:math"
import "godot:gdextension"
import "godot:gdextension/bind"
import "godot:godot"

YawSpeed :: 0.022
PitchSpeed :: 0.022
MouseSpeed :: 2.0

CharacterBody3D_ClassName: godot.String_Name
Player_ClassName: godot.String_Name
PLAYER_CLASS_NAME :: "Player"

// virtual funcs from Node
Ready_VirtualName: godot.String_Name
Input_VirtualName: godot.String_Name
PhysicsProcess_VirtualName: godot.String_Name

// signals
Player_SteppedUp_SignalName: godot.String_Name
Player_SteppedDown_SignalName: godot.String_Name

// input
Input_Singleton: godot.Input
MoveLeft_Name: godot.String_Name
MoveRight_Name: godot.String_Name

player_binding_callbacks := gdextension.InstanceBindingCallbacks{}

Player :: struct {
    object:                       godot.Character_Body3d,

    // Group: Movement. Subgroup: On Ground
    ground_friction:              f64,
    ground_accel:                 f64,
    ground_max_speed:             f64,
    max_step_height:              f64,
    max_step_up_slide_iterations: i64,

    // Group: Movement. Subgroup: In Air
    gravity_up_scale:             f64,
    gravity_down_scale:           f64,
    air_friction:                 f64,
    air_accel:                    f64,
    air_max_speed:                f64,
    max_vertical_speed:           f64,

    // onready
    camera_yaw:                   godot.Node3d,
    camera:                       godot.Camera3d,
    player_shape:                 godot.Shape3d,

    // fields
    vertical_speed:               f64,
    horizontal_velocity:          godot.Vector3,
}

@(private = "file")
player_ready :: proc "contextless" (self: ^Player) {
    self_node := self.object

    camera_yaw_path := godot.new_node_path_cstring("CameraYaw")
    defer godot.free_node_path(camera_yaw_path)

    self.camera_yaw = godot.node_get_node(self_node, camera_yaw_path)

    camera_path := godot.new_node_path_cstring("CameraYaw/Camera")
    defer godot.free_node_path(camera_path)
    self.camera = godot.node_get_node(self_node, camera_path)

    player_shape_path := godot.new_node_path_cstring("PlayerShape")
    defer godot.free_node_path(player_shape_path)
    player_col_shape := godot.node_get_node(self_node, player_shape_path)
    self.player_shape = godot.collision_shape3d_get_shape(player_col_shape)
}

@(private = "file")
player_input :: proc "contextless" (self: ^Player, event: godot.Input_Event) {
    event := event
    if godot.input_get_mouse_mode(godot.singleton_input()) == .Mouse_Mode_Captured {
        if key_event, ok := godot.cast_class(event, godot.Input_Event_Key); ok {
            if godot.input_event_key_get_keycode(key_event) == .Escape {
                godot.input_set_mouse_mode(godot.singleton_input(), .Mouse_Mode_Visible)
            }
            return
        }

        if mouse_motion_event, ok := godot.cast_class(event, godot.Input_Event_Mouse_Motion); ok {
            player_move_camera(self, godot.input_event_mouse_motion_get_relative(mouse_motion_event))
            return
        }
    } else {
        if mouse_button_event, ok := godot.cast_class(event, godot.Input_Event_Mouse_Motion); ok {
            mouse_button_index := godot.input_event_mouse_button_get_button_index(mouse_button_event)
            if mouse_button_index == .Left {
                godot.input_set_mouse_mode(godot.singleton_input(), .Mouse_Mode_Captured)
            }
            return
        }
    }
}

@(private = "file")
player_physics_process :: proc "contextless" (self: ^Player, delta: f64) {
    local_wish_dir := godot.VECTOR3_ZERO
    if godot.input_get_mouse_mode(&Input_Singleton) == .Mouse_Mode_Captured {
        input_dir := libgd.get_input_vector("move_left", "move_right", "move_forward", "move_back", true)
        local_wish_dir = godot.Vector3{input_dir.x, 0, input_dir.y}
    }

    camera_yaw_basis := godot.node3d_get_basis(&self.camera_yaw)
    wish_dir := godot.basis_multiply(camera_yaw_basis, local_wish_dir)

    if godot.character_body3d_is_on_floor(&self.object) {
        player_move(self, delta, wish_dir, self.ground_friction, self.ground_accel, self.ground_max_speed)
    } else {
        player_move(self, delta, wish_dir, self.air_friction, self.air_accel, self.air_max_speed)
    }

    player_apply_gravity(self, delta)

    was_grounded := godot.character_body3d_is_on_floor(&self.object)
    godot.character_body3d_set_velocity(
        &self.object,
        godot.Vector3{self.horizontal_velocity.x, godot.Real(self.vertical_speed), self.horizontal_velocity.z},
    )

    player_sweep_stairs_up(self, delta)
    godot.character_body3d_move_and_slide(&self.object)
    player_sweep_stairs_down(self, was_grounded)

    self.horizontal_velocity = godot.character_body3d_get_velocity(&self.object)
    self.vertical_speed = cast(godot.Float)self.horizontal_velocity.y
    self.horizontal_velocity.y = 0
}

player_move_camera :: proc "contextless" (self: ^Player, move: godot.Vector2) {
    horizontal := move.x * YawSpeed * MouseSpeed
    vertical := move.y * PitchSpeed * MouseSpeed
    yaw_rotation := math.to_radians(-horizontal)
    pitch_rotation := math.to_radians(-vertical)

    godot.node3d_rotate_y(&self.camera_yaw, yaw_rotation)
    godot.node3d_rotate_x(&self.camera, pitch_rotation)
}

player_move :: proc "contextless" (
    self: ^Player,
    delta: godot.Float,
    wish_dir: godot.Vector3,
    friction: godot.Float,
    accel: godot.Float,
    max_speed: godot.Float,
) {
    if (wish_dir == godot.Vector3{0, 0, 0}) {
        self.horizontal_velocity = exp_decay(
            self.horizontal_velocity,
            godot.VECTOR3_ZERO,
            godot.Real(friction),
            godot.Real(delta),
        )
        if is_zero_approx(self.horizontal_velocity) {
            self.horizontal_velocity = godot.Vector3{0, 0, 0}
        }
    } else {
        self.horizontal_velocity += wish_dir * godot.Real(accel * delta)
    }

    self.horizontal_velocity = limit_length(self.horizontal_velocity, max_speed)
}

player_apply_gravity :: proc "contextless" (self: ^Player, delta: f64) {
    if self.vertical_speed > -self.max_vertical_speed {
        gravity: f64 = -10
        if self.vertical_speed > 0 || godot.character_body3d_is_on_floor(&self.object) {
            gravity *= self.gravity_up_scale
        } else {
            gravity *= self.gravity_down_scale
        }

        self.vertical_speed += gravity * delta

        if self.vertical_speed < -self.max_vertical_speed {
            self.vertical_speed = -self.max_vertical_speed
        }
    }
}

player_sweep_stairs_up :: proc "contextless" (self: ^Player, delta: f64) {
    if !godot.character_body3d_is_on_floor(&self.object) {
        return
    }
}

player_sweep_stairs_down :: proc "contextless" (self: ^Player, was_grounded: bool) {

}

@(private = "file")
player_create_instance :: proc "c" (class_user_data: rawptr) -> gdextension.ObjectPtr {
    context = gdextension.godot_context()

    self := new(Player)
    self.object = gdextension.classdb_construct_object(&CharacterBody3D_ClassName)

    // defaults
    self.ground_friction = 20
    self.ground_accel = 100
    self.ground_max_speed = 5.0
    self.max_step_height = 0.6
    self.max_step_up_slide_iterations = 4
    self.gravity_up_scale = 1.0
    self.gravity_down_scale = 1.0
    self.air_friction = 10.0
    self.air_accel = 50.0
    self.air_max_speed = 3.0
    self.max_vertical_speed = 15.0

    self.vertical_speed = 0.0
    self.horizontal_velocity = godot.Vector3{0, 0, 0}

    gdextension.object_set_instance(self.object, &Player_ClassName, self)
    gdextension.object_set_instance_binding(self.object, gdextension.library, self, &player_binding_callbacks)

    return self.object
}

@(private = "file")
player_free_instance :: proc "c" (class_user_data: rawptr, instance: gdextension.ExtensionClassInstancePtr) {
    context = gdextension.godot_context()

    if instance == nil {
        return
    }

    gdextension.mem_free(instance)
}

@(private = "file")
player_get_virtual_call_data :: proc "c" (class_user_data: rawptr, name: gdextension.StringNamePtr) -> rawptr {
    if godot.engine_is_editor_hint(godot.singleton_engine()) {
        return nil
    }

    name_str := cast(^godot.String_Name)name
    if godot.string_name_equal_string_name(Ready_VirtualName, name_str^) {
        return cast(rawptr)player_ready
    } else if godot.string_name_equal_string_name(Input_VirtualName, name_str^) {
        return cast(rawptr)player_input
    } else if godot.string_name_equal_string_name(PhysicsProcess_VirtualName, name_str^) {
        return cast(rawptr)player_physics_process
    }

    return nil
}

@(private = "file")
player_call_virtual_with_data :: proc "c" (
    instance: gdextension.ExtensionClassInstancePtr,
    name: gdextension.StringNamePtr,
    virtual_call_userdata: rawptr,
    args: [^]gdextension.TypePtr,
    ret: gdextension.TypePtr,
) {
    if godot.engine_is_editor_hint(godot.singleton_engine()) {
        return
    }

    if virtual_call_userdata == cast(rawptr)player_ready {
        player_ready(cast(^Player)instance)
        return
    } else if virtual_call_userdata == cast(rawptr)player_input {
        input_event := cast(^godot.Input_Event)args[0]
        player_input(cast(^Player)instance, input_event^)
        return
    } else if virtual_call_userdata == cast(rawptr)player_physics_process {
        delta := cast(^f64)args[0]
        player_physics_process(cast(^Player)instance, delta^)
        return
    }
}

@(export)
set_ground_friction :: proc "contextless" (self: ^Player, value: f64) {
    self.ground_friction = value
}

@(export)
get_ground_friction :: proc "contextless" (self: ^Player) -> f64 {
    return self.ground_friction
}

@(private = "file")
set_ground_accel :: proc "contextless" (self: ^Player, value: f64) {
    self.ground_accel = value
}

@(private = "file")
get_ground_accel :: proc "contextless" (self: ^Player) -> f64 {
    return self.ground_accel
}

@(private = "file")
set_ground_max_speed :: proc "contextless" (self: ^Player, value: f64) {
    self.ground_max_speed = value
}

@(private = "file")
get_ground_max_speed :: proc "contextless" (self: ^Player) -> f64 {
    return self.ground_max_speed
}

@(private = "file")
set_max_step_height :: proc "contextless" (self: ^Player, value: f64) {
    self.max_step_height = value
}

@(private = "file")
get_max_step_height :: proc "contextless" (self: ^Player) -> f64 {
    return self.max_step_height
}

@(private = "file")
set_max_step_up_slide_iterations :: proc "contextless" (self: ^Player, value: i64) {
    self.max_step_up_slide_iterations = value
}

@(private = "file")
get_max_step_up_slide_iterations :: proc "contextless" (self: ^Player) -> i64 {
    return self.max_step_up_slide_iterations
}

@(private = "file")
set_gravity_up_scale :: proc "contextless" (self: ^Player, value: f64) {
    self.gravity_up_scale = value
}

@(private = "file")
get_gravity_up_scale :: proc "contextless" (self: ^Player) -> f64 {
    return self.gravity_up_scale
}

@(private = "file")
set_gravity_down_scale :: proc "contextless" (self: ^Player, value: f64) {
    self.gravity_down_scale = value
}

@(private = "file")
get_gravity_down_scale :: proc "contextless" (self: ^Player) -> f64 {
    return self.gravity_down_scale
}

@(private = "file")
set_air_friction :: proc "contextless" (self: ^Player, value: f64) {
    self.air_friction = value
}

@(private = "file")
get_air_friction :: proc "contextless" (self: ^Player) -> f64 {
    return self.air_friction
}

@(private = "file")
set_air_accel :: proc "contextless" (self: ^Player, value: f64) {
    self.air_accel = value
}

@(private = "file")
get_air_accel :: proc "contextless" (self: ^Player) -> f64 {
    return self.air_accel
}

@(private = "file")
set_air_max_speed :: proc "contextless" (self: ^Player, value: f64) {
    self.air_max_speed = value
}

@(private = "file")
get_air_max_speed :: proc "contextless" (self: ^Player) -> f64 {
    return self.air_max_speed
}

@(private = "file")
set_max_vertical_speed :: proc "contextless" (self: ^Player, value: f64) {
    self.max_vertical_speed = value
}

@(private = "file")
get_max_vertical_speed :: proc "contextless" (self: ^Player) -> f64 {
    return self.max_vertical_speed
}

player_class_register :: proc() {
    gdextension.string_name_new_with_latin1_chars(&CharacterBody3D_ClassName, "CharacterBody3D", true)
    gdextension.string_name_new_with_latin1_chars(&Player_ClassName, "Player", true)

    gdextension.string_name_new_with_latin1_chars(&Ready_VirtualName, "_ready", true)
    gdextension.string_name_new_with_latin1_chars(&Input_VirtualName, "_input", true)
    gdextension.string_name_new_with_latin1_chars(&PhysicsProcess_VirtualName, "_physics_process", true)

    gdextension.string_name_new_with_latin1_chars(&Player_SteppedUp_SignalName, "stepped_up", true)
    gdextension.string_name_new_with_latin1_chars(&Player_SteppedDown_SignalName, "stepped_down", true)

    Input_Singleton = godot.singleton_input()

    class_info := gdextension.ExtensionClassCreationInfo3 {
        is_virtual                  = false,
        is_abstract                 = false,
        is_exposed                  = true,
        is_runtime                  = false,
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
        create_instance_func        = player_create_instance,
        free_instance_func          = player_free_instance,
        recreate_instance_func      = nil,
        get_virtual_func            = nil,
        get_virtual_call_data_func  = player_get_virtual_call_data,
        call_virtual_with_data_func = player_call_virtual_with_data,
        get_rid_func                = nil,
        class_userdata              = nil,
    }

    gdextension.classdb_register_extension_class3(
        gdextension.library,
        &Player_ClassName,
        &CharacterBody3D_ClassName,
        &class_info,
    )

    bind.bind_property_group(PLAYER_CLASS_NAME, "Movement", "")
    bind.bind_property_subgroup(PLAYER_CLASS_NAME, "On Ground", "")
    bind.bind_property_and_methods(
        PLAYER_CLASS_NAME,
        "ground_friction",
        "get_ground_friction",
        "set_ground_friction",
        get_ground_friction,
        set_ground_friction,
        static_strings = true,
    )
    bind.bind_property_and_methods(
        PLAYER_CLASS_NAME,
        "ground_accel",
        "get_ground_accel",
        "set_ground_accel",
        get_ground_accel,
        set_ground_accel,
        static_strings = true,
    )
    bind.bind_property_and_methods(
        PLAYER_CLASS_NAME,
        "ground_max_speed",
        "get_ground_max_speed",
        "set_ground_max_speed",
        get_ground_max_speed,
        set_ground_max_speed,
        static_strings = true,
    )
    bind.bind_property_and_methods(
        PLAYER_CLASS_NAME,
        "max_step_height",
        "get_max_step_height",
        "set_max_step_height",
        get_max_step_height,
        set_max_step_height,
        static_strings = true,
    )
    bind.bind_property_and_methods(
        PLAYER_CLASS_NAME,
        "max_step_up_slide_iterations",
        "get_max_step_up_slide_iterations",
        "set_max_step_up_slide_iterations",
        get_max_step_up_slide_iterations,
        set_max_step_up_slide_iterations,
        static_strings = true,
    )

    bind.bind_property_subgroup(PLAYER_CLASS_NAME, "In Air", "")
    bind.bind_property_and_methods(
        PLAYER_CLASS_NAME,
        "gravity_up_scale",
        "get_gravity_up_scale",
        "set_gravity_up_scale",
        get_gravity_up_scale,
        set_gravity_up_scale,
        static_strings = true,
    )
    bind.bind_property_and_methods(
        PLAYER_CLASS_NAME,
        "gravity_down_scale",
        "get_gravity_down_scale",
        "set_gravity_down_scale",
        get_gravity_down_scale,
        set_gravity_down_scale,
        static_strings = true,
    )
    bind.bind_property_and_methods(
        PLAYER_CLASS_NAME,
        "air_friction",
        "get_air_friction",
        "set_air_friction",
        get_air_friction,
        set_air_friction,
        static_strings = true,
    )
    bind.bind_property_and_methods(
        PLAYER_CLASS_NAME,
        "air_accel",
        "get_air_accel",
        "set_air_accel",
        get_air_accel,
        set_air_accel,
        static_strings = true,
    )
    bind.bind_property_and_methods(
        PLAYER_CLASS_NAME,
        "air_max_speed",
        "get_air_max_speed",
        "set_air_max_speed",
        get_air_max_speed,
        set_air_max_speed,
        static_strings = true,
    )
    bind.bind_property_and_methods(
        PLAYER_CLASS_NAME,
        "max_vertical_speed",
        "get_max_vertical_speed",
        "set_max_vertical_speed",
        get_max_vertical_speed,
        set_max_vertical_speed,
        static_strings = true,
    )

    distance_name := godot.new_string_name_cstring("distance", true)
    bind.bind_signal(
        &Player_ClassName,
        &Player_SteppedUp_SignalName,
        bind.Signal_Arg{name = &distance_name, type = .Float},
    )
    bind.bind_signal(
        &Player_ClassName,
        &Player_SteppedDown_SignalName,
        bind.Signal_Arg{name = &distance_name, type = .Float},
    )
}

player_class_unregister :: proc "contextless" () {
    gdextension.classdb_unregister_extension_class(gdextension.library, &Player_ClassName)
}

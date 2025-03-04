package game

import core "../../../core"
import gde "../../../gdextension"
import "../../../libgd"
import var "../../../variant"

import "core:fmt"
import "core:math"

YawSpeed :: 0.022
PitchSpeed :: 0.022
MouseSpeed :: 2.0

CharacterBody3D_ClassName: var.StringName
Player_ClassName: var.StringName

// virtual funcs from Node
Ready_VirtualName: var.StringName
Input_VirtualName: var.StringName
PhysicsProcess_VirtualName: var.StringName

// signals
Player_SteppedUp_SignalName: var.StringName
Player_SteppedDown_SignalName: var.StringName

// input
Input_Singleton: core.Input
MoveLeft_Name: var.StringName
MoveRight_Name: var.StringName

player_binding_callbacks := gde.InstanceBindingCallbacks{}

Player :: struct {
    object:                       core.CharacterBody3d,

    // Group: Movement. Subgroup: On Ground
    ground_friction:              gde.float,
    ground_accel:                 gde.float,
    ground_max_speed:             gde.float,
    max_step_height:              gde.float,
    max_step_up_slide_iterations: i64,

    // Group: Movement. Subgroup: In Air
    gravity_up_scale:             gde.float,
    gravity_down_scale:           gde.float,
    air_friction:                 gde.float,
    air_accel:                    gde.float,
    air_max_speed:                gde.float,
    max_vertical_speed:           gde.float,

    // onready
    camera_yaw:                   core.Node3d,
    camera:                       core.Camera3d,
    player_shape:                 core.Shape3d,

    // fields
    vertical_speed:               gde.float,
    horizontal_velocity:          var.Vector3,
}

@(private = "file")
player_ready :: proc "contextless" (self: ^Player) {
    self_node := cast(core.Node)self.object

    camera_yaw_path := var.new_node_path_cstring("CameraYaw")
    defer var.free_node_path(camera_yaw_path)

    self.camera_yaw = cast(core.Node3d)core.node_get_node(self_node, camera_yaw_path)

    camera_path := var.new_node_path_cstring("CameraYaw/Camera")
    defer var.free_node_path(camera_path)
    self.camera = cast(core.Camera3d)core.node_get_node(self_node, camera_path)

    player_shape_path := var.new_node_path_cstring("PlayerShape")
    defer var.free_node_path(player_shape_path)
    player_col_shape := cast(core.CollisionShape3d)core.node_get_node(self_node, player_shape_path)
    self.player_shape = core.collision_shape3d_get_shape(player_col_shape)
}

@(private = "file")
player_input :: proc "contextless" (self: ^Player, event: core.InputEvent) {
    event := event
    if core.input_get_mouse_mode(Input_Singleton) == .MouseModeCaptured {
        if key_event, ok := core.cast_class(event, core.InputEventKey); ok {
            if core.input_event_key_get_keycode(key_event) == .Escape {
                core.input_set_mouse_mode(Input_Singleton, .MouseModeVisible)
            }
            return
        }

        if mouse_motion_event, ok := core.cast_class(event, core.InputEventMouseMotion); ok {
            if core.input_get_mouse_mode(Input_Singleton) == .MouseModeCaptured {
                player_move_camera(self, core.input_event_mouse_motion_get_relative(mouse_motion_event))
            }
            return
        }
    } else {
        if mouse_button_event, ok := core.cast_class(event, core.InputEventMouseButton); ok {
            mouse_button_index := core.input_event_mouse_button_get_button_index(mouse_button_event)
            if mouse_button_index == .Left {
                core.input_set_mouse_mode(Input_Singleton, .MouseModeCaptured)
            }
            return
        }
    }
}

@(private = "file")
player_physics_process :: proc "contextless" (self: ^Player, delta: gde.float) {
    local_wish_dir := var.new_vector3(0, 0, 0)
    if core.input_get_mouse_mode(Input_Singleton) == .MouseModeCaptured {
        input_dir := libgd.get_input_vector("move_left", "move_right", "move_forward", "move_back", true)
        local_wish_dir = var.new_vector3(var.vector2_get_x(input_dir), 0, var.vector2_get_y(input_dir))
    }

    camera_yaw_basis := core.node3d_get_basis(cast(core.Node3d)self.camera_yaw)
    wish_dir := var.basis_multiply(camera_yaw_basis, local_wish_dir)

    if core.character_body3d_is_on_floor(self.object) {
        player_move_grounded(self, wish_dir, delta)
    } else {
        player_move_air(self, wish_dir, delta)
    }

    player_apply_gravity(self, delta)

    was_grounded := core.character_body3d_is_on_floor(self.object)
    velocity := var.vector3_add(self.horizontal_velocity, var.new_vector3(0, self.vertical_speed, 0))
    core.character_body3d_set_velocity(self.object, velocity)

    player_sweep_stairs_up(self, delta)
    core.character_body3d_move_and_slide(self.object)
    player_sweep_stairs_down(self, was_grounded)

    self.horizontal_velocity = core.character_body3d_get_velocity(self.object)
    self.vertical_speed = var.vector3_get_y(self.horizontal_velocity)
    var.vector3_set_y(self.horizontal_velocity, 0)
}

player_move_camera :: proc "contextless" (self: ^Player, move: var.Vector2) {
    horizontal := var.vector2_get_x(move) * YawSpeed * MouseSpeed
    vertical := var.vector2_get_y(move) * PitchSpeed * MouseSpeed
    yaw_rotation := math.to_radians(-horizontal)
    pitch_rotation := math.to_radians(-vertical)
    core.node3d_rotate_y(cast(core.Node3d)self.camera_yaw, yaw_rotation)
    core.node3d_rotate_x(cast(core.Node3d)self.camera, pitch_rotation)
}

player_move_grounded :: proc "contextless" (self: ^Player, wish_dir: var.Vector3, delta: gde.float) {

}

player_move_air :: proc "contextless" (self: ^Player, wish_dir: var.Vector3, delta: gde.float) {
    
}

player_apply_gravity :: proc "contextless" (self: ^Player, delta: gde.float) {

}

player_sweep_stairs_up :: proc "contextless" (self: ^Player, delta: gde.float) {

}

player_sweep_stairs_down :: proc "contextless" (self: ^Player, was_grounded: bool) {

}

@(private = "file")
player_create_instance :: proc "c" (class_user_data: rawptr) -> gde.ObjectPtr {
    context = gde.godot_context()

    self := new(Player)
    self.object = cast(core.CharacterBody3d)gde.classdb_construct_object(&CharacterBody3D_ClassName)

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
    self.horizontal_velocity = var.new_vector3(0, 0, 0)

    gde.object_set_instance(self.object, &Player_ClassName, self)
    gde.object_set_instance_binding(self.object, gde.library, self, &player_binding_callbacks)

    return cast(gde.ObjectPtr)self.object
}

@(private = "file")
player_free_instance :: proc "c" (class_user_data: rawptr, instance: gde.ExtensionClassInstancePtr) {
    context = gde.godot_context()

    if instance == nil {
        return
    }

    gde.mem_free(instance)
}

@(private = "file")
player_get_virtual_call_data :: proc "c" (class_user_data: rawptr, name: gde.StringNamePtr) -> rawptr {
    if core.engine_is_editor_hint(core.singleton_engine()) {
        return nil
    }

    name_str := cast(^var.StringName)name
    if var.string_name_equal_string_name(Ready_VirtualName, name_str^) {
        return cast(rawptr)player_ready
    } else if var.string_name_equal_string_name(Input_VirtualName, name_str^) {
        return cast(rawptr)player_input
    } else if var.string_name_equal_string_name(PhysicsProcess_VirtualName, name_str^) {
        return cast(rawptr)player_physics_process
    }

    return nil
}

@(private = "file")
player_call_virtual_with_data :: proc "c" (
    instance: gde.ExtensionClassInstancePtr,
    name: gde.StringNamePtr,
    virtual_call_userdata: rawptr,
    args: [^]gde.TypePtr,
    ret: gde.TypePtr,
) {
    if core.engine_is_editor_hint(core.singleton_engine()) {
        return
    }

    if virtual_call_userdata == cast(rawptr)player_ready {
        player_ready(cast(^Player)instance)
        return
    } else if virtual_call_userdata == cast(rawptr)player_input {
        input_event := cast(^core.InputEvent)args[0]
        player_input(cast(^Player)instance, input_event^)
        return
    } else if virtual_call_userdata == cast(rawptr)player_physics_process {
        delta := cast(^gde.float)args[0]
        player_physics_process(cast(^Player)instance, delta^)
        return
    }
}

@(export)
set_ground_friction :: proc(self: ^Player, value: gde.float) {
    self.ground_friction = value
}

@(export)
get_ground_friction :: proc(self: ^Player) -> gde.float {
    return self.ground_friction
}

@(private = "file")
set_ground_accel :: proc(self: ^Player, value: gde.float) {
    self.ground_accel = value
}

@(private = "file")
get_ground_accel :: proc(self: ^Player) -> gde.float {
    return self.ground_accel
}

@(private = "file")
set_ground_max_speed :: proc(self: ^Player, value: gde.float) {
    self.ground_max_speed = value
}

@(private = "file")
get_ground_max_speed :: proc(self: ^Player) -> gde.float {
    return self.ground_max_speed
}

@(private = "file")
set_max_step_height :: proc(self: ^Player, value: gde.float) {
    self.max_step_height = value
}

@(private = "file")
get_max_step_height :: proc(self: ^Player) -> gde.float {
    return self.max_step_height
}

@(private = "file")
set_max_step_up_slide_iterations :: proc(self: ^Player, value: i64) {
    self.max_step_up_slide_iterations = value
}

@(private = "file")
get_max_step_up_slide_iterations :: proc(self: ^Player) -> i64 {
    return self.max_step_up_slide_iterations
}

@(private = "file")
set_gravity_up_scale :: proc(self: ^Player, value: gde.float) {
    self.gravity_up_scale = value
}

@(private = "file")
get_gravity_up_scale :: proc(self: ^Player) -> gde.float {
    return self.gravity_up_scale
}

@(private = "file")
set_gravity_down_scale :: proc(self: ^Player, value: gde.float) {
    self.gravity_down_scale = value
}

@(private = "file")
get_gravity_down_scale :: proc(self: ^Player) -> gde.float {
    return self.gravity_down_scale
}

@(private = "file")
set_air_friction :: proc(self: ^Player, value: gde.float) {
    self.air_friction = value
}

@(private = "file")
get_air_friction :: proc(self: ^Player) -> gde.float {
    return self.air_friction
}

@(private = "file")
set_air_accel :: proc(self: ^Player, value: gde.float) {
    self.air_accel = value
}

@(private = "file")
get_air_accel :: proc(self: ^Player) -> gde.float {
    return self.air_accel
}

@(private = "file")
set_air_max_speed :: proc(self: ^Player, value: gde.float) {
    self.air_max_speed = value
}

@(private = "file")
get_air_max_speed :: proc(self: ^Player) -> gde.float {
    return self.air_max_speed
}

@(private = "file")
set_max_vertical_speed :: proc(self: ^Player, value: gde.float) {
    self.max_vertical_speed = value
}

@(private = "file")
get_max_vertical_speed :: proc(self: ^Player) -> gde.float {
    return self.max_vertical_speed
}

player_class_register :: proc() {
    gde.string_name_new_with_latin1_chars(&CharacterBody3D_ClassName, "CharacterBody3D", true)
    gde.string_name_new_with_latin1_chars(&Player_ClassName, "Player", true)

    gde.string_name_new_with_latin1_chars(&Ready_VirtualName, "_ready", true)
    gde.string_name_new_with_latin1_chars(&Input_VirtualName, "_input", true)
    gde.string_name_new_with_latin1_chars(&PhysicsProcess_VirtualName, "_physics_process", true)

    gde.string_name_new_with_latin1_chars(&Player_SteppedUp_SignalName, "stepped_up", true)
    gde.string_name_new_with_latin1_chars(&Player_SteppedDown_SignalName, "stepped_down", true)

    Input_Singleton = core.singleton_input()

    class_info := gde.ExtensionClassCreationInfo3 {
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

    gde.classdb_register_extension_class3(gde.library, &Player_ClassName, &CharacterBody3D_ClassName, &class_info)

    libgd.bind_property_group(&Player_ClassName, "Movement", "")
    libgd.bind_property_subgroup(&Player_ClassName, "On Ground", "")
    libgd.bind_auto_property(
        &Player_ClassName,
        "ground_friction",
        "get_ground_friction",
        get_ground_friction,
        "set_ground_friction",
        set_ground_friction,
    )
    libgd.bind_auto_property(
        &Player_ClassName,
        "ground_accel",
        "get_ground_accel",
        get_ground_accel,
        "set_ground_accel",
        set_ground_accel,
    )
    libgd.bind_auto_property(
        &Player_ClassName,
        "ground_max_speed",
        "get_ground_max_speed",
        get_ground_max_speed,
        "set_ground_max_speed",
        set_ground_max_speed,
    )
    libgd.bind_auto_property(
        &Player_ClassName,
        "max_step_height",
        "get_max_step_height",
        get_max_step_height,
        "set_max_step_height",
        set_max_step_height,
    )
    libgd.bind_auto_property(
        &Player_ClassName,
        "max_step_up_slide_iterations",
        "get_max_step_up_slide_iterations",
        get_max_step_up_slide_iterations,
        "set_max_step_up_slide_iterations",
        set_max_step_up_slide_iterations,
    )

    libgd.bind_property_subgroup(&Player_ClassName, "In Air", "")
    libgd.bind_auto_property(
        &Player_ClassName,
        "gravity_up_scale",
        "get_gravity_up_scale",
        get_gravity_up_scale,
        "set_gravity_up_scale",
        set_gravity_up_scale,
    )
    libgd.bind_auto_property(
        &Player_ClassName,
        "gravity_down_scale",
        "get_gravity_down_scale",
        get_gravity_down_scale,
        "set_gravity_down_scale",
        set_gravity_down_scale,
    )
    libgd.bind_auto_property(
        &Player_ClassName,
        "air_friction",
        "get_air_friction",
        get_air_friction,
        "set_air_friction",
        set_air_friction,
    )
    libgd.bind_auto_property(
        &Player_ClassName,
        "air_accel",
        "get_air_accel",
        get_air_accel,
        "set_air_accel",
        set_air_accel,
    )
    libgd.bind_auto_property(
        &Player_ClassName,
        "air_max_speed",
        "get_air_max_speed",
        get_air_max_speed,
        "set_air_max_speed",
        set_air_max_speed,
    )
    libgd.bind_auto_property(
        &Player_ClassName,
        "max_vertical_speed",
        "get_max_vertical_speed",
        get_max_vertical_speed,
        "set_max_vertical_speed",
        set_max_vertical_speed,
    )

    libgd.bind_signal(&Player_ClassName, "stepped_up", libgd.MethodBindArgument{name = "distance", type = .Float})
    libgd.bind_signal(&Player_ClassName, "stepped_down", libgd.MethodBindArgument{name = "distance", type = .Float})
}

player_class_unregister :: proc "contextless" () {
    gde.classdb_unregister_extension_class(gde.library, &Player_ClassName)
}

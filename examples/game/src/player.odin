package game

import "godot:core"
import "godot:core/character_body3d"
import "godot:core/engine"
import "godot:core/node"
import "godot:core/node3d"
import "godot:core/input_event_key"
import "godot:core/input"
import "godot:core/input_event_mouse_button"
import "godot:core/input_event_mouse_motion"
import "godot:core/collision_shape3d"
import "godot:gdextension"
import "godot:libgd"
import "godot:variant"

import "core:fmt"
import "core:math"
import "core:math/linalg"

YawSpeed :: 0.022
PitchSpeed :: 0.022
MouseSpeed :: 2.0

CharacterBody3D_ClassName: variant.String_Name
Player_ClassName: variant.String_Name

// virtual funcs from Node
Ready_VirtualName: variant.String_Name
Input_VirtualName: variant.String_Name
PhysicsProcess_VirtualName: variant.String_Name

// signals
Player_SteppedUp_SignalName: variant.String_Name
Player_SteppedDown_SignalName: variant.String_Name

// input
Input_Singleton: core.Input
MoveLeft_Name: variant.String_Name
MoveRight_Name: variant.String_Name

player_binding_callbacks := gdextension.InstanceBindingCallbacks{}

Player :: struct {
    object:                       core.Character_Body3d,

    // Group: Movement. Subgroup: On Ground
    ground_friction:              gdextension.Float,
    ground_accel:                 gdextension.Float,
    ground_max_speed:             gdextension.Float,
    max_step_height:              gdextension.Float,
    max_step_up_slide_iterations: i64,

    // Group: Movement. Subgroup: In Air
    gravity_up_scale:             gdextension.Float,
    gravity_down_scale:           gdextension.Float,
    air_friction:                 gdextension.Float,
    air_accel:                    gdextension.Float,
    air_max_speed:                gdextension.Float,
    max_vertical_speed:           gdextension.Float,

    // onready
    camera_yaw:                   core.Node3d,
    camera:                       core.Camera3d,
    player_shape:                 core.Shape3d,

    // fields
    vertical_speed:               gdextension.Float,
    horizontal_velocity:          [3]gdextension.Float,
}

@(private = "file")
player_ready :: proc "contextless" (self: ^Player) {
    self_node := cast(core.Node)self.object

    camera_yaw_path := variant.new_node_path_cstring("CameraYaw")
    defer variant.free_node_path(camera_yaw_path)

    self.camera_yaw = cast(core.Node3d)node.get_node(&self_node, camera_yaw_path)

    camera_path := variant.new_node_path_cstring("CameraYaw/Camera")
    defer variant.free_node_path(camera_path)
    self.camera = cast(core.Camera3d)node.get_node(&self_node, camera_path)

    player_shape_path := variant.new_node_path_cstring("PlayerShape")
    defer variant.free_node_path(player_shape_path)
    player_col_shape := cast(core.Collision_Shape3d)node.get_node(&self_node, player_shape_path)
    self.player_shape = collision_shape3d.get_shape(&player_col_shape)
}

@(private = "file")
player_input :: proc "contextless" (self: ^Player, event: core.Input_Event) {
    event := event
    if input.get_mouse_mode(&Input_Singleton) == .Mouse_Mode_Captured {
        if key_event, ok := core.cast_class(event, core.InputEventKey); ok {
            if input_event_key.get_keycode(&key_event) == .Key_Escape {
                input.set_mouse_mode(&Input_Singleton, .Mouse_Mode_Visible)
            }
            return
        }

        if mouse_motion_event, ok := core.cast_class(event, core.Input_Event_Mouse_Motion); ok {
            player_move_camera(self, input_event_mouse_motion.get_relative(&mouse_motion_event))
            return
        }
    } else {
        if mouse_button_event, ok := core.cast_class(event, core.Input_Event_Mouse_Motion); ok {
            mouse_button_index := input_event_mouse_button.get_button_index(&mouse_button_event)
            if mouse_button_index == .Mouse_Button_Left {
                input.set_mouse_mode(&Input_Singleton, .Mouse_Mode_Captured)
            }
            return
        }
    }
}

@(private = "file")
player_physics_process :: proc "contextless" (self: ^Player, delta: gdextension.Float) {
    local_wish_dir := variant.VECTOR3_ZERO
    if input.get_mouse_mode(&Input_Singleton) == .Mouse_Mode_Captured {
        input_dir := libgd.get_input_vector("move_left", "move_right", "move_forward", "move_back", true)
        local_wish_dir = variant.Vector3{input_dir.x, 0, input_dir.y}
    }

    camera_yaw_basis := node3d.get_basis(&self.camera_yaw)
    wish_dir := variant.basis_multiply(camera_yaw_basis, local_wish_dir)

    if character_body3d.is_on_floor(&self.object) {
        player_move(self, delta, wish_dir, self.ground_friction, self.ground_accel, self.ground_max_speed)
    } else {
        player_move(self, delta, wish_dir, self.air_friction, self.air_accel, self.air_max_speed)
    }

    player_apply_gravity(self, delta)

    was_grounded := character_body3d.is_on_floor(&self.object)
    character_body3d.set_velocity(
        &self.object,
        variant.Vector3{self.horizontal_velocity.x, self.vertical_speed, self.horizontal_velocity.z},
    )

    player_sweep_stairs_up(self, delta)
    character_body3d.move_and_slide(&self.object)
    player_sweep_stairs_down(self, was_grounded)

    self.horizontal_velocity = character_body3d.get_velocity(&self.object)
    self.vertical_speed = self.horizontal_velocity.y
    self.horizontal_velocity.y = 0
}

player_move_camera :: proc "contextless" (self: ^Player, move: variant.Vector2) {
    horizontal := move.x * YawSpeed * MouseSpeed
    vertical := move.y * PitchSpeed * MouseSpeed
    yaw_rotation := math.to_radians(-horizontal)
    pitch_rotation := math.to_radians(-vertical)

    node3d.rotate_y(&self.camera_yaw, yaw_rotation)
    node3d.rotate_x(&self.camera, pitch_rotation)
}

player_move :: proc "contextless" (
    self: ^Player,
    delta: gdextension.Float,
    wish_dir: [3]gdextension.Float,
    friction: gdextension.Float,
    accel: gdextension.Float,
    max_speed: gdextension.Float,
) {
    if (wish_dir == [3]gdextension.Float{0, 0, 0}) {
        self.horizontal_velocity = exp_decay(self.horizontal_velocity, variant.VECTOR3_ZERO, friction, delta)
        if is_zero_approx(self.horizontal_velocity) {
            self.horizontal_velocity = [3]gdextension.Float{0, 0, 0}
        }
    } else {
        self.horizontal_velocity += wish_dir * accel * delta
    }

    self.horizontal_velocity = limit_length(self.horizontal_velocity, max_speed)
}

player_apply_gravity :: proc "contextless" (self: ^Player, delta: gdextension.Float) {
    if self.vertical_speed > -self.max_vertical_speed {
        gravity: gdextension.Float = -10
        if self.vertical_speed > 0 || character_body3d.is_on_floor(&self.object) {
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

player_sweep_stairs_up :: proc "contextless" (self: ^Player, delta: gdextension.Float) {
    if !character_body3d.is_on_floor(&self.object) {
        return
    }
}

player_sweep_stairs_down :: proc "contextless" (self: ^Player, was_grounded: bool) {

}

@(private = "file")
player_create_instance :: proc "c" (class_user_data: rawptr) -> gdextension.ObjectPtr {
    context = gdextension.godot_context()

    self := new(Player)
    self.object = cast(core.Character_Body3d)gdextension.classdb_construct_object(&CharacterBody3D_ClassName)

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
    self.horizontal_velocity = [3]gdextension.Float{0, 0, 0}

    gdextension.object_set_instance(self.object, &Player_ClassName, self)
    gdextension.object_set_instance_binding(self.object, gdextension.library, self, &player_binding_callbacks)

    return cast(gdextension.ObjectPtr)self.object
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
    if engine.is_editor_hint(core.singleton_engine()) {
        return nil
    }

    name_str := cast(^variant.String_Name)name
    if variant.string_name_equal_string_name(Ready_VirtualName, name_str^) {
        return cast(rawptr)player_ready
    } else if variant.string_name_equal_string_name(Input_VirtualName, name_str^) {
        return cast(rawptr)player_input
    } else if variant.string_name_equal_string_name(PhysicsProcess_VirtualName, name_str^) {
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
    if engine.is_editor_hint(core.singleton_engine()) {
        return
    }

    if virtual_call_userdata == cast(rawptr)player_ready {
        player_ready(cast(^Player)instance)
        return
    } else if virtual_call_userdata == cast(rawptr)player_input {
        input_event := cast(^core.Input_Event)args[0]
        player_input(cast(^Player)instance, input_event^)
        return
    } else if virtual_call_userdata == cast(rawptr)player_physics_process {
        delta := cast(^gdextension.Float)args[0]
        player_physics_process(cast(^Player)instance, delta^)
        return
    }
}

@(export)
set_ground_friction :: proc(self: ^Player, value: gdextension.Float) {
    self.ground_friction = value
}

@(export)
get_ground_friction :: proc(self: ^Player) -> gdextension.Float {
    return self.ground_friction
}

@(private = "file")
set_ground_accel :: proc(self: ^Player, value: gdextension.Float) {
    self.ground_accel = value
}

@(private = "file")
get_ground_accel :: proc(self: ^Player) -> gdextension.Float {
    return self.ground_accel
}

@(private = "file")
set_ground_max_speed :: proc(self: ^Player, value: gdextension.Float) {
    self.ground_max_speed = value
}

@(private = "file")
get_ground_max_speed :: proc(self: ^Player) -> gdextension.Float {
    return self.ground_max_speed
}

@(private = "file")
set_max_step_height :: proc(self: ^Player, value: gdextension.Float) {
    self.max_step_height = value
}

@(private = "file")
get_max_step_height :: proc(self: ^Player) -> gdextension.Float {
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
set_gravity_up_scale :: proc(self: ^Player, value: gdextension.Float) {
    self.gravity_up_scale = value
}

@(private = "file")
get_gravity_up_scale :: proc(self: ^Player) -> gdextension.Float {
    return self.gravity_up_scale
}

@(private = "file")
set_gravity_down_scale :: proc(self: ^Player, value: gdextension.Float) {
    self.gravity_down_scale = value
}

@(private = "file")
get_gravity_down_scale :: proc(self: ^Player) -> gdextension.Float {
    return self.gravity_down_scale
}

@(private = "file")
set_air_friction :: proc(self: ^Player, value: gdextension.Float) {
    self.air_friction = value
}

@(private = "file")
get_air_friction :: proc(self: ^Player) -> gdextension.Float {
    return self.air_friction
}

@(private = "file")
set_air_accel :: proc(self: ^Player, value: gdextension.Float) {
    self.air_accel = value
}

@(private = "file")
get_air_accel :: proc(self: ^Player) -> gdextension.Float {
    return self.air_accel
}

@(private = "file")
set_air_max_speed :: proc(self: ^Player, value: gdextension.Float) {
    self.air_max_speed = value
}

@(private = "file")
get_air_max_speed :: proc(self: ^Player) -> gdextension.Float {
    return self.air_max_speed
}

@(private = "file")
set_max_vertical_speed :: proc(self: ^Player, value: gdextension.Float) {
    self.max_vertical_speed = value
}

@(private = "file")
get_max_vertical_speed :: proc(self: ^Player) -> gdextension.Float {
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

    Input_Singleton = core.singleton_input()

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
    gdextension.classdb_unregister_extension_class(gdextension.library, &Player_ClassName)
}

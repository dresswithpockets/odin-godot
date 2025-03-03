package game

// import core "../../../core"
// import gd "../../../gdextension"
// import var "../../../variant"
// import "core:math/linalg"

// // extends CharacterBody3D
// Player :: struct {
//     object:                       gd.ObjectPtr,

//     // Movement On Ground
//     ground_friction:              gd.float,
//     ground_accel:                 gd.float,
//     ground_max_speed:             gd.float,
//     max_step_height:              gd.float,
//     max_step_up_slide_iterations: int,

//     // Movement In Air
//     gravity_up_scale:             gd.float,
//     gravity_down_scale:           gd.float,
//     air_friction:                 gd.float,
//     air_accel:                    gd.float,
//     air_max_speed:                gd.float,
//     max_vertical_speed:           gd.float,

//     // Child Nodes: Camera/Mouse
//     camera_yaw:                   core.Node3d,
//     camera_yaw_mouse:             core.Node3d,
//     camera:                       core.Camera3d,

//     // Child Nodes: Stair Stepping
//     player_shape:                 core.Shape3d,

//     // state
//     vertical_speed:               gd.float,
//     // N.B. we can't use linalg.Vector3fxx since the size isn't known at dev-time
//     horizontal_velocity:          [3]gd.float,
// }

// @(private = "file")
// _player_ready :: proc(self: ^Player) {
//     self_node := cast(core.Node)self.object

//     // TODO: helper method for this?
//     print_string(&CameraYaw_Name)
//     camera_yaw_path := var.new_node_path(CameraYaw_Name)
//     print_node_path(&camera_yaw_path)

//     // camera_yaw_mouse_path := var.new_node_path(CameraYawMouse_Name)
//     // camera_path := var.new_node_path(Camera_Name)
//     // player_shape_path := var.new_node_path(PlayerShape_Name)

//     self.camera_yaw = cast(core.Node3d)core.node_get_node(self_node, camera_yaw_path)
//     // self.camera_yaw_mouse = cast(core.Node3d)core.node_get_node(self_node, camera_yaw_mouse_path)
//     // self.camera = cast(core.Camera3d)core.node_get_node(self_node, camera_path)

//     // player_shape_node := cast(core.CollisionShape3d)core.node_get_node(self_node, player_shape_path)
//     // self.player_shape = core.collision_shape3d_get_shape(player_shape_node)
// }

// @(private = "file")
// _player_input :: proc(self: ^Player, input_event: core.InputEvent) {
// }

// @(private = "file")
// _player_physics_process :: proc(self: ^Player, delta: gd.float) {
//     input_dir := var.new_vector2(0, 0)
//     if core.input_get_mouse_mode(Input^) == .MouseModeCaptured {
//         input_dir = core.input_get_vector(
//             Input^,
//             MoveLeft_InputName,
//             MoveRight_InputName,
//             MoveForward_InputName,
//             MoveBack_InputName,
//             -1.0,
//         )
//     }

//     camera_yaw_basis := core.node3d_get_global_basis(self.camera_yaw)
// }

// @(private = "file")
// _player_emit_stepped_up :: proc "contextless" (self: ^Player, distance: gd.float) {
//     distance := distance

//     signal_argument := var.variant_from(&SteppedUp_SignalName)
//     distance_argument := var.variant_from(&distance)

//     args := [2]gd.VariantPtr{&signal_argument, &distance_argument}

//     ret := var.Variant{}
//     gd.object_method_bind_call(EmitSignal_MethodBind, self.object, &args[0], len(args), &ret, nil)
//     defer gd.variant_destroy(&ret)
// }

// @(private = "file")
// _player_emit_stepped_down :: proc "contextless" (self: ^Player, distance: gd.float) {
//     distance := distance

//     signal_argument := var.variant_from(&SteppedDown_SignalName)
//     distance_argument := var.variant_from(&distance)

//     args := [2]gd.VariantPtr{&signal_argument, &distance_argument}

//     ret := var.Variant{}
//     gd.object_method_bind_call(EmitSignal_MethodBind, self.object, &args[0], len(args), &ret, nil)
//     defer gd.variant_destroy(&ret)
// }

// @(private = "file")
// _player_binding_callbacks := gd.InstanceBindingCallbacks{}

// @(private = "file")
// _player_create_instance :: proc "c" (class_user_data: rawptr) -> gd.ObjectPtr {
//     context = gd.godot_context()

//     self := new(Player)
//     self.object = gd.classdb_construct_object(&CharacterBody3D_ClassName)

//     self.ground_friction = 20.0
//     self.ground_accel = 100.0
//     self.ground_max_speed = 5.0
//     self.max_step_height = 0.6
//     self.max_step_up_slide_iterations = 4

//     self.gravity_up_scale = 1.0
//     self.gravity_down_scale = 1.0
//     self.air_friction = 10.0
//     self.air_accel = 5.0
//     self.air_max_speed = 3.0
//     self.max_vertical_speed = 15.0

//     gd.object_set_instance(self.object, &Player_ClassName, self)
//     gd.object_set_instance_binding(self.object, gd.library, self, &_player_binding_callbacks)

//     return self.object
// }

// @(private = "file")
// _player_free_instance :: proc "c" (class_user_data: rawptr, instance: gd.ExtensionClassInstancePtr) {
//     context = gd.godot_context()

//     if instance == nil {
//         return
//     }

//     free(cast(^Player)instance)
// }

// @(private = "file")
// _player_get_virtual_with_data :: proc "c" (class_user_data: rawptr, name: gd.StringNamePtr) -> rawptr {
//     name := cast(^var.StringName)name
//     if var.string_name_equal(name^, Ready_VirtualName) {
//         return cast(rawptr)_player_ready
//     }

//     if var.string_name_equal(name^, Input_VirtualName) {
//         return cast(rawptr)_player_input
//     }

//     if var.string_name_equal(name^, PhysicsProcess_VirtualName) {
//         return cast(rawptr)_player_physics_process
//     }

//     return nil
// }

// @(private = "file")
// _player_call_virtual_with_data :: proc "c" (
//     instance: gd.ExtensionClassInstancePtr,
//     name: gd.StringNamePtr,
//     virtual_call_user_data: rawptr,
//     args: [^]gd.TypePtr,
//     ret: gd.TypePtr,
// ) {
//     context = gd.godot_context()

//     if core.engine_is_editor_hint(Engine^) {
//         // return
//     }

//     if virtual_call_user_data == cast(rawptr)_player_ready {
//         _player_ready(cast(^Player)instance)
//         return
//     }

//     if virtual_call_user_data == cast(rawptr)_player_input {
//         input_event := cast(^core.InputEvent)args[0]
//         _player_input(cast(^Player)instance, input_event^)
//         return
//     }

//     if virtual_call_user_data == cast(rawptr)_player_physics_process {
//         delta := cast(^gd.float)args[0]
//         _player_physics_process(cast(^Player)instance, delta^)
//         return
//     }
// }

// // shared string names
// Player_ClassName := var.StringName{}
// Object_ClassName := var.StringName{}
// CharacterBody3D_ClassName := var.StringName{}
// Node_ClassName := var.StringName{}

// Ready_VirtualName := var.StringName{}
// Input_VirtualName := var.StringName{}
// PhysicsProcess_VirtualName := var.StringName{}

// SteppedUp_SignalName := var.StringName{}
// SteppedDown_SignalName := var.StringName{}
// Distance_Name := var.StringName{}
// EmitSignal_MethodName := var.StringName{}
// EmitSignal_MethodBind: gd.MethodBindPtr

// MoveLeft_InputName := var.StringName{}
// MoveRight_InputName := var.StringName{}
// MoveForward_InputName := var.StringName{}
// MoveBack_InputName := var.StringName{}
// Input: ^core.Input

// CameraYaw_Name := var.String{}
// CameraYawMouse_Name := var.String{}
// Camera_Name := var.String{}
// PlayerShape_Name := var.String{}

// Engine: ^core.Engine

// player_register :: proc() {
//     gd.string_name_new_with_latin1_chars(&Player_ClassName, "Player", true)
//     gd.string_name_new_with_latin1_chars(&Object_ClassName, "Object", true)
//     gd.string_name_new_with_latin1_chars(&CharacterBody3D_ClassName, "CharacterBody3D", true)

//     gd.string_name_new_with_latin1_chars(&Ready_VirtualName, "_ready", true)
//     gd.string_name_new_with_latin1_chars(&Input_VirtualName, "_input", true)
//     gd.string_name_new_with_latin1_chars(&PhysicsProcess_VirtualName, "_physics_process", true)

//     gd.string_name_new_with_latin1_chars(&SteppedUp_SignalName, "stepped_up", true)
//     gd.string_name_new_with_latin1_chars(&SteppedDown_SignalName, "stepped_down", true)
//     gd.string_name_new_with_latin1_chars(&Distance_Name, "distance", true)
//     gd.string_name_new_with_latin1_chars(&EmitSignal_MethodName, "emit_signal", true)
//     EmitSignal_MethodBind = gd.classdb_get_method_bind(&Object_ClassName, &EmitSignal_MethodName, 4047867050)

//     gd.string_name_new_with_latin1_chars(&MoveLeft_InputName, "move_left", true)
//     gd.string_name_new_with_latin1_chars(&MoveRight_InputName, "move_right", true)
//     gd.string_name_new_with_latin1_chars(&MoveForward_InputName, "move_forward", true)
//     gd.string_name_new_with_latin1_chars(&MoveBack_InputName, "move_back", true)
//     Input = core.singleton_input()

//     gd.string_new_with_latin1_chars(&CameraYaw_Name, "CameraYaw")
//     gd.string_new_with_latin1_chars(&CameraYawMouse_Name, "CameraYaw/MouseMove")
//     gd.string_new_with_latin1_chars(&Camera_Name, "CameraYaw/Camera")
//     gd.string_new_with_latin1_chars(&PlayerShape_Name, "PlayerShape")

//     Engine = core.singleton_engine()

//     class_info := gd.ExtensionClassCreationInfo3 {
//         is_virtual                  = false,
//         is_abstract                 = false,
//         is_exposed                  = true,
//         is_runtime                  = false,
//         set_func                    = nil,
//         get_func                    = nil,
//         get_property_list_func      = nil,
//         free_property_list_func     = nil,
//         property_can_revert_func    = nil,
//         property_get_revert_func    = nil,
//         validate_property_func      = nil,
//         notification_func           = nil,
//         to_string_func              = nil,
//         reference_func              = nil,
//         unreference_func            = nil,
//         create_instance_func        = _player_create_instance,
//         free_instance_func          = _player_free_instance,
//         recreate_instance_func      = nil,
//         get_virtual_func            = nil,
//         get_virtual_call_data_func  = _player_get_virtual_with_data,
//         call_virtual_with_data_func = _player_call_virtual_with_data,
//         get_rid_func                = nil,
//         class_userdata              = nil,
//     }

//     gd.classdb_register_extension_class3(gd.library, &Player_ClassName, &CharacterBody3D_ClassName, &class_info)

//     // bind methods & properties

//     bind_signal(&Player_ClassName, &SteppedUp_SignalName, MethodBindArgument{name = &Distance_Name, type = .Float})
//     bind_signal(&Player_ClassName, &SteppedDown_SignalName, MethodBindArgument{name = &Distance_Name, type = .Float})
// }

// print_string :: proc "contextless" (str: ^var.String) {
//     as_variant: var.Variant
//     gd.get_variant_from_type_constructor(.String)(&as_variant, str)
//     core.gd_print(as_variant)
// }

// print_string_name :: proc "contextless" (str: ^var.StringName) {
//     as_variant: var.Variant
//     gd.get_variant_from_type_constructor(.String)(&as_variant, str)
//     core.gd_print(as_variant)
// }

// print_node_path :: proc "contextless" (node_path: ^var.NodePath) {
//     as_variant: var.Variant
//     gd.get_variant_from_type_constructor(.NodePath)(&as_variant, node_path)
//     core.gd_print(as_variant)
// }

// print_object :: proc "contextless" (object: gd.TypePtr) {
//     as_variant: var.Variant
//     gd.get_variant_from_type_constructor(.Object)(&as_variant, object)
//     core.gd_print(as_variant)
// }

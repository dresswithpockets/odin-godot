package game

import gd "../../../gdextension"

String :: [8]u8
StringName :: [8]u8
NodePath :: [8]u8
Variant :: [8]u8

Node :: rawptr
Node3d :: rawptr
Camera3d :: rawptr
CharacterBody3D :: rawptr
CollisionShape3d :: rawptr
Shape3d :: rawptr

CameraYaw_Name: String
CharacterBody3D_ClassName: StringName
Player_ClassName: StringName
Ready_VirtualName: StringName

player_binding_callbacks := gd.InstanceBindingCallbacks{}

Player :: struct {
    object:     CharacterBody3D,
    camera_yaw: Node3d,
}

@(private = "file")
player_ready :: proc "contextless" (self: ^Player) {
    self_node := cast(Node)self.object
    
    camera_yaw_path: NodePath
    {
        args := [1]gd.TypePtr{ &CameraYaw_Name }
        node_path_from_string(&camera_yaw_path, &args[0])
    }

    {
        args := [1]gd.TypePtr { &camera_yaw_path }
        gd.object_method_bind_ptrcall(get_node_method_bind, self.object, &args[0], &self.camera_yaw)
    }

    print_object(&self.camera_yaw)
}

@(private = "file")
player_create_instance :: proc "c" (class_user_data: rawptr) -> gd.ObjectPtr {
    self := cast(^Player)gd.mem_alloc(size_of(Player))
    self.object = gd.classdb_construct_object(&CharacterBody3D_ClassName)

    gd.object_set_instance(self.object, &Player_ClassName, self)
    gd.object_set_instance_binding(self.object, gd.library, self, &player_binding_callbacks)

    return self.object
}

@(private = "file")
player_free_instance :: proc "c" (class_user_data: rawptr, instance: gd.ExtensionClassInstancePtr) {
    if instance == nil {
        return
    }

    gd.mem_free(instance)
}

@(private = "file")
player_get_virtual_call_data :: proc "c" (class_user_data: rawptr, name: gd.StringNamePtr) -> rawptr {
    if call_builtin_op_bool(StringName_eq_StringName_op, &Ready_VirtualName, name) {
        return cast(rawptr)player_ready
    }

    return nil
}

@(private = "file")
player_call_virtual_with_data :: proc "c" (
    instance: gd.ExtensionClassInstancePtr,
    name: gd.StringNamePtr,
    virtual_call_userdata: rawptr,
    args: [^]gd.TypePtr,
    ret: gd.TypePtr,
) {
    if virtual_call_userdata == cast(rawptr)player_ready {
        player_ready(cast(^Player)instance)
        return
    }
}

player_class_register :: proc "contextless" () {
    gd.string_new_with_latin1_chars(&CameraYaw_Name, "CameraYaw")
    gd.string_name_new_with_latin1_chars(&CharacterBody3D_ClassName, "CharacterBody3D", true)
    gd.string_name_new_with_latin1_chars(&Player_ClassName, "Player", true)
    gd.string_name_new_with_latin1_chars(&Ready_VirtualName, "_ready", true)

    class_info := gd.ExtensionClassCreationInfo3 {
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

    gd.classdb_register_extension_class3(gd.library, &Player_ClassName, &CharacterBody3D_ClassName, &class_info)
}

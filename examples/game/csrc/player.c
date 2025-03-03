#include <stdbool.h>
#include "lib.h"
#include "player.h"

typedef GDExtensionObjectPtr Node;
typedef GDExtensionObjectPtr Node3d;
typedef GDExtensionObjectPtr Camera3d;
typedef GDExtensionObjectPtr CharacterBody3d;
typedef GDExtensionObjectPtr CollisionShape3d;
typedef GDExtensionObjectPtr Shape3d;

String CameraYaw_Name;
StringName CharacterBody3D_ClassName;
StringName Player_ClassName;
StringName Ready_VirtualName;

typedef struct {
    CharacterBody3d object;
    Node3d          camera_yaw;
} Player;

void player_ready(Player* self) {
    Node self_node = self->object;

    NodePath camera_yaw_path;
    {
        GDExtensionConstTypePtr args[1] = { &CameraYaw_Name };
        node_path_from_string(&camera_yaw_path, args);
    }

    {
        GDExtensionConstTypePtr args[1] = { &camera_yaw_path };
        object_method_bind_ptrcall(get_node_method_bind, self->object, args, &self->camera_yaw);
    }

    print_object(&self->camera_yaw);
}

static GDExtensionInstanceBindingCallbacks player_binding_callbacks = {
	.create_callback = NULL,
	.free_callback = NULL,
	.reference_callback = NULL,
};

GDExtensionObjectPtr __cdecl player_create_instance(void* class_userdata) {
    Player* self = gd_alloc(sizeof(Player));
    self->object = classdb_construct_object(&CharacterBody3D_ClassName);

    object_set_instance(self->object, &Player_ClassName, self);
    object_set_instance_binding(self->object, ext_library, self, &player_binding_callbacks);

    return self->object;
}

void __cdecl player_free_instance(void* class_userdata, GDExtensionClassInstancePtr instance) {
    if (!instance) {
        return;
    }

    gd_free(instance);
}

void* __cdecl player_get_virtual_with_data(void* class_userdata, GDExtensionConstStringNamePtr name) {
    if (call_builtin_op_bool(StringName_eq_StringName_op, &Ready_VirtualName, name)) {
        return player_ready;
    }

    return NULL;
}

void __cdecl player_call_virtual_with_data(GDExtensionClassInstancePtr instance, GDExtensionConstStringNamePtr name, void *virtual_call_userdata, const GDExtensionConstTypePtr *args, GDExtensionTypePtr ret) {
    if (virtual_call_userdata == player_ready) {
        player_ready(instance);
        return;
    }
}

void player_class_register() {
    string_new_with_latin1_chars(&CameraYaw_Name, "CameraYaw");
    string_name_new_with_latin1_chars(&CharacterBody3D_ClassName, "CharacterBody3D", true);
    string_name_new_with_latin1_chars(&Player_ClassName, "Player", true);
    string_name_new_with_latin1_chars(&Ready_VirtualName, "_ready", true);

    GDExtensionClassCreationInfo3 class_info = {
        .is_virtual                  = false,
        .is_abstract                 = false,
        .is_exposed                  = true,
        .is_runtime                  = false,
        .set_func                    = NULL,
        .get_func                    = NULL,
        .get_property_list_func      = NULL,
        .free_property_list_func     = NULL,
        .property_can_revert_func    = NULL,
        .property_get_revert_func    = NULL,
        .validate_property_func      = NULL,
        .notification_func           = NULL,
        .to_string_func              = NULL,
        .reference_func              = NULL,
        .unreference_func            = NULL,
        .create_instance_func        = player_create_instance,
        .free_instance_func          = player_free_instance,
        .recreate_instance_func      = NULL,
        .get_virtual_func            = NULL,
        .get_virtual_call_data_func  = player_get_virtual_with_data,
        .call_virtual_with_data_func = player_call_virtual_with_data,
        .get_rid_func                = NULL,
        .class_userdata              = NULL,
    };

    classdb_register_extension_class3(ext_library, &Player_ClassName, &CharacterBody3D_ClassName, &class_info);
}

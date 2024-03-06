package bindgen

import "core:fmt"
import "core:strings"
import "core:thread"
import "core:slice"

/*
State is all of the information transformed from the Api input

State calculates the following:
- odin-case struct, enum, and function names
- backing-field names for function pointers, default values
*/

@(private)
NewState :: struct {
    options:             Options,
    api:                 ^Api,

    // a type map to resolve types from full type names
    all_types: map[string]^NewStateType,
}

NewStateType :: struct {
    type: union {
        NewStateClass,
        NewStateEnum,
        NewStatePodType,
        NewStateNativeStructure,
    },

    // the name to use when specifying the type in the generated odin code
    odin_type: string,
}

NewStatePodType :: struct {
    odin_type: string,
}

NewStateNativeStructure :: struct {
    // the name of the struct in generated odin code
    odin_name: string,
}

// represents an API (core, editor) class or a builtin (variant) class
NewStateClass :: struct {
    // the name of the struct in generated odin code
    odin_name: string,

    is_builtin: bool,
    builtin_info: Maybe(NewStateClassBuiltin),
}

NewStateClassBuiltin :: struct {
    float_32_size: uint,
    float_64_size: uint,
    double_32_size: uint,
    double_64_size: uint,
}

NewStateEnum :: struct {
    // the name of the enum in generated odin code
    odin_name: string,
    is_global: bool,
}

@private
new_pod_type_map := map[string]string{
    "bool"     = "bool",
    "real_t"   = "f64",
    "float"    = "f64",
    "double"   = "f64",
    "int"      = "int",
    "int8_t"   = "i8",
    "int16_t"  = "i16",
    "int32_t"  = "i32",
    "int64_t"  = "i64",
    "uint8_t"  = "u8",
    "uint16_t" = "u16",
    "uint32_t" = "u32",
    "uint64_t" = "u64",
    "int8"     = "i8",
    "int16"    = "i16",
    "int32"    = "i32",
    "int64"    = "i64",
    "uint8"    = "u8",
    "uint16"   = "u16",
    "uint32"   = "u32",
    "uint64"   = "u64",
}

// new_state_godot_type_to_odin :: proc(state: ^NewState, godot_name: string) -> (type: ^NewStateType, ok: bool) {
//     godot_name := godot_name
//     if strings.has_prefix(godot_name, "typedarray::") {
//         godot_name = "Array"
//     }

//     type, ok = state.all_types[godot_name]
//     return
// }

new_state_godot_type_in_map :: proc(state: ^NewState, godot_name: string) -> bool {
    godot_name := godot_name
    if strings.has_prefix(godot_name, "typedarray::") {
        godot_name = "Array"
    }

    return godot_name in state.all_types
}

_state_enum :: proc(state: ^NewState, api_enum: ApiEnum, class_name: Maybe(string) = nil) -> ^NewStateType {
    godot_name := api_enum.name

    // enums in classes must follow the format of "ClassName.EnumName"
    if cname, has_class_name := class_name.(string); has_class_name {
        godot_name = fmt.aprintf("%v.%v", cname, godot_name)
    }

    odin_name := godot_to_odin_case(api_enum.name)
    state_enum := new(NewStateType)
    {
        state_enum.type = NewStateEnum {
            odin_name = odin_name,
            is_global = class_name == nil,
        }

        state_enum.odin_type = odin_name
    }

    state.all_types[godot_name] = state_enum

    if api_enum.is_bitfield {
        godot_name = fmt.aprintf("bitfield::%v", godot_name)
    } else {
        godot_name = fmt.aprintf("enum::%v", godot_name)
    }

    state.all_types[godot_name] = state_enum
    return state_enum
}

create_new_state :: proc(options: Options, api: ^Api) -> (state: ^NewState) {
    state = new(NewState)
    state.options = options
    state.api = api

    // TODO: make all_types map to ^NewStateType instead - we dont want all_types to own the memory of all of the NewStateTypes

    state.all_types = make(map[string]^NewStateType)
    state.global_enums = make([]^NewStateType, len(api.enums))
    state.builtin_classes = make([]^NewStateType, len(api.builtin_classes))
    state.classes = make([]^NewStateType, len(api.classes))
    state.native_structs = make([]^NewStateType, len(api.native_structs))

    builtin_sizes := make(map[string]map[string]uint, allocator = context.temp_allocator)
    for size_config in api.builtin_sizes {
        config_map := make(map[string]uint, allocator = context.temp_allocator)
        for pair in size_config.sizes {
            config_map[pair.name] = pair.size
        }
        builtin_sizes[size_config.configuration] = config_map
    }
    defer free_all(context.temp_allocator)

    for c_type, odin_type in new_pod_type_map {
        {
            state_type := new(NewStateType)
            state_type.odin_type = odin_type
            state_type.type = NewStatePodType {
                odin_type = odin_type,
            }

            state.all_types[c_type] = state_type
        }

        // pointer
        {
            // all single-pointers have no space between the base type and the star
            godot_name := fmt.aprintf("%v*", c_type)
            real_odin_type := fmt.aprintf("^%v", odin_type)
            state_type := new(NewStateType)
            state_type.odin_type = real_odin_type
            state_type.type = NewStatePodType {
                odin_type = real_odin_type,
            }

            state.all_types[godot_name] = state_type
        }

        // double pointer
        {
            // all double-pointers have a space between the base type and the stars
            godot_name := fmt.aprintf("%v **", c_type)
            real_odin_type := fmt.aprintf("^^%v", odin_type)
            state_type := new(NewStateType)
            state_type.odin_type = real_odin_type
            state_type.type = NewStatePodType {
                odin_type = real_odin_type,
            }

            state.all_types[godot_name] = state_type
        }

        // const pointer
        {
            // all single-pointers have no space between the base type and the star
            godot_name := fmt.aprintf("const %v*", c_type)
            real_odin_type := fmt.aprintf("^%v", odin_type)
            state_type := new(NewStateType)
            state_type.odin_type = real_odin_type
            state_type.type = NewStatePodType {
                odin_type = real_odin_type,
            }

            state.all_types[godot_name] = state_type
        }

        // const double pointer
        {
            // all double-pointers have a space between the base type and the stars
            godot_name := fmt.aprintf("const %v **", c_type)
            real_odin_type := fmt.aprintf("^^%v", odin_type)
            state_type := new(NewStateType)
            state_type.odin_type = real_odin_type
            state_type.type = NewStatePodType {
                odin_type = real_odin_type,
            }

            state.all_types[godot_name] = state_type
        }
    }

    // void pointer
    {
        state_type := new(NewStateType)
        state_type.odin_type = "rawptr"
        state_type.type = NewStatePodType {
            odin_type = "rawptr",
        }

        state.all_types["void*"] = state_type
    }

    {
        state_type := new(NewStateType)
        state_type.odin_type = "rawptr"
        state_type.type = NewStatePodType {
            odin_type = "rawptr",
        }

        state.all_types["const void*"] = state_type
    }

    for api_enum, i in api.enums {
        enum_type := _state_enum(state, api_enum)
    }

    for api_builtin_class in api.builtin_classes {
        odin_name := godot_to_odin_case(api_builtin_class.name)
        state_class := new(NewStateType)
        state_class.odin_type = odin_name
        state_class.type = NewStateClass {
            odin_name = odin_name,

            is_builtin = true,
            builtin_info = NewStateClassBuiltin {
                float_32_size = builtin_sizes["float_32"][api_builtin_class.name],
                float_64_size = builtin_sizes["float_64"][api_builtin_class.name],
                double_32_size = builtin_sizes["double_32"][api_builtin_class.name],
                double_64_size = builtin_sizes["double_64"][api_builtin_class.name],
            },
        }

        state.all_types[api_builtin_class.name] = state_class

        for api_enum in api_builtin_class.enums {
            _state_enum(state, api_enum, api_builtin_class.name)
        }
    }

    // special builtin class Variant
    {
        state_type := new(NewStateType)
        state_type.odin_type = "Variant"
        state_type.type = NewStateClass {
            odin_name = "Variant",
        }

        state.all_types["Variant"] = state_type
    }

    for api_class in api.classes {
        odin_name := godot_to_odin_case(api_class.name)
        state_class := new(NewStateType)
        state_class.odin_type = odin_name
        state_class.type = NewStateClass {
            odin_name = odin_name,
        }

        state.all_types[api_class.name] = state_class

        for api_enum in api_class.enums {
            _state_enum(state, api_enum, api_class.name)
        }
    }

    for native_struct in api.native_structs {
        odin_name := godot_to_odin_case(native_struct.name)
        {
            state_struct := new(NewStateType)
            state_struct.odin_type = odin_name
            state_struct.type = NewStateNativeStructure {
                odin_name = odin_name,
            }
            state.all_types[native_struct.name] = state_struct
        }

        // pointer
        {
            godot_name := fmt.aprintf("%v*", native_struct.name)
            real_odin_type := fmt.aprintf("^%v", odin_name)
            state_struct := new(NewStateType)
            state_struct.odin_type = real_odin_type
            state_struct.type = NewStateNativeStructure {
                odin_name = real_odin_type,
            }
            state.all_types[godot_name] = state_struct
        }

        // const pointer
        {
            godot_name := fmt.aprintf("const %v*", native_struct.name)
            real_odin_type := fmt.aprintf("^%v", odin_name)
            state_struct := new(NewStateType)
            state_struct.odin_type = real_odin_type
            state_struct.type = NewStateNativeStructure {
                odin_name = real_odin_type,
            }
            state.all_types[godot_name] = state_struct
        }
    }

    return
}
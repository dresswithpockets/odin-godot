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
    all_types: map[string]NewStateType
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
}

NewStateEnum :: struct {
    // the name of the enum in generated odin code
    odin_name: string,
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

_state_enum :: proc(state: ^NewState, api_enum: ApiEnum, class_name: Maybe(string) = nil) {
    godot_name := api_enum.name

    // enums in classes must follow the format of "ClassName.EnumName"
    if cname, has_class_name := class_name.(string); has_class_name {
        godot_name = fmt.aprintf("%v.%v", cname, godot_name)
    }

    odin_name := godot_to_odin_case(api_enum.name)
    state_enum := NewStateType {
        type = NewStateEnum {
            odin_name = odin_name,
        },

        odin_type = odin_name,
    }

    state.all_types[godot_name] = state_enum

    if api_enum.is_bitfield {
        godot_name = fmt.aprintf("bitfield::%v", godot_name)
    } else {
        godot_name = fmt.aprintf("enum::%v", godot_name)
    }

    state.all_types[godot_name] = state_enum
}

create_new_state :: proc(options: Options, api: ^Api) -> (state: ^NewState) {
    state = new(NewState)
    state.options = options
    state.api = api

    state.all_types = make(map[string]NewStateType)

    for c_type, odin_type in new_pod_type_map {
        state.all_types[c_type] = NewStateType {
            type = NewStatePodType {
                odin_type = odin_type,
            },

            odin_type = odin_type,
        }

        // pointer
        godot_name := fmt.aprintf("%v*", c_type)
        real_odin_type := fmt.aprintf("^%v", odin_type)
        state.all_types[godot_name] = NewStateType {
            type = NewStatePodType {
                odin_type = real_odin_type,
            },

            odin_type = real_odin_type,
        }

        // double pointer
        godot_name = fmt.aprintf("%v **", c_type)
        real_odin_type = fmt.aprintf("^^%v", odin_type)
        state.all_types[godot_name] = NewStateType {
            type = NewStatePodType {
                odin_type = real_odin_type,
            },

            odin_type = real_odin_type,
        }

        // const pointer
        godot_name = fmt.aprintf("const %v*", c_type)
        real_odin_type = fmt.aprintf("^%v", odin_type)
        state.all_types[godot_name] = NewStateType {
            type = NewStatePodType {
                odin_type = real_odin_type,
            },

            odin_type = real_odin_type,
        }

        // const double pointer
        godot_name = fmt.aprintf("const %v **", c_type)
        real_odin_type = fmt.aprintf("^^%v", odin_type)
        state.all_types[godot_name] = NewStateType {
            type = NewStatePodType {
                odin_type = real_odin_type,
            },

            odin_type = real_odin_type,
        }
    }

    // void pointers
    state.all_types["void*"] = NewStateType {
        type = NewStatePodType {
            odin_type = "rawptr",
        },

        odin_type = "rawptr",
    }

    // N.B. in all cases in Godot, double-pointers are buffers
    state.all_types["void**"] = NewStateType {
        type = NewStatePodType {
            odin_type = "[^]rawptr",
        },

        odin_type = "[^]rawptr",
    }

    state.all_types["const void*"] = NewStateType {
        type = NewStatePodType {
            odin_type = "rawptr",
        },

        odin_type = "rawptr",
    }

    // N.B. in all cases in Godot, double-pointers are buffers
    state.all_types["const void**"] = NewStateType {
        type = NewStatePodType {
            odin_type = "[^]rawptr",
        },

        odin_type = "[^]rawptr",
    }

    for api_enum in api.enums {
        _state_enum(state, api_enum)
    }

    for api_builtin_class in api.builtin_classes {
        odin_name := godot_to_odin_case(api_builtin_class.name)
        state_class := NewStateType {
            type = NewStateClass {
                odin_name = odin_name,
            },

            odin_type = odin_name,
        }

        state.all_types[api_builtin_class.name] = state_class

        for api_enum in api_builtin_class.enums {
            _state_enum(state, api_enum, api_builtin_class.name)
        }
    }

    // special builtin class Variant
    state.all_types["Variant"] = NewStateType {
        type = NewStateClass {
            odin_name = "Variant",
        },

        odin_type = "Variant",
    }

    for api_class in api.classes {
        odin_name := godot_to_odin_case(api_class.name)
        state_class := NewStateType {
            type = NewStateClass {
                odin_name = odin_name,
            },

            odin_type = odin_name,
        }

        state.all_types[api_class.name] = state_class

        for api_enum in api_class.enums {
            _state_enum(state, api_enum, api_class.name)
        }
    }

    for native_struct in api.native_structs {
        odin_name := godot_to_odin_case(native_struct.name)
        state_struct := NewStateType {
            type = NewStateNativeStructure {
                odin_name = odin_name,
            },

            odin_type = odin_name,
        }

        // pointer
        godot_name := fmt.aprintf("%v*", native_struct.name)
        real_odin_type := fmt.aprintf("^%v", odin_name)
        state.all_types[godot_name] = NewStateType {
            type = NewStateNativeStructure {
                odin_name = real_odin_type,
            },

            odin_type = real_odin_type,
        }

        // const pointer
        godot_name = fmt.aprintf("const %v*", native_struct.name)
        real_odin_type = fmt.aprintf("^%v", odin_name)
        state.all_types[godot_name] = NewStateType {
            type = NewStateNativeStructure {
                odin_name = real_odin_type,
            },

            odin_type = real_odin_type,
        }
    }

    return
}
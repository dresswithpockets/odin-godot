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
        NewStateNativeType,
    },

    // the name to use when specifying the type in the generated odin code
    odin_type: string,
}

NewStateNativeType :: struct {
    odin_type: union {string, NewStateNativeStructure},
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

create_new_state :: proc(options: Options, api: ^Api) -> (state: ^NewState) {
    state = new(NewState)
    state.options = options
    state.api = api

    state.all_types = make(map[string]NewStateType)

    for c_type, odin_type in new_pod_type_map {
        state.all_types[c_type] = NewStateType {
            type = NewStateNativeType {
                odin_type = odin_type,
            },

            odin_type = odin_type,
        }

        // pointer
        godot_name := fmt.aprintf("%v*", c_type)
        real_odin_type := fmt.aprintf("^%v", odin_type)
        state.all_types[godot_name] = NewStateType {
            type = NewStateNativeType {
                odin_type = real_odin_type,
            },

            odin_type = real_odin_type,
        }

        // double pointer
        godot_name = fmt.aprintf("%v **", c_type)
        real_odin_type = fmt.aprintf("^^%v", odin_type)
        state.all_types[godot_name] = NewStateType {
            type = NewStateNativeType {
                odin_type = real_odin_type,
            },

            odin_type = real_odin_type,
        }

        // const pointer
        godot_name := fmt.aprintf("const %v*", c_type)
        real_odin_type := fmt.aprintf("^%v", odin_type)
        state.all_types[godot_name] = NewStateType {
            type = NewStateNativeType {
                odin_type = real_odin_type,
            },

            odin_type = real_odin_type,
        }

        // const double pointer
        godot_name = fmt.aprintf("const %v **", c_type)
        real_odin_type = fmt.aprintf("^^%v", odin_type)
        state.all_types[godot_name] = NewStateType {
            type = NewStateNativeType {
                odin_type = real_odin_type,
            },

            odin_type = real_odin_type,
        }
    }

    // void pointers
    state.all_types["void*"] = NewStateType {
        type = NewStateNativeType {
            pointer_depth = 0,
            odin_type = "rawptr",
        },

        odin_type = "rawptr",
    }

    // N.B. in all cases in Godot, double-pointers are buffers
    state.all_types["void**"] = NewStateType {
        type = NewStateNativeType {
            pointer_depth = 0,
            odin_type = "[^]rawptr",
        },

        odin_type = "[^]rawptr",
    }

    state.all_types["const void*"] = NewStateType {
        type = NewStateNativeType {
            pointer_depth = 0,
            odin_type = "rawptr",
        },

        odin_type = "rawptr",
    }

    // N.B. in all cases in Godot, double-pointers are buffers
    state.all_types["const void**"] = NewStateType {
        type = NewStateNativeType {
            pointer_depth = 0,
            odin_type = "[^]rawptr",
        },

        odin_type = "[^]rawptr",
    }

    for api_enum in api.enums {
        odin_name := godot_to_odin_case(api_enum.name)
        state_enum := NewStateType {
            type = NewStateEnum {
                odin_name = odin_name,
            },

            odin_name = odin_name,
        }

        state.all_types[api_enum.name] = state_enum
    }

    for api_builtin_class in api.builtin_classes {
        odin_name := godot_to_odin_case(api_builtin_class.name)
        state_class := NewStateType {
            type = NewStateClass {
                odin_name = odin_name,
            },

            odin_name = odin_name,
        }

        state.all_types[api_builtin_class.name] = state_class
    }

    for api_class in api.classes {
        odin_name := godot_to_odin_case(api_class.name)
        state_class := NewStateType {
            type = NewStateClass {
                odin_name = odin_name,
            },

            odin_name = odin_name,
        }

        state.all_types[api_class.name] = state_class
    }

    return
}
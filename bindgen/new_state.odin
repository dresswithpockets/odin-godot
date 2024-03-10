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

    global_enums:    []^NewStateType,
    builtin_classes: []^NewStateType,
    classes:         []^NewStateType,
    native_structs:  []^NewStateType,
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

    odin_skip: bool,
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

    enums: []^NewStateType,
    methods: []NewStateClassMethod,

    is_builtin: bool,
    builtin_info: Maybe(NewStateClassBuiltin),
}

NewStateClassMethod :: struct {
    odin_name: string,
    godot_name: string,
    hash: i64,

    arguments: []^NewStateClassMethodArgument,
    return_type: Maybe(^NewStateType),
}

NewStateClassMethodArgument :: struct {
    name: string,
    type: ^NewStateType,
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

    // the ordered key-value pairs of all enum values
    odin_values: []NewStateEnumValue
}

NewStateEnumValue :: struct {
    name: string,
    value: int,
}

// some enums are pre-implemented in the gdextension package, and should be skipped
// during generation
@private
skip_enums_by_name :: []string{"Variant.Operator", "Variant.Type"}

@private
enum_prefix_alias := map[string]string {
    "Error" = "Err",
}

@private
skip_builtin_types_by_name :: []string{
    "Nil",
    "void",
    "bool",
    "real_t",
    "float",
    "double",
    "int",
    "int8_t",
    "uint8_t",
    "int16_t",
    "uint16_t",
    "int32_t",
    "int64_t",
    "uint32_t",
    "uint64_t",
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
    odin_name := godot_name

    // enums in classes must follow the format of "ClassName.EnumName"
    // and the odin name must follow the foramt of "ClassName_EnumName"
    if cname, has_class_name := class_name.(string); has_class_name {
        odin_name = godot_to_odin_case(fmt.aprintf("%v_%v", cname, godot_name))
        godot_name = fmt.aprintf("%v.%v", cname, godot_name)
    } else {
        odin_name = godot_to_odin_case(godot_name)
    }

    state_type := new(NewStateType)
    state_type.odin_type = odin_name
    state_enum := NewStateEnum {
        odin_name = odin_name,
        odin_values = make([]NewStateEnumValue, len(api_enum.values)),
    }
    state_type.type = state_enum

    // we skip over some enums by name, such as those pre-implemented in gdextension
    state_type.odin_skip = slice.contains(skip_enums_by_name, api_enum.name)

    // godot's enums use CONST_CASE for their values, and usually
    // have a prefix. e.e `GDExtensionVariantType` uses the prefix
    // `GDEXTENSION_VARIANT_TYPE_`. The prefix gets stripped before
    // the value is generated in odin.
    const_case_prefix := odin_to_const_case(odin_name)
    defer delete(const_case_prefix)

    // gotta do all of that for the prefix alias if there is one
    prefix_alias, has_alias := enum_prefix_alias[api_enum.name]
    const_case_prefix_alias: string
    if has_alias {
        const_case_prefix_alias = odin_to_const_case(prefix_alias)
    }
    defer if has_alias {
        delete(const_case_prefix_alias)
    }

    // godot has a convention for "Flags" enums, where the prefix used
    // by values isn't always plural. e.g `MethodFlags` has 
    // `METHOD_FLAG_NORMAL`, as well as `METHOD_FLAGS_DEFAULT`.
    // The latter will get caught by const_case_prefix, but we also
    // need to have a prefix for the singular variation of the prefix
    is_flags := strings.has_suffix(api_enum.name, "Flags")
    flag_prefix: string
    without_flags_prefix: string
    if is_flags {
        // chops off the s at the end
        flag_prefix = const_case_prefix[:len(const_case_prefix) - 1]
        // also a variation for enums where the "FLAGS_" portion of the
        // value prefix is completely dropped. e.g `PropertyUsageFlags`
        // uses the prefix `PROPERTY_USAGE_` instead of `PROPERTY_USAGE_FLAG`
        without_flags_prefix = const_case_prefix[:len(const_case_prefix) - 5]
    }

    for value, i in api_enum.values {
        name := value.name
        if len(name) != len(const_case_prefix) {
            name = strings.trim_prefix(name, const_case_prefix)
        }

        if has_alias && len(name) != len(const_case_prefix_alias) {
            name = strings.trim_prefix(name, const_case_prefix_alias)
        }

        if is_flags {
            if len(name) != len(flag_prefix) {
                name = strings.trim_prefix(name, flag_prefix)
            }

            if len(name) != len(without_flags_prefix) {
                name = strings.trim_prefix(name, without_flags_prefix)
            }
        }

        // we might have a lingering _ after we removed the prefix
        if name[0] == '_' && len(name) > 1 {
            name = name[1:]
        }
        name = const_to_odin_case(name)
        state_enum.odin_values[i] = NewStateEnumValue {
            name = name,
            value = value.value,
        }
    }

    state.all_types[godot_name] = state_type

    if api_enum.is_bitfield {
        godot_name = fmt.aprintf("bitfield::%v", godot_name)
    } else {
        godot_name = fmt.aprintf("enum::%v", godot_name)
    }

    state.all_types[godot_name] = state_type
    return state_type
}

_class_method_name :: proc(class_name: string, godot_method_name: string) -> string {
    snake_case_class := odin_to_snake_case(class_name)
    defer delete(snake_case_class)
    return fmt.aprintf("%v_%v", snake_case_class, godot_method_name)
}

create_new_state :: proc(options: Options, api: ^Api) -> (state: ^NewState) {
    state = new(NewState)
    state.options = options
    state.api = api

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
        state.global_enums[i] = enum_type
    }

    for api_builtin_class, i in api.builtin_classes {
        odin_name := godot_to_odin_case(api_builtin_class.name)
        state_type := new(NewStateType)
        state_type.odin_type = odin_name
        state_type.odin_skip = slice.contains(skip_builtin_types_by_name, api_builtin_class.name)
        state_class := NewStateClass {
            odin_name = odin_name,

            enums = make([]^NewStateType, len(api_builtin_class.enums)),
            methods = make([]NewStateClassMethod, len(api_builtin_class.methods)),

            is_builtin = true,
            builtin_info = NewStateClassBuiltin {
                float_32_size = builtin_sizes["float_32"][api_builtin_class.name],
                float_64_size = builtin_sizes["float_64"][api_builtin_class.name],
                double_32_size = builtin_sizes["double_32"][api_builtin_class.name],
                double_64_size = builtin_sizes["double_64"][api_builtin_class.name],
            },
        }
        state_type.type = state_class

        state.all_types[api_builtin_class.name] = state_type
        state.builtin_classes[i] = state_type

        for api_enum, i in api_builtin_class.enums {
            state_enum := _state_enum(state, api_enum, api_builtin_class.name)
            state_class.enums[i] = state_enum
        }

        for api_method, i in api_builtin_class.methods {
            state_class.methods[i] = NewStateClassMethod {
                odin_name = _class_method_name(state_class.odin_name, api_method.name),
                godot_name = api_method.name,
                hash = api_method.hash,
            }
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
#+feature dynamic-literals
package bindgen

import "core:fmt"
import "core:slice"
import "core:strings"

/*
State is all of the information transformed from the Api input

State calculates the following:
- odin-case struct, enum, and function names
- backing-field names for function pointers, default values
*/

@(private)
State :: struct {
    options:           Options,
    api:               ^Api,

    // a type map to resolve types from full type names
    all_types:         map[string]^StateType,
    global_enums:      []^StateType,
    builtin_classes:   []^StateType,
    classes:           []^StateType,
    native_structs:    []^StateType,
    core_singletons:   [dynamic]StateSingleton,
    editor_singletons: [dynamic]StateSingleton,
    utility_functions: []StateFunction,
}

StateSingleton :: struct {
    name:       string,
    snake_name: string,
    odin_type:  string,
}

StateType :: struct {
    derived:              union {
        StateClass,
        StateEnum,
        StatePodType,
        StateNativeStructure,
    },

    // the name to use when specifying the type in the generated odin code
    odin_type:            string,
    godot_type:           string,
    snake_type:           string,

    // the name to use when the VariantType is required
    variant_type:         Maybe(string),
    odin_skip:            bool,
    depends_on_core_math: bool,
}

StatePodType :: struct {
    odin_type: string,
}

StateNativeStructure :: struct {
    // the name of the struct in generated odin code
    odin_name:    string,
    fields:       []StateNativeStructureField,
    has_defaults: bool,
}

StateNativeStructureField :: struct {
    name:            string,
    type:            ^StateType,
    array_specifier: string,
    default:         string,
}

// represents an API (core, editor) class or a builtin (variant) class
StateClass :: struct {
    // the name of the struct in generated odin code
    odin_name:    string,
    enums:        []^StateType,
    methods:      []StateFunction,
    operators:    []StateOperator,
    constants:    []StateConstant,
    api_type:     string,
    inherits:     ^StateType,
    is_builtin:   bool,
    builtin_info: Maybe(StateClassBuiltin),
}

StateClassConstructor :: struct {
    odin_name: string,
    arguments: []StateFunctionArgument,
}

StateFunction :: struct {
    odin_skip:   bool,
    odin_name:   string,
    godot_name:  string,
    hash:        i64,
    arguments:   []StateFunctionArgument,
    return_type: Maybe(^StateType),
}

StateOperator :: struct {
    // proc group name
    odin_name:    string,

    // VariantOperator name
    variant_name: string,
    overloads:    []StateOperatorOverload,
}

StateConstant :: struct {
    name:      string,
    type:      ^StateType,
    value:     union {
        int,
        string,
    },
    odin_skip: bool,
}

StateOperatorOverload :: struct {
    // proc name
    odin_name:   string,

    // should never be nil
    return_type: ^StateType,

    // may be nil
    right_type:  ^StateType,
}

StateFunctionArgument :: struct {
    name: string,
    type: ^StateType,
}

StateClassBuiltin :: struct {
    float_32_size:         uint,
    float_64_size:         uint,
    double_32_size:        uint,
    double_64_size:        uint,
    base_constructor_name: string,
    constructors:          []StateClassConstructor,
    destructor_name:       Maybe(string),
    members:               []StateClassBuiltinMember,
}

StateClassBuiltinMember :: struct {
    odin_prefix: string,
    name:        string,
    type:        ^StateType,
}

StateEnum :: struct {
    // the name of the enum in generated odin code
    odin_name:    string,

    // the ordered key-value pairs of all enum values
    odin_values:  []StateEnumValue,
    parent_class: Maybe(^StateType),
}

StateEnumValue :: struct {
    name:  string,
    value: int,
}

// some enums are pre-implemented in the gdextension package, and should be skipped
// during generation
@(private)
skip_enums_by_name :: []string{"Variant.Operator", "Variant.Type"}

@(private)
enum_prefix_alias := map[string]string {
    "Error" = "Err",
}

@(private)
skip_builtin_types_by_name :: []string {
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
    "char32",
}

@(private)
new_pod_type_map := map[string]string {
    "bool"     = "bool",

    // TODO: these should map to gd.float, not f64
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

    // TODO: this should map to c.uint_least32_t
    "char32"   = "u32",
}

operator_enum_map := map[string]string {
    // comparison
    "=="     = "Equal",
    "!="     = "NotEqual",
    "<"      = "Less",
    "<="     = "LessEqual",
    ">"      = "Greater",
    ">="     = "GreaterEqual",

    // maths
    "+"      = "Add",
    "-"      = "Subtract",
    "*"      = "Multiply",
    "/"      = "Divide",
    "unary-" = "Negate",
    "unary+" = "Positive",
    "%"      = "Module",
    "**"     = "Power",

    // bits
    "<<"     = "ShiftLeft",
    ">>"     = "ShiftRight",
    "&"      = "BitAnd",
    "|"      = "BitOr",
    "^"      = "BitXor",
    "~"      = "BitNegate",

    // logic
    "and"    = "And",
    "or"     = "Or",
    "xor"    = "Xor",
    "not"    = "Not",

    // containment
    "in"     = "In",
}

// new_state_godot_type_to_odin :: proc(state: ^State, godot_name: string) -> (type: ^StateType, ok: bool) {
//     godot_name := godot_name
//     if strings.has_prefix(godot_name, "typedarray::") {
//         godot_name = "Array"
//     }

//     type, ok = state.all_types[godot_name]
//     return
// }

new_state_godot_type_in_map :: proc(state: ^State, godot_name: string) -> bool {
    godot_name := godot_name
    if strings.has_prefix(godot_name, "typedarray::") {
        godot_name = "Array"
    }

    return godot_name in state.all_types
}

_state_enum :: proc(state: ^State, api_enum: ApiEnum, class: Maybe(^StateType) = nil) -> ^StateType {
    godot_name := api_enum.name
    odin_name := godot_to_odin_case(godot_name)

    // enums in classes must follow the format of "ClassName.EnumName"
    // and the odin name must follow the foramt of "ClassName_EnumName"
    if parent_class, has_parent_class := class.(^StateType); has_parent_class {
        odin_name = fmt.aprintf("%v_%v", parent_class.odin_type, odin_name)
        godot_name = fmt.aprintf("%v.%v", parent_class.godot_type, godot_name)
    }

    state_type := new(StateType)
    state_type.odin_type = odin_name
    state_type.godot_type = api_enum.name
    state_type.snake_type = godot_to_snake_case(api_enum.name)
    state_enum := StateEnum {
        odin_name    = odin_name,
        odin_values  = make([]StateEnumValue, len(api_enum.values)),
        parent_class = class,
    }
    state_type.derived = state_enum

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
        state_enum.odin_values[i] = StateEnumValue {
            name  = name,
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

_class_operator_name :: proc(class_name: string, variant_name: string) -> string {
    snake_case_class := odin_to_snake_case(class_name)
    snake_case_name := odin_to_snake_case(variant_name)
    defer {
        delete(snake_case_class)
        delete(snake_case_name)
    }
    return fmt.aprintf("%v_%v", snake_case_class, snake_case_name)
}

_class_operator_overload_name :: proc(
    class_name: string,
    variant_name: string,
    right_type_variant_name: string,
) -> string {
    snake_case_right := "self" if right_type_variant_name == "Nil" else odin_to_snake_case(right_type_variant_name)
    defer if right_type_variant_name != "Nil" {
        delete(snake_case_right)
    }
    return fmt.aprintf("%v_%v", _class_operator_name(class_name, variant_name), snake_case_right)
}

_unique_operators_count :: proc(operators: []ApiClassOperator) -> int {
    operator_overloads := make(map[string]int)
    for api_operator in operators {
        operator_name, ok := operator_enum_map[api_operator.name]
        assert(ok)
        operator_overloads[operator_name] = 0
    }

    return len(operator_overloads)
}

_class_constructor_name :: proc(base_constructor_name: string, arguments: []StateFunctionArgument) -> string {
    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    fmt.sbprint(&sb, base_constructor_name)
    if len(arguments) == 0 {
        fmt.sbprint(&sb, "_default")
        return strings.clone(strings.to_string(sb))
    }

    for argument in arguments {
        snake_type := odin_to_snake_case(argument.type.odin_type)
        fmt.sbprintf(&sb, "_%v", snake_type)
    }

    return strings.clone(strings.to_string(sb))
}

_native_struct_fields :: proc(state: ^State, format: string) -> []StateNativeStructureField {
    // HACK: its really gross to allocate this much when i could be using split_iterator...
    //       but i was having some unusual issues with split_iterator, it didnt behave as expected.
    field_strings := strings.split(format, ";")
    fields := make([]StateNativeStructureField, len(field_strings))
    for field_string, field_idx in field_strings {
        parts := strings.split(field_string, " ")
        type_string := parts[0]
        name_string := parts[1]

        type_string, _ = strings.replace(type_string, "::", ".", 1)

        if strings.has_prefix(name_string, "*") {
            type_string = fmt.tprintf("%s*", type_string)
            name_string = name_string[1:]
        }

        array_specifier := ""
        if array_spec_idx := strings.index_rune(name_string, '['); array_spec_idx >= 0 {
            array_specifier = name_string[array_spec_idx:]
            name_string = name_string[:array_spec_idx]
        }

        odin_type, odin_type_ok := state.all_types[type_string]
        assert(odin_type_ok)

        // the field has a default!
        default := ""
        if len(parts) > 2 {
            default = parts[len(parts) - 1]
            // odin fields are 0 by default
            if default == "0.f" || default == "0" {
                default = ""
            }
        }

        fields[field_idx] = StateNativeStructureField {
            name            = name_string,
            type            = odin_type,
            array_specifier = array_specifier,
            default         = default,
        }
    }

    return fields
}

create_new_state :: proc(options: Options, api: ^Api) -> (state: ^State) {
    state = new(State)
    state.options = options
    state.api = api

    state.all_types = make(map[string]^StateType)
    state.global_enums = make([]^StateType, len(api.enums))
    // we add an additional 2 items to the builtin classes array for the special Variant and Object types
    state.builtin_classes = make([]^StateType, len(api.builtin_classes) + 3)
    state.classes = make([]^StateType, len(api.classes))
    state.native_structs = make([]^StateType, len(api.native_structs))

    state.core_singletons = make([dynamic]StateSingleton)
    state.editor_singletons = make([dynamic]StateSingleton)
    state.utility_functions = make([]StateFunction, len(api.util_functions))

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
            state_type := new(StateType)
            state_type.odin_type = odin_type
            state_type.variant_type = godot_to_odin_case(c_type)
            state_type.derived = StatePodType {
                odin_type = odin_type,
            }

            state.all_types[c_type] = state_type
        }

        // pointer
        {
            // all single-pointers have no space between the base type and the star
            godot_name := fmt.aprintf("%v*", c_type)
            real_odin_type := fmt.aprintf("^%v", odin_type)
            state_type := new(StateType)
            state_type.odin_type = real_odin_type
            state_type.derived = StatePodType {
                odin_type = real_odin_type,
            }

            state.all_types[godot_name] = state_type
        }

        // double pointer
        {
            // all double-pointers have a space between the base type and the stars
            godot_name := fmt.aprintf("%v **", c_type)
            real_odin_type := fmt.aprintf("^^%v", odin_type)
            state_type := new(StateType)
            state_type.odin_type = real_odin_type
            state_type.derived = StatePodType {
                odin_type = real_odin_type,
            }

            state.all_types[godot_name] = state_type
        }

        // const pointer
        {
            // all single-pointers have no space between the base type and the star
            godot_name := fmt.aprintf("const %v*", c_type)
            real_odin_type := fmt.aprintf("^%v", odin_type)
            state_type := new(StateType)
            state_type.odin_type = real_odin_type
            state_type.derived = StatePodType {
                odin_type = real_odin_type,
            }

            state.all_types[godot_name] = state_type
        }

        // const double pointer
        {
            // all double-pointers have a space between the base type and the stars
            godot_name := fmt.aprintf("const %v **", c_type)
            real_odin_type := fmt.aprintf("^^%v", odin_type)
            state_type := new(StateType)
            state_type.odin_type = real_odin_type
            state_type.derived = StatePodType {
                odin_type = real_odin_type,
            }

            state.all_types[godot_name] = state_type
        }
    }

    // void pointer
    {
        state_type := new(StateType)
        state_type.odin_type = "rawptr"
        state_type.derived = StatePodType {
            odin_type = "rawptr",
        }

        state.all_types["void*"] = state_type
    }

    {
        state_type := new(StateType)
        state_type.odin_type = "rawptr"
        state_type.derived = StatePodType {
            odin_type = "rawptr",
        }

        state.all_types["const void*"] = state_type
    }

    for api_enum, i in api.enums {
        enum_type := _state_enum(state, api_enum)
        state.global_enums[i] = enum_type
    }

    // builtin classes initial pass - another one is made down further for operators, methods, constructors
    for api_builtin_class, api_builtin_class_index in api.builtin_classes {
        // TODO: handle is_keyed
        // TODO: handle indexing_return_type (these can be special cases for Array/Dictionary/PackedXXArray)
        odin_name := godot_to_odin_case(api_builtin_class.name)
        snake_name := godot_to_snake_case(api_builtin_class.name)
        defer delete(snake_name) // we only use the snake name to build other strings
        state_type := new(StateType)
        state_type.odin_type = odin_name
        state_type.godot_type = api_builtin_class.name
        state_type.snake_type = snake_name
        state_type.odin_skip = slice.contains(skip_builtin_types_by_name, api_builtin_class.name)
        state_class := StateClass {
            odin_name = odin_name,
            enums = make([]^StateType, len(api_builtin_class.enums)),
            methods = make([]StateFunction, len(api_builtin_class.methods)),
            operators = make([]StateOperator, _unique_operators_count(api_builtin_class.operators)),
            constants = make([]StateConstant, len(api_builtin_class.constants)),
            api_type = "variant",
            is_builtin = true,
            builtin_info = StateClassBuiltin {
                float_32_size = builtin_sizes["float_32"][api_builtin_class.name],
                float_64_size = builtin_sizes["float_64"][api_builtin_class.name],
                double_32_size = builtin_sizes["double_32"][api_builtin_class.name],
                double_64_size = builtin_sizes["double_64"][api_builtin_class.name],
                base_constructor_name = fmt.aprintf("new_%v", snake_name),
                constructors = make([]StateClassConstructor, len(api_builtin_class.constructors)),
                destructor_name = fmt.aprintf("free_%v", snake_name) if api_builtin_class.has_destructor else nil,
                members = make([]StateClassBuiltinMember, len(api_builtin_class.members)),
            },
        }

        state_type.derived = state_class

        // we don't wanna override the existing POD data type in all_types
        if !state_type.odin_skip {
            state.all_types[api_builtin_class.name] = state_type
        }
        state.builtin_classes[api_builtin_class_index] = state_type

        for api_enum, enum_index in api_builtin_class.enums {
            state_enum := _state_enum(state, api_enum, state_type)
            state_class.enums[enum_index] = state_enum
        }
    }

    // special builtin class Variant
    {
        state_type := new(StateType)
        state_type.odin_type = "Variant"
        state_type.derived = StateClass {
            odin_name = "Variant",
            api_type = "variant",
            is_builtin = true,
            builtin_info = StateClassBuiltin {
                float_32_size = builtin_sizes["float_32"]["Variant"],
                float_64_size = builtin_sizes["float_64"]["Variant"],
                double_32_size = builtin_sizes["double_32"]["Variant"],
                double_64_size = builtin_sizes["double_64"]["Variant"],
            },
        }

        state.all_types["Variant"] = state_type
        state.builtin_classes[len(state.builtin_classes) - 1] = state_type
    }

    // and Object
    {
        state_type := new(StateType)
        state_type.odin_type = "Object"
        // we skip this one since it is already covered by the manually written variant/Object.odin
        state_type.odin_skip = true
        state_type.derived = StateClass {
            odin_name = "Object",
            api_type = "variant",
            is_builtin = true,
            builtin_info = StateClassBuiltin {
                float_32_size = builtin_sizes["float_32"]["Object"],
                float_64_size = builtin_sizes["float_64"]["Object"],
                double_32_size = builtin_sizes["double_32"]["Object"],
                double_64_size = builtin_sizes["double_64"]["Object"],
            },
        }

        state.all_types["Object"] = state_type
        state.builtin_classes[len(state.builtin_classes) - 2] = state_type
    }

    // and Object pointer
    {
        state_type := new(StateType)
        state_type.odin_type = "^Object"
        // we skip this one since it is already covered by the manually written variant/Object.odin
        state_type.odin_skip = true
        state_type.derived = StateClass {
            odin_name = "^Object",
            api_type = "variant",
            is_builtin = true,
            builtin_info = StateClassBuiltin {
                float_32_size = builtin_sizes["float_32"]["Object"],
                float_64_size = builtin_sizes["float_64"]["Object"],
                double_32_size = builtin_sizes["double_32"]["Object"],
                double_64_size = builtin_sizes["double_64"]["Object"],
            },
        }

        state.all_types["Object*"] = state_type
        state.builtin_classes[len(state.builtin_classes) - 3] = state_type
    }

    // and Nil, which is only used for VariantType.Nil
    {
        state_type := new(StateType)
        state_type.odin_type = "Nil"
        state_type.odin_skip = true
        state_type.derived = StatePodType {
            odin_type = "",
        }

        state.all_types["Nil"] = state_type
    }

    // initial pass for engine classes, another one is made further down for things like methods
    for api_class, api_class_index in api.classes {
        odin_name := godot_to_odin_case(api_class.name)
        snake_name := godot_to_snake_case(api_class.name)
        state_type := new(StateType)
        state_type.odin_type = odin_name
        state_type.godot_type = api_class.name
        state_type.snake_type = snake_name
        // HACK: don't generate Object.gen.odin for now, we need to add support for bindgen'd Object
        //       but, for now, we rely on the premade variant/Object.odin
        state_type.odin_skip = odin_name == "Object"
        state_class := StateClass {
            odin_name = odin_name,
            api_type  = api_class.api_type,
            methods   = make([]StateFunction, len(api_class.methods)),
            constants = make([]StateConstant, len(api_class.constants)),
            enums     = make([]^StateType, len(api_class.enums)),
            operators = make([]StateOperator, len(api_class.operators)),
        }

        state_type.derived = state_class

        // HACK: since we already added a builtin Object type to all_types, we dont want to override here
        if odin_name != "Object" {
            state.all_types[api_class.name] = state_type
        }
        state.classes[api_class_index] = state_type

        for api_enum, enum_index in api_class.enums {
            state_enum := _state_enum(state, api_enum, state_type)
            state_class.enums[enum_index] = state_enum
        }
    }

    // adding all native struct types and their pointer equivalents to the all types map
    for api_native_struct, api_native_struct_index in api.native_structs {
        odin_name := godot_to_odin_case(api_native_struct.name)
        native_struct := StateNativeStructure {
            odin_name = odin_name,
            fields    = _native_struct_fields(state, api_native_struct.format),
        }

        for field in native_struct.fields {
            if field.default != "" {
                native_struct.has_defaults = true
                break
            }
        }

        {
            state_type := new(StateType)
            state_type.odin_type = odin_name
            state_type.snake_type = odin_to_snake_case(odin_name)
            state_type.derived = native_struct
            state.all_types[api_native_struct.name] = state_type
            state.native_structs[api_native_struct_index] = state_type
        }

        // pointer
        {
            godot_name := fmt.aprintf("%v*", api_native_struct.name)
            real_odin_type := fmt.aprintf("^%v", odin_name)
            state_type := new(StateType)
            state_type.odin_type = real_odin_type
            state_type.derived = native_struct
            state.all_types[godot_name] = state_type
        }

        // const pointer
        {
            godot_name := fmt.aprintf("const %v*", api_native_struct.name)
            real_odin_type := fmt.aprintf("^%v", odin_name)
            state_type := new(StateType)
            state_type.odin_type = real_odin_type
            state_type.derived = native_struct
            state.all_types[godot_name] = state_type
        }
    }

    for api_singleton, api_singleton_idx in api.singletons {
        state_class, singleton_is_state_class := state.all_types[api_singleton.type].derived.(StateClass)
        assert(singleton_is_state_class)

        state_singleton := StateSingleton {
            name       = api_singleton.name,
            snake_name = godot_to_snake_case(api_singleton.name),
            odin_type  = godot_to_odin_case(api_singleton.type),
        }

        if state_class.api_type == "core" {
            append(&state.core_singletons, state_singleton)
        } else {
            append(&state.editor_singletons, state_singleton)
        }
    }

    for api_function, i in api.util_functions {
        state_function := StateFunction {
            odin_name  = fmt.aprintf("gd_%v", api_function.name),
            godot_name = api_function.name,
            hash       = api_function.hash,
            arguments  = make([]StateFunctionArgument, len(api_function.arguments)),
        }

        if return_type_str, has_return_type := api_function.return_type.(string); has_return_type {
            state_function.return_type = state.all_types[api_function.return_type.(string)]
        }

        for api_arg, arg_index in api_function.arguments {
            // TODO: argument defaults
            state_function.arguments[arg_index] = StateFunctionArgument {
                name = api_arg.name,
                type = state.all_types[api_arg.type],
            }
        }

        state.utility_functions[i] = state_function
    }

    // second engine class pass
    for api_class in api.classes {
        if api_class.name == "Object" {
            continue
        }

        state_type := state.all_types[api_class.name]
        _, is_class := state_type.derived.(StateClass)
        if !is_class {
            continue
        }

        // TODO: have a base "Wrapped"-like object like in godot-cpp, so we can autogen Object too
        inherits := api_class.inherits.(string) or_else "Object"
        inherits_type := state.all_types[inherits]
        _, is_class = inherits_type.derived.(StateClass)
        assert(is_class)
        (&state_type.derived.(StateClass))^.inherits = inherits_type

        for api_constant, i in api_class.constants {
            constant_type: ^StateType = nil
            if api_constant.type != nil {
                constant_type = state.all_types[api_constant.type.(string)]
            }

            state_constant := StateConstant {
                name  = fmt.aprintf("%s_%s", odin_to_const_case(state_type.odin_type), api_constant.name),
                type  = constant_type,
                value = api_constant.value,
            }

            // we already have enums for the Axis constants
            if strings.has_prefix(state_type.odin_type, "Vector") && strings.has_prefix(api_constant.name, "AXIS") {
                state_constant.odin_skip = true
            }

            // extension_api.json for 4.2.1 uses an invalid constructor form for some reason,
            // I think its shorthand for 4 Vector3s though. For now im just going to pretend
            // it doesnt exist and deal with it later (:
            // TODO: deal with Transform, Projection, Basis constants
            if value_string, is_string := api_constant.value.(string);
               is_string &&
               (strings.has_prefix(value_string, "Transform3D(") ||
                       strings.has_prefix(value_string, "Transform2D(") ||
                       strings.has_prefix(value_string, "Projection(") ||
                       strings.has_prefix(value_string, "Basis(")) {

                state_constant.odin_skip = true
            }

            // TODO: properly parse out the value into a function call?
            if value_string, is_string := api_constant.value.(string);
               is_string && strings.contains_rune(value_string, '(') && strings.contains_rune(value_string, ')') {

                split_value := strings.split_n(value_string, "(", 2)
                constructor_type, ok := state.all_types[split_value[0]]
                assert(ok)

                value_string = fmt.aprintf(
                    "%v(%v",
                    constructor_type.derived.(StateClass).builtin_info.(StateClassBuiltin).base_constructor_name,
                    split_value[1],
                )
                // TODO: verify that inf is always passed as f64?
                state_constant.value, _ = strings.replace_all(value_string, "inf", "__bindgen_math.INF_F64")
                state_type.depends_on_core_math = true
            }
            state_type.derived.(StateClass).constants[i] = state_constant
        }

        // we process methods way at the end so that all dependent types have been mapped in all_types by this point
        for api_method, method_index in api_class.methods {
            class_method := StateFunction {
                odin_name  = _class_method_name(state_type.odin_type, api_method.name),
                godot_name = api_method.name,
                hash       = api_method.hash,

                // HACK: for some ungodly reason the gdextension duplicates the getter for origin as a builtin method? Resulting in a redelcaration of the get_origin proc.
                odin_skip  = state_type.odin_type == "Transform2d" && api_method.name == "get_origin",
                arguments  = make([]StateFunctionArgument, len(api_method.arguments)),
            }

            if return_value, has_return_value := api_method.return_value.(ApiClassMethodReturnValue);
               has_return_value {
                return_type := return_value.meta.(string) or_else return_value.type
                if strings.has_prefix(return_type, "typedarray::") {
                    return_type = "Array"
                }

                state_return_type, ok := state.all_types[return_type]
                assert(ok, return_type)

                class_method.return_type = state_return_type
            }

            for argument, arg_index in api_method.arguments {
                argument_type := argument.type
                if strings.has_prefix(argument_type, "typedarray::") {
                    argument_type = "Array"
                }

                state_arg_type, ok := state.all_types[argument_type]
                assert(ok, argument_type)
                method_argument := StateFunctionArgument {
                    name = argument.name,
                    type = state_arg_type,
                }

                // TODO: default args

                class_method.arguments[arg_index] = method_argument
            }

            state_type.derived.(StateClass).methods[method_index] = class_method
        }
    }

    // second builtin class pass
    for api_builtin_class in api.builtin_classes {
        state_type := state.all_types[api_builtin_class.name]
        _, is_class := state_type.derived.(StateClass)
        if !is_class {
            continue
        }

        for api_member, i in api_builtin_class.members {
            member_type := state.all_types[api_member.type]
            state_member := StateClassBuiltinMember {
                odin_prefix = odin_to_snake_case(state_type.odin_type),
                name        = api_member.name,
                type        = member_type,
            }
            state_type.derived.(StateClass).builtin_info.(StateClassBuiltin).members[i] = state_member
        }

        for api_constant, i in api_builtin_class.constants {
            constant_type := state.all_types[api_constant.type.(string)]
            state_constant := StateConstant {
                name  = fmt.aprintf("%v_%v", odin_to_const_case(state_type.odin_type), api_constant.name),
                type  = constant_type,
                value = api_constant.value,
            }

            // we already have enums for the Axis constants
            if strings.has_prefix(state_type.odin_type, "Vector") && strings.has_prefix(api_constant.name, "AXIS") {
                state_constant.odin_skip = true
            }

            // extension_api.json for 4.2.1 uses an invalid constructor form for some reason,
            // I think its shorthand for 4 Vector3s though. For now im just going to pretend
            // it doesnt exist and deal with it later (:
            // TODO: deal with Transform, Projection, Basis constants
            if value_string, is_string := api_constant.value.(string);
               is_string &&
               (strings.has_prefix(value_string, "Transform3D(") ||
                       strings.has_prefix(value_string, "Transform2D(") ||
                       strings.has_prefix(value_string, "Projection(") ||
                       strings.has_prefix(value_string, "Basis(")) {

                state_constant.odin_skip = true
            }

            // TODO: properly parse out the value into a function call?
            if value_string, is_string := api_constant.value.(string);
               is_string && strings.contains_rune(value_string, '(') && strings.contains_rune(value_string, ')') {

                split_value := strings.split_n(value_string, "(", 2)
                constructor_type, ok := state.all_types[split_value[0]]
                assert(ok)

                value_string = fmt.aprintf(
                    "%v(%v",
                    constructor_type.derived.(StateClass).builtin_info.(StateClassBuiltin).base_constructor_name,
                    split_value[1],
                )
                // TODO: verify that inf is always passed as f64?
                state_constant.value, _ = strings.replace_all(value_string, "inf", "__bindgen_math.INF_F64")
                state_type.depends_on_core_math = true
            }
            state_type.derived.(StateClass).constants[i] = state_constant
        }

        for api_constructor in api_builtin_class.constructors {
            state_constructor := StateClassConstructor {
                arguments = make([]StateFunctionArgument, len(api_constructor.arguments)),
            }

            for argument, arg_index in api_constructor.arguments {
                state_arg_type, ok := state.all_types[argument.type]
                assert(ok, argument.type)
                method_argument := StateFunctionArgument {
                    name = argument.name,
                    type = state_arg_type,
                }

                state_constructor.arguments[arg_index] = method_argument
            }

            state_constructor.odin_name = _class_constructor_name(
                state_type.derived.(StateClass).builtin_info.(StateClassBuiltin).base_constructor_name,
                state_constructor.arguments,
            )
            state_type.derived.(StateClass).builtin_info.(StateClassBuiltin).constructors[api_constructor.index] =
                state_constructor
        }

        operator_overloads := make(map[string][dynamic]ApiClassOperator)
        for api_operator in api_builtin_class.operators {
            operator_name, ok := operator_enum_map[api_operator.name]
            assert(ok)
            if operator_name not_in operator_overloads {
                operator_overloads[operator_name] = make([dynamic]ApiClassOperator)
            }
            append(&operator_overloads[operator_name], api_operator)
        }

        op_index := 0
        for variant_name, api_operators in operator_overloads {
            operator := StateOperator {
                odin_name    = _class_operator_name(state_type.odin_type, variant_name),
                variant_name = variant_name,
                overloads    = make([]StateOperatorOverload, len(api_operators)),
            }

            for api_operator, i in api_operators {
                // the right type in builtin class operators is used exclusively as a VariantType specifier when passed
                // to `variant_get_ptr_operator_evaluator`, which expects Nil if right_type is non-existant or if its
                // Variant
                right_type_str := api_operator.right_type.(string) or_else "Nil"
                if right_type_str == "Variant" {
                    right_type_str = "Nil"
                }
                right_type := state.all_types[right_type_str]
                return_type := state.all_types[api_operator.return_type]
                operator.overloads[i] = StateOperatorOverload {
                    odin_name   = _class_operator_overload_name(
                        state_type.odin_type,
                        variant_name,
                        right_type.odin_type,
                    ),
                    return_type = return_type,
                    right_type  = right_type,
                }
            }

            state_type.derived.(StateClass).operators[op_index] = operator
            op_index += 1
        }

        // we process methods way at the end so that all dependent types have been mapped in all_types by this point
        for api_method, method_index in api_builtin_class.methods {
            class_method := StateFunction {
                odin_name  = _class_method_name(state_type.odin_type, api_method.name),
                godot_name = api_method.name,
                hash       = api_method.hash,

                // HACK: for some ungodly reason the gdextension duplicates the getter for origin as a builtin method? Resulting in a redelcaration of the get_origin proc.
                odin_skip  = state_type.odin_type == "Transform2d" && api_method.name == "get_origin",
                arguments  = make([]StateFunctionArgument, len(api_method.arguments)),
            }

            if return_type, has_return_type := api_method.return_type.(string); has_return_type {
                state_return_type, ok := state.all_types[return_type]
                assert(ok, return_type)

                class_method.return_type = state_return_type
            }

            for argument, arg_index in api_method.arguments {
                state_arg_type, ok := state.all_types[argument.type]
                assert(ok, argument.type)
                method_argument := StateFunctionArgument {
                    name = argument.name,
                    type = state_arg_type,
                }

                // TODO: default args

                class_method.arguments[arg_index] = method_argument
            }

            state_type.derived.(StateClass).methods[method_index] = class_method
        }
    }

    return
}

/*
    Copyright 2023 Dresses Digital

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

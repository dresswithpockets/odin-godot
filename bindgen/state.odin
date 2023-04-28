package bindgen

import "core:fmt"
import "core:strings"

State :: struct {
    options:             Options,
    api:                 ^Api,

    // maps a godot type name to the package its in
    type_package_map:    map[string]string,
    // maps a godot type name to an odin type name
    type_odin_names:     map[string]string,
    // maps a godot type name to an odin type's snake case name
    type_snake_names:    map[string]string,
    size_configurations: map[string]StateSizeConfiguration,
    enums:               map[string]StateEnum,
    // maps a builtin godot type name to builtin class details
    builtin_classes:     map[string]StateBuiltinClass,
}

StateSizeConfiguration :: struct {
    name:  string,
    sizes: map[string]uint,
}

StateEnum :: struct {
    godot_name:  string,
    is_bitfield: bool,
    values:      map[string]int,
}

StateBuiltinClass :: struct {
    godot_name:          string,
    is_keyed:            bool,
    has_destructor:      bool,
    operators:           map[string]StateClassOperator,
    methods:             map[string]StateBuiltinClassMethod,
    constructors:        map[string]StateClassConstructor,
    depends_on_packages: map[string]bool,
}

StateClassOperator :: struct {
    // the actual operator, e.g '=='
    operator:        string,
    // the VariantOperator name, e.g Equal
    variant_op_name: string,
    // name of the odin function to generate to invoke this operator
    // e.g 'string_name_equal'
    proc_name:       string,
    overloads:       [dynamic]StateClassOperatorOverload,
}

StateClassOperatorOverload :: struct {
    // name of the odin function to generate to invoke this operator
    // e.g 'string_name_equal_string_name'
    proc_name:         string,
    backing_func_name: string,
    // nil for unary operators
    right_type:        Maybe(string),
    return_type:       string,
}

StateBuiltinClassMethod :: struct {
    backing_func_name: string,
    godot_name:        string,
    proc_name:         string,
    // nil for void-returning functions
    return_type:       Maybe(string),
    is_vararg:         bool,
    is_const:          bool,
    is_static:         bool,
    hash:              i64,
    arguments:         []StateFunctionArgument,
}

StateClassConstructor :: struct {
    index:     u64,
    arguments: []StateFunctionArgument,
}

StateFunctionArgument :: struct {
    name:          string,
    godot_type:    string,
    default_value: string,
}

@(private)
operator_name_map := map[string]string {
    // comparison
    "=="     = "equal",
    "!="     = "notequal",
    "<"      = "less",
    "<="     = "lessequal",
    ">"      = "greater",
    ">="     = "greaterequal",

    // maths
    "+"      = "add",
    "-"      = "sub",
    "*"      = "mul",
    "/"      = "div",
    "unary-" = "neg",
    "unary+" = "pos",
    "%"      = "mod",
    "**"     = "pow",

    // bits
    "<<"     = "bitleft",
    ">>"     = "bitright",
    "&"      = "bitand",
    "|"      = "bitor",
    "^"      = "bitxor",
    "~"      = "bitneg",

    // logic
    "and"    = "and",
    "or"     = "or",
    "xor"    = "xor",
    "not"    = "not",

    // containment
    "in"     = "int",
}

@(private)
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

create_state :: proc(options: Options, api: ^Api) -> (state: ^State) {
    state = new(State)
    state.options = options
    state.api = api

    _state_size_configurations(state)
    _state_global_enums(state)
    _state_builtin_classes(state)
    _state_builtin_class_members(state)

    return
}

@(private)
_state_size_configurations :: proc(state: ^State) {
    state.size_configurations = make(map[string]StateSizeConfiguration)

    for builtin_config in state.api.builtin_sizes {
        configuration := StateSizeConfiguration {
            name  = builtin_config.configuration,
            sizes = make(map[string]uint),
        }
        for size in builtin_config.sizes {
            configuration.sizes[size.name] = size.size
        }
        state.size_configurations[builtin_config.configuration] = configuration
    }
}

@(private)
_state_global_enums :: proc(state: ^State) {
    state.enums = make(map[string]StateEnum)

    for api_enum in state.api.enums {
        state_enum := StateEnum {
            godot_name  = api_enum.name,
            is_bitfield = api_enum.is_bitfield,
            values      = make(map[string]int),
        }

        for value in api_enum.values {
            state_enum.values[value.name] = value.value
        }

        state.enums[api_enum.name] = state_enum
        state.type_package_map[api_enum.name] = "core"
        state.type_odin_names[api_enum.name] = godot_to_odin_case(api_enum.name)
        state.type_snake_names[api_enum.name] = godot_to_snake_case(api_enum.name)
    }
}

@(private)
_state_builtin_classes :: proc(state: ^State) {
    state.builtin_classes = make(map[string]StateBuiltinClass)

    // cache info about classes first for lookup later
    for class in &state.api.builtin_classes {
        state.builtin_classes[class.name] = StateBuiltinClass {
            godot_name     = class.name,
            is_keyed       = class.is_keyed,
            has_destructor = class.has_destructor,
        }
        state.type_package_map[class.name] = "variant"
        state.type_odin_names[class.name] = godot_to_odin_case(class.name)
        state.type_snake_names[class.name] = godot_to_snake_case(class.name)
    }
}

@(private)
_state_builtin_class_members :: proc(state: ^State) {
    for class in &state.api.builtin_classes {
        state_class := &state.builtin_classes[class.name]
        _state_builtin_class_operators(state, state_class, &class)
        state_class.methods = _state_builtin_class_methods(state, &class)
        state_class.constructors = _state_builtin_class_constructors(state, &class)
    }
}

// formats the name for a builtin class method's backing func ptr
// format is like __ClassName__method_name__ArgType1_ArgType2
@(private)
_builtin_backing_func_name :: proc(class: ^ApiBuiltinClass, method: ^ApiBuiltinClassMethod) -> (name: string) {
    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    fmt.sbprintf(&sb, "__%v__%v", class.name, method.hash)
    if len(method.arguments) > 0 {
        fmt.sbprint(&sb, "_")
    }
    for arg in method.arguments {
        fmt.sbprintf(&sb, "_%v", arg.type)
    }

    name = strings.clone(strings.to_string(sb))
    return
}

// formats the name for a class operator's public proc group
// format is like class_name_op_name, used for proc overloading
@(private)
_class_operator_proc_name :: proc(
    state: ^State,
    class: ^ApiBuiltinClass,
    operator: ^ApiClassOperator,
) -> (
    name: string,
) {
    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    class_snake_name := _get_correct_class_snake_name(state, class.name)
    op_name := operator_name_map[operator.name]
    fmt.sbprintf(&sb, "%v_%v", class_snake_name, op_name)

    name = strings.clone(strings.to_string(sb))
    return
}

// formats the name for a class operator's public proc overload
// format is like class_name_op_name_other_type
@(private)
_class_operator_overload_proc_name :: proc(
    state: ^State,
    class: ^ApiBuiltinClass,
    operator: ^ApiClassOperator,
) -> (
    name: string,
) {
    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    class_snake_name := _get_correct_class_snake_name(state, class.name)
    op_name := operator_name_map[operator.name]
    if operator.right_type == nil {
        fmt.sbprintf(&sb, "%v_%v_default", class_snake_name, op_name)
    } else {
        right_type_snake_name := _get_correct_class_snake_name(state, operator.right_type.(string))
        fmt.sbprintf(&sb, "%v_%v_%v", class_snake_name, op_name, right_type_snake_name)
    }

    name = strings.clone(strings.to_string(sb))
    return
}

// formats the name for a class operator's backing func ptr
// format is like __ClassName__OpName__RightType
@(private)
_class_operator_backing_func_name :: proc(
    state: ^State,
    class: ^ApiBuiltinClass,
    operator: ^ApiClassOperator,
) -> (
    name: string,
) {
    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    class_name := _get_correct_class_odin_name(state, class.name)
    op_name := operator_enum_map[operator.name]
    if operator.right_type == nil {
        fmt.sbprintf(&sb, "__%v__%v__Nil", class_name, op_name)
    } else {
        right_type_name := _get_correct_class_odin_name(state, operator.right_type.(string))
        fmt.sbprintf(&sb, "__%v__%v__%v", class_name, right_type_name)
    }

    name = strings.clone(strings.to_string(sb))
    return
}

@(private)
_state_builtin_class_operators :: proc(state: ^State, class: ^StateBuiltinClass, api_class: ^ApiBuiltinClass) {
    class.operators = make(map[string]StateClassOperator)

    for operator in &api_class.operators {
        group, ok := &class.operators[operator.name]
        if !ok {
            class.operators[operator.name] = StateClassOperator {
                operator        = operator.name,
                overloads       = make([dynamic]StateClassOperatorOverload),
                proc_name       = _class_operator_proc_name(state, api_class, &operator),
                variant_op_name = operator_enum_map[operator.name],
            }
            group = &class.operators[operator.name]
        }

        append(
            &group.overloads,
            StateClassOperatorOverload{
                backing_func_name = _class_operator_backing_func_name(state, api_class, &operator),
                proc_name = _class_operator_overload_proc_name(state, api_class, &operator),
                return_type = operator.return_type,
                right_type = operator.right_type,
            },
        )

        if right_type, not_nil := operator.right_type.(string); not_nil {
            if right_type_package, in_map := state.type_package_map[right_type]; in_map {
                class.depends_on_packages[right_type_package] = true
            }
        }
    }
    return
}

@(private)
_state_builtin_class_methods :: proc(
    state: ^State,
    api_class: ^ApiBuiltinClass,
) -> (
    cons: map[string]StateBuiltinClassMethod,
) {
    cons = make(map[string]StateBuiltinClassMethod)
    for method in api_class.methods {
        cons[method.name] = StateBuiltinClassMethod{}
        // TODO:
    }
    return
}

@(private)
_state_builtin_class_constructors :: proc(
    state: ^State,
    class: ^ApiBuiltinClass,
) -> (
    cons: map[string]StateClassConstructor,
) {
    cons = make(map[string]StateClassConstructor)
    for _ in class.constructors {
        // TODO:
    }
    return
}

@(private)
_get_correct_class_odin_name :: proc(state: ^State, name: string) -> string {
    if n, ok := state.type_odin_names[name]; !ok {
        return n
    }

    return name
}

@(private)
_get_correct_class_snake_name :: proc(state: ^State, name: string) -> string {
    if n, ok := state.type_snake_names[name]; !ok {
        return n
    }

    return name
}

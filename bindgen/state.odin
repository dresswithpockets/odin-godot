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
    utility_functions:   map[string]StateUtilityFunction,
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

StateUtilityFunction :: struct {
    backing_proc_name: string,
    godot_name: string,
    proc_name: string,
    odin_return_type: string,
    snake_return_type: string,
    godot_return_type: string,
    category: string,
    is_vararg: bool,
    hash: i64,
    arguments: []StateFunctionArgument,
}

StateBuiltinClass :: struct {
    odin_name: string,
    snake_name: string,
    godot_name:          string,
    is_keyed:            bool,
    has_destructor:      bool,
    operators:           map[string]StateClassOperator,
    methods:             map[string]StateBuiltinClassMethod,
    base_constructor_name: string,
    constructors:        []StateClassConstructor,
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
    odin_right_type:   Maybe(string),
    snake_right_type:  Maybe(string),
    godot_right_type:        Maybe(string),
    odin_return_type: string,
    snake_return_type: string,
    godot_return_type:       string,
}

StateBuiltinClassMethod :: struct {
    backing_func_name: string,
    godot_name:        string,
    proc_name:         string,
    // return types are nil for void-returning functions
    odin_return_type:        Maybe(string),
    snake_return_type: Maybe(string),
    godot_return_type:       Maybe(string),
    is_vararg:         bool,
    is_const:          bool,
    is_static:         bool,
    hash:              i64,
    arguments:         []StateFunctionArgument,
}

StateClassConstructor :: struct {
    index:     u64,
    backing_proc_name: string,
    proc_name: string,
    arguments: []StateFunctionArgument,
}

StateFunctionArgument :: struct {
    name:          string,
    odin_type:     string,
    snake_type:    string,
    godot_type:    string,
    default_value: Maybe(string),
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
    // TODO: classes

    _state_utility_functions(state)
    _state_builtin_class_members(state)
    // TODO: class members

    // TODO: singletons
    // TODO: native structures

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
_state_utility_functions :: proc(state: ^State) {
    state.utility_functions = make(map[string]StateUtilityFunction)

    for function in &state.api.util_functions {
        state_function := StateUtilityFunction{
            backing_proc_name = _utility_function_backing_proc_name(state, &function),
            proc_name = _utility_function_proc_name(state, &function),
            godot_name = function.name,
            odin_return_type = _get_correct_class_odin_name(state, function.return_type),
            snake_return_type = _get_correct_class_snake_name(state, function.return_type),
            godot_return_type = function.return_type,
            category = function.category,
            is_vararg = function.is_vararg,
            hash = function.hash,
            arguments = make([]StateFunctionArgument, len(function.arguments)),
        }
        for arg, i in function.arguments {
            state_function.arguments[i] = StateFunctionArgument {
                name = arg.name,
                odin_type = _get_correct_class_odin_name(state, arg.name),
                snake_type = _get_correct_class_snake_name(state, arg.name),
                godot_type = arg.type,
                default_value = arg.default_value,
            }
        }
        state.utility_functions[function.name] = state_function
    }
}

@(private)
_utility_function_backing_proc_name :: proc(state: ^State, function: ^ApiUtilityFunction) -> (name: string) {
    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    fmt.sbprintf(&sb, "__%v__%v", function.name, function.hash)

    name = strings.clone(strings.to_string(sb))
    return
}

@(private)
_utility_function_proc_name :: proc(state: ^State, function: ^ApiUtilityFunction) -> (name: string) {
    name = function.name
    return
}

@(private)
_state_builtin_classes :: proc(state: ^State) {
    state.builtin_classes = make(map[string]StateBuiltinClass)

    // cache info about classes first for lookup later
    for class in &state.api.builtin_classes {
        odin_name := godot_to_odin_case(class.name)
        snake_name := godot_to_snake_case(class.name)
        state.builtin_classes[class.name] = StateBuiltinClass {
            odin_name = odin_name,
            snake_name = snake_name,
            godot_name     = class.name,
            is_keyed       = class.is_keyed,
            has_destructor = class.has_destructor,
            base_constructor_name = _builtin_class_constructor_base_proc_name(state, snake_name),
        }
        state.type_package_map[class.name] = "variant"
        state.type_odin_names[class.name] = odin_name
        state.type_snake_names[class.name] = snake_name
    }
}

@(private)
_state_builtin_class_members :: proc(state: ^State) {
    for class in &state.api.builtin_classes {
        state_class := &state.builtin_classes[class.name]
        _state_builtin_class_operators(state, state_class, &class)
        _state_builtin_class_constructors(state, state_class, &class)
        state_class.methods = _state_builtin_class_methods(state, &class)
    }
}

// formats the name for a builtin class method's backing func ptr
// format is like __ClassName__METHODHASH
@(private)
_builtin_class_method_backing_func_name :: proc(
    state: ^State,
    class: ^ApiBuiltinClass,
    method: ^ApiBuiltinClassMethod,
) -> (
    name: string,
) {
    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    class_name := _get_correct_class_odin_name(state, class.name)
    fmt.sbprintf(&sb, "__%v__%v__%v", class_name, method.name, method.hash)

    name = strings.clone(strings.to_string(sb))
    return
}

@(private)
_builtin_class_method_proc_name :: proc(
    state: ^State,
    class: ^ApiBuiltinClass,
    method: ^ApiBuiltinClassMethod,
) -> (
    name: string,
) {
    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    class_snake_name := _get_correct_class_snake_name(state, class.name)
    fmt.sbprintf(&sb, "%v_%v", class_snake_name, method.name)

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
    if right_type, has_right_type := operator.right_type.(string); has_right_type {
        right_type_snake_name := _get_correct_class_snake_name(state, right_type)
        fmt.sbprintf(&sb, "%v_%v_%v", class_snake_name, op_name, right_type_snake_name)
    } else {
        if operator.name == "%" {
            op_name = "format"
        }
        fmt.sbprintf(&sb, "%v_%v_default", class_snake_name, op_name)
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
        fmt.sbprintf(&sb, "__%v__%v__%v", class_name, op_name, right_type_name)
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

        overload := StateClassOperatorOverload{
            backing_func_name = _class_operator_backing_func_name(state, api_class, &operator),
            proc_name = _class_operator_overload_proc_name(state, api_class, &operator),
            odin_return_type = _get_correct_class_odin_name(state, operator.return_type),
            snake_return_type = _get_correct_class_snake_name(state, operator.return_type),
            godot_return_type = operator.return_type,
        }
        if right_type, has_right_type := operator.right_type.(string); has_right_type {
            overload.odin_right_type = _get_correct_class_odin_name(state, right_type)
            overload.snake_right_type = _get_correct_class_snake_name(state, right_type)
            overload.godot_right_type = right_type
        }

        append(&group.overloads, overload)

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
    for method in &api_class.methods {
        state_method := StateBuiltinClassMethod {
            godot_name        = method.name,
            backing_func_name = _builtin_class_method_backing_func_name(state, api_class, &method),
            proc_name         = _builtin_class_method_proc_name(state, api_class, &method),
            is_const          = method.is_const,
            is_static         = method.is_static,
            is_vararg         = method.is_vararg,
            hash              = method.hash,
            arguments         = make([]StateFunctionArgument, len(method.arguments)),
        }
        for arg, i in method.arguments {
            state_method.arguments[i] = StateFunctionArgument {
                name = arg.name,
                odin_type = _get_correct_class_odin_name(state, arg.type),
                snake_type = _get_correct_class_snake_name(state, arg.type),
                godot_type = arg.type,
                default_value = arg.default_value,
            }
        }
        if return_type, has_return_type := method.return_type.(string); has_return_type {
            state_method.odin_return_type = _get_correct_class_odin_name(state, return_type)
            state_method.snake_return_type = _get_correct_class_snake_name(state, return_type)
            state_method.godot_return_type = return_type
        }
        cons[method.name] = state_method
    }
    return
}

@(private)
_state_builtin_class_constructors :: proc(state: ^State, class: ^StateBuiltinClass, api_class: ^ApiBuiltinClass) {
    class.constructors = make([]StateClassConstructor, len(api_class.constructors))
    for constructor in &api_class.constructors {
        state_constructor := StateClassConstructor {
            index     = constructor.index,
            backing_proc_name = _builtin_class_constructor_backing_proc_name(state, class, &constructor)
            proc_name = _builtin_class_constructor_proc_name(state, class, &constructor)
            arguments = make([]StateFunctionArgument, len(constructor.arguments)),
        }

        for arg, i in constructor.arguments {
            state_constructor.arguments[i] = StateFunctionArgument {
                odin_type = _get_correct_class_odin_name(state, arg.type),
                snake_type = _get_correct_class_snake_name(state, arg.type),
                godot_type    = arg.type,
                name          = arg.name,
                default_value = arg.default_value,
            }
        }

        class.constructors[constructor.index] = state_constructor
    }
}

@(private)
_builtin_class_constructor_backing_proc_name :: proc(state: ^State, class: ^StateBuiltinClass, constructor: ^ApiClassConstructor) -> (name: string) {
    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)
    
    fmt.sbprintf(&sb, "__%v__constructor_%v", class.godot_name, constructor.index)

    name = strings.clone(strings.to_string(sb))
    return
}

@(private)
_builtin_class_constructor_base_proc_name :: proc(state: ^State, class_snake_name: string) -> (name: string) {
    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)
    
    fmt.sbprintf(&sb, "new_%v", class_snake_name)
    name = strings.clone(strings.to_string(sb))
    return
}

@(private)
_builtin_class_constructor_proc_name :: proc(state: ^State, class: ^StateBuiltinClass, constructor: ^ApiClassConstructor) -> (name: string) {
    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)
    
    fmt.sbprint(&sb, class.base_constructor_name)
    if len(constructor.arguments) == 0 {
        fmt.sbprint(&sb, "_default")
        name = strings.clone(strings.to_string(sb))
        return
    }

    for arg in constructor.arguments {
        snake_type := _get_correct_class_snake_name(state, arg.type)
        fmt.sbprintf(&sb, "_%v", snake_type)
    }

    name = strings.clone(strings.to_string(sb))
    return
}

@(private)
_get_correct_class_odin_name :: proc(state: ^State, name: string) -> string {
    if n, ok := state.type_odin_names[name]; ok {
        return n
    }

    return name
}

@(private)
_get_correct_class_snake_name :: proc(state: ^State, name: string) -> string {
    if n, ok := state.type_snake_names[name]; ok {
        return n
    }

    return name
}

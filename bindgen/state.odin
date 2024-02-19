//+private file
package bindgen

import "core:fmt"
import "core:strings"

@(private)
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
    size_configurations_ordered: [dynamic]StateSizeConfiguration,
    enums:               map[string]StateEnum,
    utility_functions:   []StateUtilityFunction,
    // maps a builtin godot type name to builtin class details
    builtin_classes:     map[string]StateBuiltinClass,
}

@(private)
StateType :: struct {
    // prio_type is pod_type if not nil, odin_type otherwise
    prio_type:  string,
    pod_type:   Maybe(string),
    odin_type:  string,
    snake_type: string,
    godot_type: string,
}

@(private)
StateSizeConfiguration :: struct {
    name:  string,
    sizes: map[string]uint,
}

@(private)
StateEnum :: struct {
    godot_name:  string,
    is_bitfield: bool,
    values:      map[string]int,

    // processed data used in the temple template
    odin_skip:      bool,
    odin_case_name: string,
    odin_values:    map[string]int,
}

@(private)
StateUtilityFunction :: struct {
    backing_proc_name: string,
    godot_name:        string,
    proc_name:         string,
    return_type:       Maybe(StateType),
    return_type_str:   Maybe(string),
    category:          string,
    is_vararg:         bool,
    hash:              i64,
    arguments:         []StateFunctionArgument,
}

@(private)
StateBuiltinClass :: struct {
    odin_name:             string,
    snake_name:            string,
    godot_name:            string,
    is_keyed:              bool,
    has_destructor:        bool,
    operators:             map[string]StateClassOperator,
    methods:               map[string]StateBuiltinClassMethod,
    base_constructor_name: string,
    constructors:          []StateClassConstructor,
    depends_on_packages:   map[string]bool,

    odin_needs_strings: bool,
    is_special_string_type: bool,
}

@(private)
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

@(private)
StateClassOperatorOverload :: struct {
    // name of the odin function to generate to invoke this operator
    // e.g 'string_name_equal_string_name'
    proc_name:          string,
    backing_func_name:  string,
    // nil for unary operators
    right_type:         Maybe(StateType),
    return_type:        StateType,

    right_variant_type_name: string,
    right_type_str:          string,
    right_type_is_native:    bool,
    right_type_is_ref:       bool,
    right_type_ptr_str:      string,
}

@(private)
StateBuiltinClassMethod :: struct {
    backing_func_name:  string,
    godot_name:         string,
    proc_name:          string,
    // return types are nil for void-returning functions
    return_type:        Maybe(StateType),
    return_type_str:    Maybe(string),
    is_vararg:          bool,
    is_const:           bool,
    is_static:          bool,
    hash:               i64,
    arguments:          []StateFunctionArgument,
}

@(private)
StateClassConstructor :: struct {
    index:             u64,
    backing_proc_name: string,
    proc_name:         string,
    arguments:         []StateFunctionArgument,
}

@(private)
StateFunctionArgument :: struct {
    name:          string,
    arg_type:      StateType,
    arg_type_str:  string,
    default_value: Maybe(string),
}

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
    "in"     = "in",
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

@(private)
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

_state_size_configurations :: proc(state: ^State) {
    state.size_configurations = make(map[string]StateSizeConfiguration)
    state.size_configurations_ordered = make([dynamic]StateSizeConfiguration)

    for builtin_config in state.api.builtin_sizes {
        configuration := StateSizeConfiguration {
            name  = builtin_config.configuration,
            sizes = make(map[string]uint),
        }
        for size in builtin_config.sizes {
            configuration.sizes[size.name] = size.size
        }
        state.size_configurations[builtin_config.configuration] = configuration
        append(&state.size_configurations_ordered, configuration)
    }
}

_state_global_enums :: proc(state: ^State) {
    state.enums = make(map[string]StateEnum)

    for api_enum in state.api.enums {
        state_enum := StateEnum {
            godot_name  = api_enum.name,
            is_bitfield = api_enum.is_bitfield,
            values      = make(map[string]int),
            odin_values = make(map[string]int),
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

_state_utility_functions :: proc(state: ^State) {
    state.utility_functions = make([]StateUtilityFunction, len(state.api.util_functions))

    for &function, function_index in &state.api.util_functions {
        state_function := StateUtilityFunction {
            backing_proc_name  = _utility_function_backing_proc_name(state, &function),
            proc_name          = _utility_function_proc_name(state, &function),
            godot_name         = function.name,
            category           = function.category,
            is_vararg          = function.is_vararg,
            hash               = function.hash,
            arguments          = make([]StateFunctionArgument, len(function.arguments)),
        }

        if return_type, ok := function.return_type.(string); ok {
            state_function.return_type = _get_correct_state_type(state, return_type)
        }

        for arg, i in function.arguments {
            odin_type: string
            is_pod_type := false
            if odin_type, is_pod_type = pod_type_map[arg.type]; !is_pod_type {
                odin_type = _get_correct_class_odin_name(state, arg.type)
            }
            state_function.arguments[i] = StateFunctionArgument {
                name          = arg.name,
                arg_type      = _get_correct_state_type(state, arg.type),
                default_value = arg.default_value,
            }
        }
        state.utility_functions[function_index] = state_function
    }
}

_utility_function_backing_proc_name :: proc(state: ^State, function: ^ApiUtilityFunction) -> (name: string) {
    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    fmt.sbprintf(&sb, "__%v__%v", function.name, function.hash)

    name = strings.clone(strings.to_string(sb))
    return
}

_utility_function_proc_name :: proc(state: ^State, function: ^ApiUtilityFunction) -> (name: string) {
    name = function.name
    return
}

_state_builtin_classes :: proc(state: ^State) {
    state.builtin_classes = make(map[string]StateBuiltinClass)

    // cache info about classes first for lookup later
    for class in &state.api.builtin_classes {
        odin_name := godot_to_odin_case(class.name)
        snake_name := godot_to_snake_case(class.name)
        state.builtin_classes[class.name] = StateBuiltinClass {
            odin_name             = odin_name,
            snake_name            = snake_name,
            godot_name            = class.name,
            is_keyed              = class.is_keyed,
            has_destructor        = class.has_destructor,
            base_constructor_name = _builtin_class_constructor_base_proc_name(state, snake_name),
        }
        state.type_package_map[class.name] = "variant"
        state.type_odin_names[class.name] = odin_name
        state.type_snake_names[class.name] = snake_name
    }
}

_state_builtin_class_members :: proc(state: ^State) {
    for &class in &state.api.builtin_classes {
        state_class := &state.builtin_classes[class.name]
        _state_builtin_class_operators(state, state_class, &class)
        _state_builtin_class_constructors(state, state_class, &class)
        state_class.methods = _state_builtin_class_methods(state, &class)
    }
}

// formats the name for a builtin class method's backing func ptr
// format is like __ClassName__METHODHASH

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

_state_builtin_class_operators :: proc(state: ^State, class: ^StateBuiltinClass, api_class: ^ApiBuiltinClass) {
    class.operators = make(map[string]StateClassOperator)

    for &operator in &api_class.operators {
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

        overload := StateClassOperatorOverload {
            backing_func_name  = _class_operator_backing_func_name(state, api_class, &operator),
            proc_name          = _class_operator_overload_proc_name(state, api_class, &operator),
            return_type = _get_correct_state_type(state, operator.return_type),
        }

        if right_type, has_right_type := operator.right_type.(string); has_right_type {
            overload.right_type = _get_correct_state_type(state, right_type)
        }

        append(&group.overloads, overload)

        // ensures that the package this type depends on gets imported
        if right_type, not_nil := operator.right_type.(string); not_nil {
            if right_type_package, in_map := state.type_package_map[right_type]; in_map {
                class.depends_on_packages[right_type_package] = true
            }
        }
    }
    return
}

_state_builtin_class_methods :: proc(
    state: ^State,
    api_class: ^ApiBuiltinClass,
) -> (
    cons: map[string]StateBuiltinClassMethod,
) {
    cons = make(map[string]StateBuiltinClassMethod)
    for &method in &api_class.methods {
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
                name          = arg.name,
                arg_type      = _get_correct_state_type(state, arg.type),
                default_value = arg.default_value,
            }
        }
        if return_type, has_return_type := method.return_type.(string); has_return_type {
            state_method.return_type = _get_correct_state_type(state, return_type)
        }
        cons[method.name] = state_method
    }
    return
}

_state_builtin_class_constructors :: proc(state: ^State, class: ^StateBuiltinClass, api_class: ^ApiBuiltinClass) {
    class.constructors = make([]StateClassConstructor, len(api_class.constructors))
    for &constructor in &api_class.constructors {
        state_constructor := StateClassConstructor {
            index             = constructor.index,
            backing_proc_name = _builtin_class_constructor_backing_proc_name(state, class, &constructor),
            proc_name         = _builtin_class_constructor_proc_name(state, class, &constructor),
            arguments         = make([]StateFunctionArgument, len(constructor.arguments)),
        }

        for arg, i in constructor.arguments {
            state_constructor.arguments[i] = StateFunctionArgument {
                arg_type      = _get_correct_state_type(state, arg.type),
                name          = arg.name,
                default_value = arg.default_value,
            }
        }

        class.constructors[constructor.index] = state_constructor
    }
}

_builtin_class_constructor_backing_proc_name :: proc(
    state: ^State,
    class: ^StateBuiltinClass,
    constructor: ^ApiClassConstructor,
) -> (
    name: string,
) {
    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    fmt.sbprintf(&sb, "__%v__constructor_%v", class.godot_name, constructor.index)

    name = strings.clone(strings.to_string(sb))
    return
}

_builtin_class_constructor_base_proc_name :: proc(state: ^State, class_snake_name: string) -> (name: string) {
    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    fmt.sbprintf(&sb, "new_%v", class_snake_name)
    name = strings.clone(strings.to_string(sb))
    return
}

_builtin_class_constructor_proc_name :: proc(
    state: ^State,
    class: ^StateBuiltinClass,
    constructor: ^ApiClassConstructor,
) -> (
    name: string,
) {
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

_get_correct_state_type :: proc(state: ^State, godot_name: string) -> (state_type: StateType) {
    state_type.pod_type   = nil
    state_type.odin_type  = _get_correct_class_odin_name(state, godot_name)
    state_type.snake_type = _get_correct_class_snake_name(state, godot_name)
    state_type.godot_type = godot_name
    state_type.prio_type  = state_type.odin_type

    if pod_type, ok := pod_type_map[godot_name]; ok {
        state_type.pod_type = pod_type
        state_type.prio_type  = pod_type
    }

    return
}

_get_correct_class_odin_name :: proc(state: ^State, godot_name: string) -> (name: string) {
    name = godot_name

    if n, ok := state.type_odin_names[name]; ok {
        name = n
    }

    return
}

_get_correct_class_snake_name :: proc(state: ^State, godot_name: string) -> (name: string) {
    name = godot_name

    if n, ok := state.type_snake_names[name]; ok {
        name = n
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

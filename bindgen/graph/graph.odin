#+feature dynamic-literals
package graph

import "../names"
import "core:fmt"
import "core:mem"
import "core:strings"
import "core:text/scanner"

@(private = "file")
odin_primitives := [?]Primitive {
    // godot "meta" types
    Primitive{name = "int8", odin_name = "i8"},
    Primitive{name = "int16", odin_name = "i16"},
    Primitive{name = "int32", odin_name = "i32"},
    Primitive{name = "int64", odin_name = "i64"},
    Primitive{name = "char32", odin_name = "u32"},
    Primitive{name = "uint8", odin_name = "u8"},
    Primitive{name = "uint16", odin_name = "u16"},
    Primitive{name = "uint32", odin_name = "u32"},
    Primitive{name = "uint64", odin_name = "u64"},
    Primitive{name = "float", odin_name = "Float"},
    Primitive{name = "double", odin_name = "f64"},

    // c types
    Primitive{name = "void*", odin_name = "rawptr"},
    Primitive{name = "int8_t", odin_name = "i8"},
    // Primitive{name = "int8_t*", odin_name = "i8", pointer = 1},
    // Primitive{name = "int8_t **", odin_name = "i8", pointer = 2},
    Primitive{name = "int16_t", odin_name = "i16"},
    // Primitive{name = "int16_t*", odin_name = "i16", pointer = 1},
    // Primitive{name = "int16_t **", odin_name = "i16", pointer = 2},
    Primitive{name = "int32_t", odin_name = "i32"},
    // Primitive{name = "int32_t*", odin_name = "i32", pointer = 1},
    // Primitive{name = "int32_t **", odin_name = "i32", pointer = 2},
    Primitive{name = "int64_t", odin_name = "i64"},
    // Primitive{name = "int64_t*", odin_name = "i64", pointer = 1},
    // Primitive{name = "int64_t **", odin_name = "i64", pointer = 2},
    Primitive{name = "uint8_t", odin_name = "u8"},
    // Primitive{name = "uint8_t*", odin_name = "u8", pointer = 1},
    // Primitive{name = "uint8_t **", odin_name = "u8", pointer = 2},
    Primitive{name = "uint16_t", odin_name = "u16"},
    // Primitive{name = "uint16_t*", odin_name = "u16", pointer = 1},
    // Primitive{name = "uint16_t **", odin_name = "u16", pointer = 2},
    Primitive{name = "uint32_t", odin_name = "u32"},
    // Primitive{name = "uint32_t*", odin_name = "u32", pointer = 1},
    // Primitive{name = "uint32_t **", odin_name = "u32", pointer = 2},
    Primitive{name = "uint64_t", odin_name = "u64"},
    // Primitive{name = "uint64_t*", odin_name = "u64", pointer = 1},
    // Primitive{name = "uint64_t **", odin_name = "u64", pointer = 2},
    // Primitive{name = "float*", odin_name = "Float", pointer = 1},
    Primitive{name = "const void*", odin_name = "rawptr"},
    // Primitive{name = "const int8_t*", odin_name = "i8", pointer = 1},
    // Primitive{name = "const int8_t **", odin_name = "i8", pointer = 2},
    // Primitive{name = "const int16_t*", odin_name = "i16", pointer = 1},
    // Primitive{name = "const int16_t **", odin_name = "i16", pointer = 2},
    // Primitive{name = "const int32_t*", odin_name = "i32", pointer = 1},
    // Primitive{name = "const int32_t **", odin_name = "i32", pointer = 2},
    // Primitive{name = "const int64_t*", odin_name = "i64", pointer = 1},
    // Primitive{name = "const int64_t **", odin_name = "i64", pointer = 2},
    // Primitive{name = "const uint8_t*", odin_name = "u8", pointer = 1},
    // Primitive{name = "const uint8_t **", odin_name = "u8", pointer = 2},
    // Primitive{name = "const uint16_t*", odin_name = "u16", pointer = 1},
    // Primitive{name = "const uint16_t **", odin_name = "u16", pointer = 2},
    // Primitive{name = "const uint32_t*", odin_name = "u32", pointer = 1},
    // Primitive{name = "const uint32_t **", odin_name = "u32", pointer = 2},
    // Primitive{name = "const uint64_t*", odin_name = "u64", pointer = 1},
    // Primitive{name = "const uint64_t **", odin_name = "u64", pointer = 2},
    // Primitive{name = "const float*", odin_name = "Float", pointer = 1},
}

@(private = "file")
operator_name_map := map[string]names.Snake_Name {
    // comparison
    "=="     = "equal",
    "!="     = "not_equal",
    "<"      = "less",
    "<="     = "less_equal",
    ">"      = "greater",
    ">="     = "greater_equal",

    // maths
    "+"      = "add",
    "-"      = "subtract",
    "*"      = "multiply",
    "/"      = "divide",
    "unary-" = "negate",
    "unary+" = "positive",
    "%"      = "module",
    "**"     = "power",

    // bits
    "<<"     = "shift_left",
    ">>"     = "shift_right",
    "&"      = "Bit_and",
    "|"      = "bit_or",
    "^"      = "bit_xor",
    "~"      = "bit_negate",

    // logic
    "and"    = "and",
    "or"     = "or",
    "xor"    = "xor",
    "not"    = "not",

    // containment
    "in"     = "in",
}

Graph :: struct {
    allocator:       mem.Allocator,

    // caches
    types:           map[names.Godot_Name]Root_Type,
    configuration:   map[string]Configuration,

    // types
    builtin_classes: []Builtin_Class,
    engine_classes:  []Engine_Class,
    enums:           []Enum,
    bit_fields:      []Bit_Field,
    native_structs:  []Native_Struct,

    // non-types
    singletons:      []Singleton,
    util_procs:      []Util_Proc,
}

Configuration :: struct {
    class_sizes:    map[names.Godot_Name]uint,
    // maps type name to an inner map. The inner map maps member name to Member_Offset
    member_offsets: map[names.Godot_Name]map[string]Member_Offset,
}

Root_Type :: union #no_nil {
    ^Builtin_Class,
    ^Engine_Class,
    ^Enum,
    ^Bit_Field,
    ^Native_Struct,
    ^Primitive,
}

Any_Type :: union {
    ^Builtin_Class,
    ^Engine_Class,
    ^Class_Enum(Builtin_Class),
    ^Class_Bit_Field(Builtin_Class),
    ^Class_Enum(Engine_Class),
    ^Class_Bit_Field(Engine_Class),
    ^Enum,
    ^Bit_Field,
    ^Native_Struct,
    ^Primitive,
    ^Typed_Array,
    ^Pointer,
}

Pointable_Type :: union {
    ^Class_Enum(Builtin_Class),
    ^Class_Bit_Field(Builtin_Class),
    ^Class_Enum(Engine_Class),
    ^Class_Bit_Field(Engine_Class),
    ^Enum,
    ^Bit_Field,
    ^Native_Struct,
    ^Primitive,
}

Pointer :: struct {
    type:  Pointable_Type,
    depth: int,
}

Builtin_Class :: struct {
    name:            names.Godot_Name,
    destructor:      bool,
    index_returns:   Any_Type, // nil if no indexer
    keyed:           bool,
    constants:       []Constant,
    constructors:    []Constructor,
    enums:           []Class_Enum(Builtin_Class),
    bit_fields:      []Class_Bit_Field(Builtin_Class),
    members:         []Member,
    methods:         []Method,
    operators:       []Operator,
    layout_float32:  Layout,
    layout_float64:  Layout,
    layout_double32: Layout,
    layout_double64: Layout,
}

Layout :: struct {
    size:           uint,
    member_offsets: map[string]Member_Offset,
}

Member :: struct {
    name:    string,
    type:    Any_Type,
    offsets: map[string]Member_Offset,
}

Member_Offset :: struct {
    offset: uint,
    type:   Any_Type,
}

Constructor :: struct {
    index: u64,
    args:  []Constructor_Arg,
}

Constructor_Arg :: struct {
    name: string,
    type: Any_Type,
}

Engine_Api_Type :: enum {
    Core   = 0,
    Editor = 1,
}

Engine_Class :: struct {
    name:         names.Godot_Name,
    inherits:     Any_Type,
    instantiable: bool,
    api_type:     Engine_Api_Type,
    enums:        []Class_Enum(Engine_Class),
    bit_fields:   []Class_Bit_Field(Engine_Class),
    constants:    []Constant,
    methods:      []Method,
    signals:      []Signal,
    operators:    []Operator,
    properties:   []Property,
    // TODO: is_refcounted
}

Enum_Value :: struct {
    name:  names.Const_Name,
    value: string,
}

Class_Enum :: struct($C: typeid) where C == Builtin_Class || C == Engine_Class {
    class:  ^C,
    name:   names.Godot_Name,
    values: []Enum_Value,
}

Class_Bit_Field :: struct($C: typeid) where C == Builtin_Class || C == Engine_Class {
    class:  ^C,
    name:   names.Godot_Name,
    values: []Enum_Value,
}

Enum :: struct {
    name:   names.Godot_Name,
    values: []Enum_Value,
}

Bit_Field :: struct {
    name:   names.Godot_Name,
    values: []Enum_Value,
}

Native_Struct :: struct {
    name:    names.Godot_Name,
    fields:  []Struct_Field,
    pointer: int,
}

Struct_Field :: struct {
    name:    string,
    type:    Any_Type,
    default: Maybe(string),
}

Primitive :: struct {
    name:      string,
    odin_name: string,
    pointer:   int,
}

Typed_Array :: struct {
    element_type: Any_Type,
}

Constant :: struct {
    name:        names.Const_Name,
    type:        Any_Type,
    initializer: union #no_nil {
        string,
        Initialize_By_Constructor,
    },
}

Initialize_By_Constructor :: struct {
    type:       Any_Type,
    arg_values: []string,
}

Method :: struct {
    name:        string,
    vararg:      bool,
    static:      bool,
    virtual:     bool,
    hash:        i64,
    return_type: Any_Type, // will be nil if there is no return type
    args:        []Method_Arg,
}

Method_Arg :: struct {
    name:    string,
    type:    Any_Type,
    default: Maybe(string),
}

Signal :: struct {
    name: string,
    args: []Signal_Arg,
}

Signal_Arg :: struct {
    name: string,
    type: Any_Type,
}

Operator :: struct {
    name:        names.Snake_Name,
    // nil if unary operator
    right_type:  Any_Type,
    return_type: Any_Type,
}

Property :: struct {
    type:   Any_Type,
    name:   string,
    getter: string,
    setter: Maybe(string),
}

Singleton :: struct {
    name: names.Godot_Name,
    type: Any_Type,
}

Util_Proc :: struct {
    name:        string,
    return_type: Any_Type, // will be nil if there is no return type
    category:    string,
    vararg:      bool,
    hash:        i64,
    args:        []Method_Arg,
}

to_string :: proc(type: Engine_Api_Type) -> string {
    switch type {
    case .Core:
        return "core"
    case .Editor:
        return "editor"
    }

    panic("unexpected engine api type")
}

/*
Allocate a Graph based on an Api, using the provided allocator.

Other graph_* procs may allocate - when they do, they will use the provided allocator.

To free the initialized Graph & all its allocations, call free_all on the allocator you pass here.
*/
graph_init :: proc(graph: ^Graph, api: ^Api, allocator: mem.Allocator) {
    context.allocator = allocator

    enum_count := 0
    bitfield_count := 0
    for api_enum in api.enums {
        if api_enum.is_bitfield {
            bitfield_count += 1
        } else {
            enum_count += 1
        }
    }

    configuration := make(map[string]Configuration)
    configuration["float_32"] = Configuration {
        class_sizes    = make(map[names.Godot_Name]uint),
        member_offsets = make(map[names.Godot_Name]map[string]Member_Offset),
    }
    configuration["float_64"] = Configuration {
        class_sizes    = make(map[names.Godot_Name]uint),
        member_offsets = make(map[names.Godot_Name]map[string]Member_Offset),
    }
    configuration["double_32"] = Configuration {
        class_sizes    = make(map[names.Godot_Name]uint),
        member_offsets = make(map[names.Godot_Name]map[string]Member_Offset),
    }
    configuration["double_64"] = Configuration {
        class_sizes    = make(map[names.Godot_Name]uint),
        member_offsets = make(map[names.Godot_Name]map[string]Member_Offset),
    }

    graph^ = Graph {
        allocator       = allocator,
        types           = make(map[names.Godot_Name]Root_Type),
        configuration   = configuration,
        builtin_classes = make([]Builtin_Class, len(api.builtin_classes)),
        engine_classes  = make([]Engine_Class, len(api.classes)),
        enums           = make([]Enum, enum_count),
        bit_fields      = make([]Bit_Field, bitfield_count),
        native_structs  = make([]Native_Struct, len(api.native_structs)),
        singletons      = make([]Singleton, len(api.singletons)),
        util_procs      = make([]Util_Proc, len(api.util_functions)),
    }
}

@(private = "file")
_graph_class_enums :: proc(
    class: ^$C,
    enums: $E/[]Class_Enum(C),
    bit_fields: $B/[]Class_Bit_Field(C),
    api_enums: []ApiEnum,
) where C == Builtin_Class ||
    C == Engine_Class {
    enum_idx := 0
    bitfield_idx := 0
    for api_enum, idx in api_enums {
        if api_enum.is_bitfield {
            new_bit_field := Class_Bit_Field(C) {
                class  = class,
                name   = api_enum.name,
                values = make([]Enum_Value, len(api_enum.values)),
            }

            for api_value, value_idx in api_enum.values {
                new_bit_field.values[value_idx] = Enum_Value {
                    name  = api_value.name,
                    value = fmt.tprintf("%d", api_value.value),
                }
            }

            bit_fields[bitfield_idx] = new_bit_field
            bitfield_idx += 1
        } else {
            new_enum := Class_Enum(C) {
                class  = class,
                name   = api_enum.name,
                values = make([]Enum_Value, len(api_enum.values)),
            }

            for api_value, value_idx in api_enum.values {
                new_enum.values[value_idx] = Enum_Value {
                    name  = api_value.name,
                    value = fmt.tprintf("%d", api_value.value),
                }
            }

            enums[enum_idx] = new_enum
            enum_idx += 1
        }
    }
}

// initial pass over all types, copies over all data that doesn't depend on another type being present
graph_type_info_pass :: proc(graph: ^Graph, api: ^Api) {
    context.allocator = graph.allocator

    // variant isn't included in the api, but it always exists
    {
        variant := new_clone(Builtin_Class{name = "Variant", enums = make([]Class_Enum(Builtin_Class), 1)})

        variant.enums[0] = Class_Enum(Builtin_Class) {
            name  = "Type",
            class = variant,
        }

        graph.types["Variant"] = variant
    }

    for api_builtin_class, class_idx in api.builtin_classes {
        enum_count := 0
        bitfield_count := 0
        for api_enum in api_builtin_class.enums {
            if api_enum.is_bitfield {
                bitfield_count += 1
            } else {
                enum_count += 1
            }
        }

        graph.builtin_classes[class_idx] = Builtin_Class {
            name         = api_builtin_class.name,
            destructor   = api_builtin_class.has_destructor,
            keyed        = api_builtin_class.is_keyed,
            constants    = make([]Constant, len(api_builtin_class.constants)),
            constructors = make([]Constructor, len(api_builtin_class.constructors)),
            enums        = make([]Class_Enum(Builtin_Class), enum_count),
            bit_fields   = make([]Class_Bit_Field(Builtin_Class), bitfield_count),
            members      = make([]Member, len(api_builtin_class.members)),
            methods      = make([]Method, len(api_builtin_class.methods)),
            operators    = make([]Operator, len(api_builtin_class.operators)),
        }

        // N.B. class enums and class bit fields get resolved through their owning class, not through graph.types
        _graph_class_enums(
            &graph.builtin_classes[class_idx],
            graph.builtin_classes[class_idx].enums,
            graph.builtin_classes[class_idx].bit_fields,
            api_builtin_class.enums,
        )

        graph.types[api_builtin_class.name] = &graph.builtin_classes[class_idx]
    }

    for api_class, class_idx in api.classes {
        enum_count := 0
        bitfield_count := 0
        for api_enum in api_class.enums {
            if api_enum.is_bitfield {
                bitfield_count += 1
            } else {
                enum_count += 1
            }
        }

        engine_class := Engine_Class {
            name         = api_class.name,
            instantiable = api_class.is_instantiable,
            constants    = make([]Constant, len(api_class.constants)),
            enums        = make([]Class_Enum(Engine_Class), enum_count),
            bit_fields   = make([]Class_Bit_Field(Engine_Class), bitfield_count),
            methods      = make([]Method, len(api_class.methods)),
            operators    = make([]Operator, len(api_class.operators)),
            properties   = make([]Property, len(api_class.properties)),
            signals      = make([]Signal, len(api_class.signals)),
        }

        switch api_class.api_type {
        case "core":
            engine_class.api_type = .Core
        case "editor":
            engine_class.api_type = .Editor
        case:
            panic("unexpected api_type in class")
        }

        graph.engine_classes[class_idx] = engine_class

        _graph_class_enums(
            &graph.engine_classes[class_idx],
            graph.engine_classes[class_idx].enums,
            graph.engine_classes[class_idx].bit_fields,
            api_class.enums,
        )

        graph.types[api_class.name] = &graph.engine_classes[class_idx]
    }

    enum_idx := 0
    bitfield_idx := 0
    for api_enum in api.enums {
        if api_enum.is_bitfield {
            new_bit_field := Bit_Field {
                name   = api_enum.name,
                values = make([]Enum_Value, len(api_enum.values)),
            }

            for api_value, value_idx in api_enum.values {
                new_bit_field.values[value_idx] = Enum_Value {
                    name  = api_value.name,
                    value = fmt.tprintf("%d", api_value.value),
                }
            }

            graph.bit_fields[bitfield_idx] = new_bit_field
            graph.types[api_enum.name] = &graph.bit_fields[bitfield_idx]
            bitfield_idx += 1
        } else {
            new_enum := Enum {
                name   = api_enum.name,
                values = make([]Enum_Value, len(api_enum.values)),
            }

            for api_value, value_idx in api_enum.values {
                new_enum.values[value_idx] = Enum_Value {
                    name  = api_value.name,
                    value = fmt.tprintf("%d", api_value.value),
                }
            }

            graph.enums[enum_idx] = new_enum
            graph.types[api_enum.name] = &graph.enums[enum_idx]
            enum_idx += 1
        }
    }

    for api_struct, idx in api.native_structs {
        graph.native_structs[idx] = Native_Struct {
            name = api_struct.name,
        }

        graph.types[api_struct.name] = &graph.native_structs[idx]
    }

    for &primitive in odin_primitives {
        // primitive.name is never actually ever in Godot_Name case... but we never
        // render primitive.name so it doesn't matter if we lie here.
        graph.types[cast(names.Godot_Name)primitive.name] = &primitive
    }
}

graph_builtins_structure_pass :: proc(graph: ^Graph, api: ^Api) {
    context.allocator = graph.allocator

    for api_size_configuration in api.builtin_sizes {
        configuration, configuration_ok := &graph.configuration[api_size_configuration.configuration]
        assert(configuration_ok, api_size_configuration.configuration)

        for api_size in api_size_configuration.sizes {
            configuration.class_sizes[api_size.name] = api_size.size
        }
    }

    for api_member_offset in api.builtin_offsets {
        configuration, configuration_ok := &graph.configuration[api_member_offset.configuration]
        assert(configuration_ok, api_member_offset.configuration)

        for api_offset_class in api_member_offset.classes {
            class_offset_map := configuration.member_offsets[api_offset_class.name]
            for api_offset_member in api_offset_class.members {
                class_offset_map[api_offset_member.member] = Member_Offset {
                    offset = api_offset_member.offset,
                    type   = _graph_resolve_type(graph, api_offset_member.meta),
                }
            }
        }
    }
}

pointable_to_any :: proc(pointable_type: Pointable_Type) -> Any_Type {
    switch type in pointable_type {
        case ^Class_Enum(Builtin_Class):
            return type
        case ^Class_Bit_Field(Builtin_Class):
            return type
        case ^Class_Enum(Engine_Class):
            return type
        case ^Class_Bit_Field(Engine_Class):
            return type
        case ^Enum:
            return type
        case ^Bit_Field:
            return type
        case ^Native_Struct:
            return type
        case ^Primitive:
            return type
    }

    panic("Couldn't match pointable type to any type")
}

any_to_pointable :: proc(any_type: Any_Type) -> Pointable_Type {
    #partial switch type in any_type {
    case ^Class_Enum(Builtin_Class):
        return type
    case ^Class_Bit_Field(Builtin_Class):
        return type
    case ^Class_Enum(Engine_Class):
        return type
    case ^Class_Bit_Field(Engine_Class):
        return type
    case ^Enum:
        return type
    case ^Bit_Field:
        return type
    case ^Native_Struct:
        return type
    case ^Primitive:
        return type
    }

    panic("Couldn't match any type to pointable type")
}

@(private = "file")
_root_to_any :: proc(root_type: Root_Type) -> Any_Type {
    switch type in root_type {
    case ^Builtin_Class:
        return type
    case ^Engine_Class:
        return type
    case ^Enum:
        return type
    case ^Bit_Field:
        return type
    case ^Native_Struct:
        return type
    case ^Primitive:
        return type
    }

    panic("Couldn't match root type to any type")
}

@(private)
Type_Specifier :: union #no_nil {
    string,
    names.Godot_Name,
}

/*
Type strings can be in the following formats:
    TypeName
    enum::TypeName
    bitfield::TypeName
    enum::TypeName.TypeName
    bitfield::TypeName.TypeName
    typedarray::TypeName
    typedarray::VariantType/PropertyHint:TypeName
*/
@(private)
_graph_resolve_type :: proc(graph: ^Graph, type_specifier: Type_Specifier) -> Any_Type {
    godot_name, is_godot_name := type_specifier.(names.Godot_Name)

    if !is_godot_name {
        type_string := type_specifier.(string)

        // used later if we fall through the colon check
        godot_name = cast(names.Godot_Name)type_string

        colon_idx := strings.index(type_string, "::")
        if colon_idx > -1 {
            suffix := type_string[colon_idx + 2:]
            switch type_string[:colon_idx] {
            case "enum":
                {
                    dot_idx := strings.index_rune(suffix, '.')
                    if dot_idx > -1 {
                        class_type, class_type_ok := graph.types[cast(names.Godot_Name)suffix[:dot_idx]]
                        assert(
                            class_type_ok,
                            fmt.tprintfln(
                                "Couldn't find class_type in typestring '%v' (searched: '%v').",
                                suffix,
                                suffix[:dot_idx],
                            ),
                        )
                        child_type_string := cast(names.Godot_Name)suffix[dot_idx + 1:]

                        #partial switch class in class_type {
                        case ^Builtin_Class:
                            for &class_enum in class.enums {
                                if class_enum.name == child_type_string {
                                    return &class_enum
                                }
                            }
                            panic(
                                fmt.tprintfln(
                                    "Couldn't match '%v' in '%v' to a Class_Enum",
                                    child_type_string,
                                    type_string,
                                ),
                            )
                        case ^Engine_Class:
                            for &class_enum in class.enums {
                                if class_enum.name == child_type_string {
                                    return &class_enum
                                }
                            }
                            panic("Couldn't match TypeName in enum::ClassName.TypeName to a Class_Enum")
                        case:
                            panic(
                                "Expected ClassName in enum::ClassName.TypeName to be an Engine Class or Builtin Class",
                            )
                        }
                    }

                    if class_type, ok := graph.types[cast(names.Godot_Name)suffix]; ok {
                        if class_enum, enum_ok := class_type.(^Enum); enum_ok {
                            return class_enum
                        }

                        panic("Expected TypeName in bitfield::TypeName to be an Enum")
                    }

                    panic("Couldn't match TypeName in bitfield::TypeName to a type")
                }
            case "bitfield":
                {
                    dot_idx := strings.index_rune(suffix, '.')
                    if dot_idx > -1 {
                        class_type := graph.types[cast(names.Godot_Name)suffix[:dot_idx]]
                        child_type_string := cast(names.Godot_Name)suffix[dot_idx + 1:]

                        #partial switch class in class_type {
                        case ^Builtin_Class:
                            for &class_bit_field in class.bit_fields {
                                if class_bit_field.name == child_type_string {
                                    return &class_bit_field
                                }
                            }
                            panic("Couldn't match TypeName in bitfield::ClassName.TypeName to a Class_Bit_Field")
                        case ^Engine_Class:
                            for &class_bit_field in class.bit_fields {
                                if class_bit_field.name == child_type_string {
                                    return &class_bit_field
                                }
                            }
                            panic("Couldn't match TypeName in bitfield::ClassName.TypeName to a Class_Bit_Field")
                        case:
                            panic(
                                "Expected ClassName in bitfield::ClassName.TypeName to be an Engine Class or Builtin Class",
                            )
                        }
                    }

                    if class_type, ok := graph.types[cast(names.Godot_Name)suffix]; ok {
                        if class_bit_field, bit_field_ok := class_type.(^Bit_Field); bit_field_ok {
                            return class_bit_field
                        }

                        panic("Expected TypeName in bitfield::TypeName to be a Bit_Field")
                    }

                    panic("Couldn't match TypeName in bitfield::TypeName to a type")
                }
            case "typedarray":
                {
                    colon_idx = strings.last_index(suffix, ":")
                    if colon_idx > -1 {
                        // if there is ':' in the suffix, it means there is additional information padded into the hint
                        // string, conveying what type of elements the array contains. This can be used to indicate
                        // nested type arrays as well. Since we can't really use this information yet, we discard it
                        // and set suffix to always be "Array" for now.
                        // TODO: nested typed arrays
                        // TODO: property parsing hint string
                        suffix = "Array"
                    }

                    element_type, ok := graph.types[cast(names.Godot_Name)suffix]
                    assert(
                        ok,
                        fmt.tprintfln(
                            "Couldn't match typedarray::TypeName to type in graph.types: '%v', '%v'",
                            type_string,
                            suffix,
                        ),
                    )

                    typed_array := new(Typed_Array)
                    typed_array.element_type = _root_to_any(element_type)

                    return typed_array
                }
            case:
                panic("Unexpected type prefix before ::")
            }
        }
    }

    ptr_idx := strings.index_rune(cast(string)godot_name, '*')
    // void pointers are primitives since they map to rawptr, so we skip over them here
    if ptr_idx != -1 && !strings.contains(cast(string)godot_name, "void") {
        // its a pointer!
        ptr_count := len(godot_name) - ptr_idx
        type_string := strings.trim_right_space(cast(string)godot_name[:ptr_idx])
        if strings.has_prefix(type_string, "const") {
            type_string = type_string[6:]
        }

        type := any_to_pointable(_graph_resolve_type(graph, type_string))
        return new_clone(Pointer{type = type, depth = ptr_count})
    }

    switch type in graph.types[godot_name] {
    case ^Builtin_Class:
        return type
    case ^Engine_Class:
        return type
    case ^Enum:
        return type
    case ^Bit_Field:
        return type
    case ^Native_Struct:
        return type
    case ^Primitive:
        return type
    }

    panic("Couldn't resolve type in graph")
}

/*
Field type strings can be in the following formats:
    TypeName
    TypeName::TypeName
*/
@(private = "file")
_graph_struct_field_type :: proc(graph: ^Graph, type_string: string) -> Any_Type {
    panic("")
}

@(private = "file")
_graph_initializer_by_constructor :: proc(graph: ^Graph, call_string: string) -> Initialize_By_Constructor {
    lparen_idx := strings.index_rune(call_string, '(')
    rparen_idx := strings.index_rune(call_string, ')')
    type_string := call_string[:lparen_idx]
    call_string := call_string[lparen_idx + 1:rparen_idx]

    arg_count := strings.count(call_string, ",") + 1
    return Initialize_By_Constructor {
        type = _graph_resolve_type(graph, type_string),
        arg_values = strings.split(call_string, ", "),
    }
}

@(private = "file")
_graph_constant :: proc(graph: ^Graph, api_constant: ApiConstant) -> Constant {
    type_string := api_constant.type.(string) or_else "int64"
    value_string, ok := api_constant.value.(string)
    if !ok {
        value_string = fmt.tprintf("%d", api_constant.value)
    }

    constant := Constant {
        name        = api_constant.name,
        type        = _graph_resolve_type(graph, type_string),
        initializer = value_string,
    }

    if strings.contains_rune(value_string, '(') {
        constant.initializer = _graph_initializer_by_constructor(graph, value_string)
    }

    return constant
}

@(private = "file")
_graph_constructor :: proc(graph: ^Graph, api_constructor: ApiClassConstructor) -> Constructor {
    constructor := Constructor {
        index = api_constructor.index,
        args  = make([]Constructor_Arg, len(api_constructor.arguments)),
    }

    for api_arg, arg_idx in api_constructor.arguments {
        assert(api_arg.default_value == nil, "Unexpected default value in builtin class constructor")
        constructor.args[arg_idx] = Constructor_Arg {
            name = api_arg.name,
            type = _graph_resolve_type(graph, api_arg.type),
        }
    }

    return constructor
}

@(private = "file")
_graph_member :: proc(graph: ^Graph, api_class: ApiBuiltinClass, api_member: ApiClassMember) -> Member {
    member := Member {
        name = api_member.name,
        type = _graph_resolve_type(graph, api_member.type),
    }

    for config_key, configuration in graph.configuration {
        offset_map, offset_map_ok := configuration.member_offsets[api_class.name]
        if !offset_map_ok {
            // N.B. if this class has no member offsets for a configuration, its not going to have any
            // for any other configurations either
            break
        }

        member_offset, member_offset_ok := offset_map[api_member.name]
        if !member_offset_ok {
            // N.B. if this class has no member offsets for a configuration, its not going to have any
            // for any other configurations either
            break
        }

        member.offsets[config_key] = member_offset
    }

    return member
}

@(private = "file")
_graph_engine_method :: proc(graph: ^Graph, api_method: ApiClassMethod) -> Method {
    method := Method {
        name        = api_method.name,
        hash        = api_method.hash,
        // builtin methods are never virtual
        virtual     = api_method.is_virtual,
        static      = api_method.is_static,
        vararg      = api_method.is_vararg,
        return_type = nil,
        args        = make([]Method_Arg, len(api_method.arguments)),
    }

    // assert(api_method.name != "get_char_from_glyph_index")

    if return_value, ok := api_method.return_value.(ApiClassMethodReturnValue); ok {
        return_type_string := return_value.meta.(string) or_else return_value.type
        method.return_type = _graph_resolve_type(graph, return_type_string)
    }

    for api_arg, arg_idx in api_method.arguments {
        method.args[arg_idx] = Method_Arg {
            name    = api_arg.name,
            type    = _graph_resolve_type(graph, api_arg.type),
            default = api_arg.default_value,
        }
    }

    return method
}

@(private = "file")
_graph_builtin_method :: proc(graph: ^Graph, api_method: ApiBuiltinClassMethod) -> Method {
    method := Method {
        name        = api_method.name,
        hash        = api_method.hash,
        // builtin methods are never virtual
        virtual     = false,
        static      = api_method.is_static,
        vararg      = api_method.is_vararg,
        return_type = nil,
        args        = make([]Method_Arg, len(api_method.arguments)),
    }

    if return_type_string, ok := api_method.return_type.(string); ok {
        method.return_type = _graph_resolve_type(graph, return_type_string)
    }

    for api_arg, arg_idx in api_method.arguments {
        method.args[arg_idx] = Method_Arg {
            name    = api_arg.name,
            type    = _graph_resolve_type(graph, api_arg.type),
            default = api_arg.default_value,
        }
    }

    return method
}

@(private = "file")
_graph_operator :: proc(graph: ^Graph, api_operator: ApiClassOperator) -> Operator {
    operator_name, ok := operator_name_map[api_operator.name]
    assert(ok)

    operator := Operator {
        name        = operator_name,
        return_type = _graph_resolve_type(graph, api_operator.return_type),
        right_type  = nil,
    }

    if right_type_string, ok := api_operator.right_type.(string); ok {
        operator.right_type = _graph_resolve_type(graph, right_type_string)
    }

    return operator
}

@(private = "file")
_graph_property :: proc(graph: ^Graph, api_property: ApiClassProperty) -> Property {
    return Property {
        name = api_property.name,
        getter = api_property.getter,
        setter = api_property.setter,
        type = _graph_resolve_type(graph, api_property.type),
    }
}

@(private = "file")
_graph_signal :: proc(graph: ^Graph, api_signal: ApiClassSignal) -> Signal {
    signal := Signal {
        name = api_signal.name,
        args = make([]Signal_Arg, len(api_signal.arguments)),
    }

    for api_arg, arg_idx in api_signal.arguments {
        signal.args[arg_idx] = Signal_Arg {
            name = api_arg.name,
            type = _graph_resolve_type(graph, api_arg.type),
        }
    }

    return signal
}

@(private = "file")
_graph_singleton :: proc(graph: ^Graph, api_singleton: ApiSingleton) -> Singleton {
    return Singleton{name = api_singleton.name, type = _graph_resolve_type(graph, api_singleton.type)}
}

@(private = "file")
_graph_util_proc :: proc(graph: ^Graph, api_util_func: ApiUtilityFunction) -> Util_Proc {
    util_proc := Util_Proc {
        name        = api_util_func.name,
        hash        = api_util_func.hash,
        vararg      = api_util_func.is_vararg,
        category    = api_util_func.category,
        return_type = nil,
        args        = make([]Method_Arg, len(api_util_func.arguments)),
    }

    return util_proc
}

@(private = "file")
_search_class_enums :: proc(enums: []Class_Enum($C), name: names.Godot_Name) -> (ret: ^Class_Enum(C), ok: bool) {
    for &class_enum in enums {
        if class_enum.name == name {
            return &class_enum, true
        }
    }
    return nil, false
}

@(private = "file")
_search_class_bit_fields :: proc(
    bit_fields: []Class_Bit_Field($C),
    name: names.Godot_Name,
) -> (
    ret: ^Class_Bit_Field(C),
    ok: bool,
) {
    for &class_bit_field in bit_fields {
        if class_bit_field.name == name {
            return &class_bit_field, true
        }
    }
    return nil, false
}

@(private = "file")
_graph_native_struct_field_type :: proc(graph: ^Graph, type_string: string) -> Any_Type {
    colon_idx := strings.index(type_string, "::")
    if colon_idx > -1 {
        // type is a member of another type
        class_type := _graph_resolve_type(graph, type_string[:colon_idx])
        child_type_string := cast(names.Godot_Name)type_string[colon_idx + 2:]

        #partial switch class in class_type {
        case ^Builtin_Class:
            if class_enum, ok := _search_class_enums(class.enums, child_type_string); ok {
                return class_enum
            }

            if class_bit_field, ok := _search_class_bit_fields(class.bit_fields, child_type_string); ok {
                return class_bit_field
            }
        case ^Engine_Class:
            if class_enum, ok := _search_class_enums(class.enums, child_type_string); ok {
                return class_enum
            }

            if class_bit_field, ok := _search_class_bit_fields(class.bit_fields, child_type_string); ok {
                return class_bit_field
            }
        case:
            panic("Expected ClassName in ClassName::TypeName to be an Engine Class or Builtin Class")
        }

        panic("Couldn't match type in struct format to a type")
    }

    return _graph_resolve_type(graph, type_string)
}

/*
native struct formats follow the following grammar:

WS         := ' '*
ident      := [a-zA-Z_][a-zA-Z0-9_]*
prefix     := ident '::'
field      := prefix? ident WS '*'? WS ident
field_list := field (';' WS format)?
*/
@(private = "file")
_graph_native_struct_fields :: proc(graph: ^Graph, format: string) -> []Struct_Field {
    fields := make([]Struct_Field, strings.count(format, ";"))
    format := format
    field_idx := 0
    for field_format in strings.split_iterator(&format, ";") {
        field := Struct_Field{}

        split_idx := strings.index_proc(field_format, strings.is_space)
        assert(split_idx > -1)

        split_idx = strings.index_proc(field_format[split_idx:], strings.is_space, truth = false)

        remainder := field_format[split_idx:]
        for remainder[split_idx] == '*' {
            split_idx += 1
        }

        // we want to include the pointer in the type specifier
        field.type = _graph_native_struct_field_type(graph, field_format[:split_idx])

        // remainder contains the field's name and the default value
        remainder = field_format[split_idx:]
        space_idx := strings.index_proc(remainder, strings.is_space)
        if space_idx > -1 {
            field.name = remainder[:space_idx]
            remainder = remainder[space_idx:]

            // the default value is always a number literal, with no spaces mixed in
            space_idx = strings.last_index_proc(remainder, strings.is_space)
            field.default = remainder[space_idx + 1:]
        } else {
            field.name = remainder
        }

        field_idx += 1
    }

    return fields
}

graph_relationship_pass :: proc(graph: ^Graph, api: ^Api) {
    context.allocator = graph.allocator

    for api_builtin_class, class_idx in api.builtin_classes {
        builtin_class := &graph.builtin_classes[class_idx]

        builtin_class.layout_float32 = Layout {
            size           = graph.configuration["float_32"].class_sizes[api_builtin_class.name],
            member_offsets = graph.configuration["float_32"].member_offsets[api_builtin_class.name],
        }

        builtin_class.layout_float64 = Layout {
            size           = graph.configuration["float_64"].class_sizes[api_builtin_class.name],
            member_offsets = graph.configuration["float_64"].member_offsets[api_builtin_class.name],
        }

        builtin_class.layout_double32 = Layout {
            size           = graph.configuration["double_32"].class_sizes[api_builtin_class.name],
            member_offsets = graph.configuration["double_32"].member_offsets[api_builtin_class.name],
        }

        builtin_class.layout_double64 = Layout {
            size           = graph.configuration["double_64"].class_sizes[api_builtin_class.name],
            member_offsets = graph.configuration["double_64"].member_offsets[api_builtin_class.name],
        }

        for api_constant, constant_idx in api_builtin_class.constants {
            builtin_class.constants[constant_idx] = _graph_constant(graph, api_constant)
        }

        for api_constructor, constructor_idx in api_builtin_class.constructors {
            builtin_class.constructors[constructor_idx] = _graph_constructor(graph, api_constructor)
        }

        for api_member, member_idx in api_builtin_class.members {
            builtin_class.members[member_idx] = _graph_member(graph, api_builtin_class, api_member)
        }

        for api_method, method_idx in api_builtin_class.methods {
            builtin_class.methods[method_idx] = _graph_builtin_method(graph, api_method)
        }

        for api_operator, operator_idx in api_builtin_class.operators {
            builtin_class.operators[operator_idx] = _graph_operator(graph, api_operator)
        }
    }

    for api_engine_class, class_idx in api.classes {
        class := &graph.engine_classes[class_idx]

        class_godot_name := api_engine_class.inherits.(names.Godot_Name) or_else "Object"
        class.inherits = _graph_resolve_type(graph, cast(string)class_godot_name)

        for api_constant, constant_idx in api_engine_class.constants {
            class.constants[constant_idx] = _graph_constant(graph, api_constant)
        }

        for api_property, property_idx in api_engine_class.properties {
            class.properties[property_idx] = _graph_property(graph, api_property)
        }

        for api_method, method_idx in api_engine_class.methods {
            class.methods[method_idx] = _graph_engine_method(graph, api_method)
        }

        for api_operator, operator_idx in api_engine_class.operators {
            class.operators[operator_idx] = _graph_operator(graph, api_operator)
        }

        for api_signal, signal_idx in api_engine_class.signals {
            class.signals[signal_idx] = _graph_signal(graph, api_signal)
        }
    }

    for api_struct, struct_idx in api.native_structs {
        native_struct := &graph.native_structs[struct_idx]
        native_struct.fields = _graph_native_struct_fields(graph, api_struct.format)
    }

    for api_singleton, singleton_idx in api.singletons {
        graph.singletons[singleton_idx] = _graph_singleton(graph, api_singleton)
    }

    for api_util_func, util_func_idx in api.util_functions {
        graph.util_procs[util_func_idx] = _graph_util_proc(graph, api_util_func)
    }
}

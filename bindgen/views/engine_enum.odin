package views

// import g "../graph"
// import "core:mem"
// import "core:strings"

// Engine_Enums :: struct {
//     enums:      []Enum,
//     bit_fields: []Bit_Field,
// }

// engine_enums :: proc(graph: ^g.Graph, allocator: mem.Allocator) -> (enums: Engine_Enums) {
//     enums = Engine_Enums {
//         enums      = make([]Enum, len(graph.enums)),
//         bit_fields = make([]Bit_Field, len(graph.bit_fields)),
//     }

//     for graph_enum, enum_idx in graph.enums {
//         new_enum := Enum {
//             name   = strings.clone(cast(string)graph_enum.name),
//             values = make([]Enum_Value, len(graph_enum.values)),
//         }

//         for value, value_idx in graph_enum.values {
//             new_enum.values[value_idx] = Enum_Value {
//                 name  = cast(string)names.to_odin(value.name),
//                 value = strings.clone(value.value),
//             }
//         }

//         enums.enums[enum_idx] = new_enum
//     }

//     for class_bit_field, bit_field_idx in graph.bit_fields {
//         new_bit_field := Bit_Field {
//             name   = string.clone(cast(string)class_bit_field.name),
//             values = make([]Enum_Value, len(class_bit_field.values)),
//         }

//         for value, value_idx in class_bit_field.values {
//             new_bit_field.values[value_idx] = Enum_Value {
//                 name  = cast(string)names.to_odin(value.name),
//                 value = strings.clone(value.value),
//             }
//         }

//         engine_class.bit_fields[bit_field_idx] = new_enum
//     }
// }

package views

import g "../graph"
import "../names"
import "core:mem"
import "core:strings"

Structs :: struct {
    imports: map[string]Import,
    structs: []Struct,
}

Struct :: struct {
    name:   string,
    fields: []Struct_Field,
}

Struct_Field :: struct {
    name: string,
    type: string,
}

native_structs :: proc(graph: ^g.Graph, allocator: mem.Allocator) -> (structs: Structs) {
    structs = Structs {
        structs = make([]Struct, len(graph.native_structs)),
    }

    for native_struct, struct_idx in graph.native_structs {
        new_struct := Struct {
            name   = names.clone_string(native_struct.odin_name),
            fields = make([]Struct_Field, len(native_struct.fields)),
        }

        for field, field_idx in native_struct.fields {
            ensure_imports(&structs.imports, field.type, "godot:structs")
            new_struct.fields[field_idx] = Struct_Field {
                name = strings.clone(field.name),
                type = resolve_qualified_type(field.type, "godot:structs"),
                // TODO: default values
            }
        }

        structs.structs[struct_idx] = new_struct
    }

    return
}

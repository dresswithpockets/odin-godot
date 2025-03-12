package views

import g "../graph"
import "../names"
import "core:mem"
import "core:strings"

Engine_Init :: struct {
    packages:       []string,
    parent_package: string,
}

engine_init :: proc(graph: ^g.Graph, api_type: g.Engine_Api_Type, allocator: mem.Allocator) -> (init: Engine_Init) {
    context.allocator = allocator

    class_count := 0
    for class in graph.engine_classes {
        if class.api_type == api_type {
            class_count += 1
        }
    }

    init = Engine_Init {
        packages       = make([]string, class_count),
        parent_package = g.to_string(api_type),
    }

    class_idx := 0
    for class in graph.engine_classes {
        if class.api_type == api_type {
            init.packages[class_idx] = cast(string)names.to_snake(class.name)
            class_idx += 1
        }
    }

    return
}

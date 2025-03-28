#+private
package bindgen

import "../temple"
import "base:runtime"
import "core:fmt"
import "core:io"
import "core:mem"
import "core:os"
import "core:thread"

import g "graph"
import "views"

@(private = "file")
UNIX_ALLOW_READ_WRITE_ALL :: 0o666

open_write_template :: proc(file_path: string, view: $T, template: temple.Compiled(T)) {
    fhandle, ferr := os.open(file_path, os.O_CREATE | os.O_TRUNC | os.O_RDWR, UNIX_ALLOW_READ_WRITE_ALL)
    if ferr != 0 {
        fmt.eprintfln("Error opening %v", file_path)
        return
    }
    defer {
        os.flush(fhandle)
        os.close(fhandle)
    }

    fstream := os.stream_from_handle(fhandle)
    flusher, flusher_ok := io.to_flusher(fstream)
    defer if flusher_ok {
        io.flush(flusher)
    }

    _, terr := template.with(fstream, view)
    if terr != nil {
        fmt.eprintfln("Error writing template %v (%v): %v", typeid_of(T), file_path, terr)
    }
}

codegen_godot :: proc(task: thread.Task) {
    graph := cast(^g.Graph)task.data

    tracking_alloc: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_alloc, context.allocator)

    allocator := mem.tracking_allocator(&tracking_alloc)

    view := views.godot_package(graph, allocator = allocator)
    open_write_template("godot/godot.gen.odin", view, core_template)

    free_all(allocator)
}

codegen_engine_class :: proc(task: thread.Task) {
    class := cast(^g.Engine_Class)task.data

    tracking_alloc: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_alloc, context.allocator)

    allocator := mem.tracking_allocator(&tracking_alloc)
    if view, should_render := views.engine_class(class, allocator = allocator); should_render {
        file_path := fmt.aprintf("godot/%v.gen.odin", view.snake_name, allocator = allocator)
        open_write_template(file_path, view, engine_class_template)
    }

    free_all(allocator)
}

codegen_native_structs :: proc(task: thread.Task) {
    graph := cast(^g.Graph)task.data

    tracking_alloc: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_alloc, context.allocator)

    allocator := mem.tracking_allocator(&tracking_alloc)

    view := views.native_structs(graph, allocator = allocator)
    open_write_template("godot/structs.gen.odin", view, structs_template)

    free_all(allocator)
}

codegen_variant :: proc(task: thread.Task) {
    class := cast(^g.Builtin_Class)task.data

    tracking_alloc: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_alloc, context.allocator)

    allocator := mem.tracking_allocator(&tracking_alloc)
    if view, should_render := views.variant(class, allocator = allocator); should_render {
        file_path := fmt.aprintf("godot/%v.gen.odin", view.name, allocator = allocator)
        open_write_template(file_path, view, variant_template)
    }

    free_all(allocator)
}

generate_bindings :: proc(graph: g.Graph, options: Options) {
    graph := graph

    views.map_types_to_imports(graph, options.map_mode)

    if options.job_count == 1 {
        codegen_godot(thread.Task{data = &graph})\
        codegen_native_structs(thread.Task{data = &graph})
        for &builtin_class in graph.builtin_classes {
            codegen_variant(thread.Task{data = &builtin_class})
        }
    
        for &engine_class in graph.engine_classes {
            codegen_engine_class(thread.Task{data = &engine_class})
        }

        return
    }

    thread_pool: thread.Pool
    thread.pool_init(&thread_pool, context.allocator, options.job_count)
    thread.pool_add_task(&thread_pool, context.allocator, codegen_godot, &graph)
    thread.pool_add_task(&thread_pool, context.allocator, codegen_native_structs, &graph)
    for &builtin_class in graph.builtin_classes {
        thread.pool_add_task(&thread_pool, context.allocator, codegen_variant, &builtin_class)
    }

    for &engine_class in graph.engine_classes {
        thread.pool_add_task(&thread_pool, context.allocator, codegen_engine_class, &engine_class)
    }

    thread.pool_start(&thread_pool)
    thread.pool_finish(&thread_pool)
}

/*
    Copyright 2025 Dresses Digital

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

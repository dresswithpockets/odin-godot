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

constructor_type :: "gdextension.PtrConstructor"
destructor_type :: "gdextension.PtrDestructor"
operator_evaluator_type :: "gdextension.PtrOperatorEvaluator"
builtin_method_type :: "gdextension.PtrBuiltInMethod"

native_odin_types :: []string{"bool", "f32", "f64", "int", "i8", "i16", "i32", "i64", "u8", "u16", "u32", "u64"}

types_with_odin_string_constructors :: []string{"String", "StringName"}

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

codegen_core :: proc(task: thread.Task) {
    graph := cast(^g.Graph)task.data

    tracking_alloc: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_alloc, context.allocator)

    allocator := mem.tracking_allocator(&tracking_alloc)

    view := views.core_package(graph, allocator = allocator)
    open_write_template("core/core.gen.odin", view, core_template)

    free_all(allocator)
}

codegen_editor :: proc(task: thread.Task) {
    graph := cast(^g.Graph)task.data

    tracking_alloc: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_alloc, context.allocator)

    allocator := mem.tracking_allocator(&tracking_alloc)

    view := views.editor_package(graph, allocator = allocator)
    open_write_template("editor/editor.gen.odin", view, editor_template)

    free_all(allocator)
}

codegen_core_init :: proc(task: thread.Task) {
    graph := cast(^g.Graph)task.data

    os.make_directory("core/init", UNIX_ALLOW_READ_WRITE_ALL)

    tracking_alloc: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_alloc, context.allocator)

    allocator := mem.tracking_allocator(&tracking_alloc)

    view := views.engine_init(graph, .Core, allocator = allocator)
    open_write_template("core/init/init.gen.odin", view, engine_init_template)

    free_all(allocator)
}

codegen_editor_init :: proc(task: thread.Task) {
    graph := cast(^g.Graph)task.data

    os.make_directory("editor/init", UNIX_ALLOW_READ_WRITE_ALL)

    tracking_alloc: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_alloc, context.allocator)

    allocator := mem.tracking_allocator(&tracking_alloc)

    view := views.engine_init(graph, .Editor, allocator = allocator)
    open_write_template("editor/init/init.gen.odin", view, engine_init_template)

    free_all(allocator)
}

codegen_engine_class :: proc(task: thread.Task) {
    class := cast(^g.Engine_Class)task.data

    tracking_alloc: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_alloc, context.allocator)

    allocator := mem.tracking_allocator(&tracking_alloc)
    if view, should_render := views.engine_class(class, allocator = allocator); should_render {
        package_dir := fmt.aprintf("%v/%v", g.to_string(class.api_type), view.snake_name, allocator = allocator)
        os.make_directory(package_dir, UNIX_ALLOW_READ_WRITE_ALL)

        file_path := fmt.aprintf("%v/%v.gen.odin", package_dir, view.snake_name, allocator = allocator)
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
    open_write_template("structs/structs.gen.odin", view, structs_template)

    free_all(allocator)
}

codegen_variant :: proc(task: thread.Task) {
    class := cast(^g.Builtin_Class)task.data

    tracking_alloc: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_alloc, context.allocator)

    allocator := mem.tracking_allocator(&tracking_alloc)
    if view, should_render := views.variant(class, allocator = allocator); should_render {
        file_path := fmt.aprintf("variant/%v.gen.odin", view.name, allocator = allocator)
        open_write_template(file_path, view, variant_template)
    }

    free_all(allocator)
}

generate_bindings :: proc(graph: g.Graph, options: Options) {
    graph := graph

    views.map_types_to_imports(graph, options.map_mode)

    if options.job_count == 1 {
        codegen_core(thread.Task{data = &graph})
        codegen_core_init(thread.Task{data = &graph})
        codegen_editor(thread.Task{data = &graph})
        codegen_editor_init(thread.Task{data = &graph})
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
    thread.pool_add_task(&thread_pool, context.allocator, codegen_core, &graph)
    thread.pool_add_task(&thread_pool, context.allocator, codegen_core_init, &graph)
    thread.pool_add_task(&thread_pool, context.allocator, codegen_editor, &graph)
    thread.pool_add_task(&thread_pool, context.allocator, codegen_editor_init, &graph)
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

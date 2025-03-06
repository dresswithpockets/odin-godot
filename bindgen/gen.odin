#+private
package bindgen

import "base:runtime"
import "core:fmt"
import "core:io"
import "core:os"
import "core:thread"
import "../temple"

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

codegen_variant :: proc(task: thread.Task) {
    class := cast(^g.Builtin_Class)task.data
    view := views.variant(class)

    file_path := fmt.tprintf("variant/%v.gen.odin", view.name)
    defer delete(file_path, allocator = context.temp_allocator)

    open_write_template(file_path, view, variant_template)
}

generate_bindings :: proc(graph: g.Graph, options: Options) {
    views.map_types_to_imports(graph, options.map_mode)

    thread_pool: thread.Pool
    thread.pool_init(&thread_pool, context.allocator, options.job_count)
    for &builtin_class in graph.builtin_classes {
        thread.pool_add_task(&thread_pool, context.allocator, codegen_variant, &builtin_class)
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

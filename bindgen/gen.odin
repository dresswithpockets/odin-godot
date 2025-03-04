#+private
package bindgen

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:thread"

@(private = "file")
UNIX_ALLOW_READ_WRITE_ALL :: 0o666

constructor_type :: "gdextension.PtrConstructor"
destructor_type :: "gdextension.PtrDestructor"
operator_evaluator_type :: "gdextension.PtrOperatorEvaluator"
builtin_method_type :: "gdextension.PtrBuiltInMethod"

native_odin_types :: []string{"bool", "f32", "f64", "int", "i8", "i16", "i32", "i64", "u8", "u16", "u32", "u64"}

types_with_odin_string_constructors :: []string{"String", "StringName"}

generate_variant_init_task :: proc(task: thread.Task) {

    fhandle, ferr := os.open("variant/init.gen.odin", os.O_CREATE | os.O_TRUNC | os.O_RDWR, UNIX_ALLOW_READ_WRITE_ALL)
    if ferr != 0 {
        fmt.eprintln("Error opening variant/init.gen.odin")
        return
    }
    defer {
        os.flush(fhandle)
        os.close(fhandle)
    }

    fstream := os.stream_from_handle(fhandle)
    variant_init_template.with(fstream, cast(^State)task.data)
}

generate_core_init_task :: proc(task: thread.Task) {

    fhandle, ferr := os.open("core/init.gen.odin", os.O_CREATE | os.O_TRUNC | os.O_RDWR, UNIX_ALLOW_READ_WRITE_ALL)
    if ferr != 0 {
        fmt.eprintln("Error opening core/init.gen.odin")
        return
    }
    defer {
        os.flush(fhandle)
        os.close(fhandle)
    }

    fstream := os.stream_from_handle(fhandle)
    core_init_template.with(fstream, cast(^State)task.data)
}

generate_editor_init_task :: proc(task: thread.Task) {

    fhandle, ferr := os.open("editor/init.gen.odin", os.O_CREATE | os.O_TRUNC | os.O_RDWR, UNIX_ALLOW_READ_WRITE_ALL)
    if ferr != 0 {
        fmt.eprintln("Error opening editor/init.gen.odin")
        return
    }
    defer {
        os.flush(fhandle)
        os.close(fhandle)
    }

    fstream := os.stream_from_handle(fhandle)
    editor_init_template.with(fstream, cast(^State)task.data)
}

generate_global_enums_task :: proc(task: thread.Task) {
    fhandle, ferr := os.open("core/enums.gen.odin", os.O_CREATE | os.O_TRUNC | os.O_RDWR, UNIX_ALLOW_READ_WRITE_ALL)
    if ferr != 0 {
        fmt.eprintln("Error opening core/enums.gen.odin")
        return
    }
    defer {
        os.flush(fhandle)
        os.close(fhandle)
    }

    fstream := os.stream_from_handle(fhandle)
    global_enums_template.with(fstream, cast(^State)task.data)
}

generate_utility_functions_task :: proc(task: thread.Task) {
    fhandle, ferr := os.open("core/util.gen.odin", os.O_CREATE | os.O_TRUNC | os.O_RDWR, UNIX_ALLOW_READ_WRITE_ALL)
    if ferr != 0 {
        fmt.eprintln("Error opening core/util.gen.odin")
        return
    }
    defer {
        os.flush(fhandle)
        os.close(fhandle)
    }

    fstream := os.stream_from_handle(fhandle)
    util_functions_template.with(fstream, cast(^State)task.data)
}

generate_native_structs_task :: proc(task: thread.Task) {
    fhandle, ferr := os.open("core/native.gen.odin", os.O_CREATE | os.O_TRUNC | os.O_RDWR, UNIX_ALLOW_READ_WRITE_ALL)
    if ferr != 0 {
        fmt.eprintln("Error opening core/native.gen.odin")
        return
    }
    defer {
        os.flush(fhandle)
        os.close(fhandle)
    }

    fstream := os.stream_from_handle(fhandle)
    native_struct_template.with(fstream, cast(^State)task.data)
}

generate_builtin_class_task :: proc(task: thread.Task) {
    class := cast(^StateType)task.data

    file_path := fmt.tprintf("variant/%v.gen.odin", class.odin_type)
    defer delete(file_path, allocator = context.temp_allocator)

    fhandle, ferr := os.open(file_path, os.O_CREATE | os.O_TRUNC | os.O_RDWR, UNIX_ALLOW_READ_WRITE_ALL)
    if ferr != 0 {
        fmt.eprintf("Error opening %v\n", file_path)
        return
    }
    defer {
        os.flush(fhandle)
        os.close(fhandle)
    }

    fstream := os.stream_from_handle(fhandle)
    builtin_class_template.with(fstream, class)
}

generate_engine_class_task :: proc(task: thread.Task) {
    class := cast(^StateType)task.data

    file_path := fmt.tprintf("%v/%v.gen.odin", class.derived.(StateClass).api_type, class.odin_type)
    defer delete(file_path, allocator = context.temp_allocator)

    fhandle, ferr := os.open(file_path, os.O_CREATE | os.O_TRUNC | os.O_RDWR, UNIX_ALLOW_READ_WRITE_ALL)
    if ferr != 0 {
        fmt.eprintf("Error opening %v\n", file_path)
        return
    }
    defer {
        os.flush(fhandle)
        os.close(fhandle)
    }

    fstream := os.stream_from_handle(fhandle)
    engine_class_template.with(fstream, class)
}

generate_bindings :: proc(state: ^State) {
    thread_pool: thread.Pool
    thread.pool_init(&thread_pool, context.allocator, state.options.job_count)
    thread.pool_add_task(&thread_pool, context.allocator, generate_global_enums_task, state)
    thread.pool_add_task(&thread_pool, context.allocator, generate_utility_functions_task, state)
    thread.pool_add_task(&thread_pool, context.allocator, generate_native_structs_task, state)
    thread.pool_add_task(&thread_pool, context.allocator, generate_variant_init_task, state)
    thread.pool_add_task(&thread_pool, context.allocator, generate_core_init_task, state)
    thread.pool_add_task(&thread_pool, context.allocator, generate_editor_init_task, state)

    for builtin_class in state.builtin_classes do if !builtin_class.odin_skip {
        _, ok := builtin_class.derived.(StateClass)
        assert(ok)
        thread.pool_add_task(&thread_pool, context.allocator, generate_builtin_class_task, builtin_class)
    }

    for engine_class in state.classes do if !engine_class.odin_skip {
        _, ok := engine_class.derived.(StateClass)
        assert(ok)
        thread.pool_add_task(&thread_pool, context.allocator, generate_engine_class_task, engine_class)
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

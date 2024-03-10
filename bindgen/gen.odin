//+private
package bindgen

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
import "core:path/filepath"
import "core:strconv"
import "core:io"
import "core:sync"
import "core:thread"
import "base:runtime"

@(private="file")
UNIX_ALLOW_READ_WRITE_ALL :: 0o666

constructor_type :: "gdextension.PtrConstructor"
destructor_type :: "gdextension.PtrDestructor"
operator_evaluator_type :: "gdextension.PtrOperatorEvaluator"
builtin_method_type :: "gdextension.PtrBuiltInMethod"

native_odin_types :: []string {
    "bool",
    "f32",
    "f64",
    "int",
    "i8",
    "i16",
    "i32",
    "i64",
    "u8",
    "u16",
    "u32",
    "u64",
}

types_with_odin_string_constructors :: []string{"String", "StringName"}

@private
generate_global_enums :: proc(state: ^NewState) {
    fhandle, ferr := os.open("core/enums.gen.odin", os.O_CREATE | os.O_TRUNC | os.O_RDWR, UNIX_ALLOW_READ_WRITE_ALL)
    if ferr != 0 {
        fmt.eprintf("Error opening core/enums.gen.odin\n")
        return
    }
    defer os.close(fhandle)

    fstream := os.stream_from_handle(fhandle)
    global_enums_template.with(fstream, state)
}

@private
generate_builtin_class :: proc(class: ^NewStateType) {
    file_path := fmt.tprintf("variant/%v.gen.odin", class.odin_type)
    defer delete(file_path, allocator = context.temp_allocator)

    fhandle, ferr := os.open(file_path, os.O_CREATE | os.O_TRUNC | os.O_RDWR, UNIX_ALLOW_READ_WRITE_ALL)
    if ferr != 0 {
        fmt.eprintf("Error opening %v\n", file_path)
        return
    }
    defer os.close(fhandle)

    fstream := os.stream_from_handle(fhandle)
    builtin_class_template.with(fstream, class)
}

generate_bindings :: proc(state: ^NewState) {
    generate_global_enums(state)

    for builtin_class in state.builtin_classes do if !builtin_class.odin_skip {
        _, ok := builtin_class.derived.(NewStateClass)
        assert(ok)
        generate_builtin_class(builtin_class)
    }
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

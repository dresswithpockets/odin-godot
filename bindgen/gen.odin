//+private
package bindgen

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
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

pod_types :: []string{
    "Nil",
    "void",
    "bool",
    "real_t",
    "float",
    "double",
    "int",
    "int8_t",
    "uint8_t",
    "int16_t",
    "uint16_t",
    "int32_t",
    "int64_t",
    "uint32_t",
    "uint64_t",
}

pod_type_map := map[string]string{
    "bool"     = "bool",
    "real_t"   = "f64",
    "float"    = "f64",
    "double"   = "f64",
    "int"      = "int",
    "int8_t"   = "i8",
    "int16_t"  = "i16",
    "int32_t"  = "i32",
    "int64_t"  = "i64",
    "uint8_t"  = "u8",
    "uint16_t" = "u16",
    "uint32_t" = "u32",
    "uint64_t" = "u64",
    "int8"     = "i8",
    "int16"    = "i16",
    "int32"    = "i32",
    "int64"    = "i64",
    "uint8"    = "u8",
    "uint16"   = "u16",
    "uint32"   = "u32",
    "uint64"   = "u64",

    "const void*" = "rawptr",
    "void*"       = "rawptr",
}

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

generate_bindings :: proc(state: ^NewState) {
    generate_global_enums(state)
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

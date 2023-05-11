package gdextension

import "../gdextension"
import "core:c"
import "core:runtime"
import "core:mem"

godot_allocator_proc :: proc(
    allocator_data: rawptr,
    mode: mem.Allocator_Mode,
    size, alignment: int,
    old_memory: rawptr,
    old_size: int,
    loc := #caller_location,
) -> (
    []byte,
    mem.Allocator_Error,
) {

    interface := cast(^gdextension.Interface)allocator_data

    switch mode {
    case .Alloc, .Alloc_Non_Zeroed:
        ptr := interface.mem_alloc(cast(c.size_t)size)
        if ptr == nil {
            return nil, .Out_Of_Memory
        }
        return mem.byte_slice(ptr, size), nil

    case .Free:
        interface.mem_free(old_memory)

    case .Free_All:
        return nil, .Mode_Not_Implemented

    case .Resize:
        ptr: rawptr
        if old_memory == nil {
            ptr = interface.mem_alloc(cast(c.size_t)size)
            if ptr == nil {
                return nil, .Out_Of_Memory
            }
            return mem.byte_slice(ptr, size), nil
        }
        ptr = interface.mem_realloc(ptr, cast(c.size_t)size)
        if ptr == nil {
            return nil, .Out_Of_Memory
        }
        return mem.byte_slice(ptr, size), nil

    case .Query_Features:
        set := (^mem.Allocator_Mode_Set)(old_memory)
        if set != nil {
            set^ = {.Alloc, .Alloc_Non_Zeroed, .Free, .Resize, .Query_Features}
        }
        return nil, nil

    case .Query_Info:
        return nil, .Mode_Not_Implemented
    }

    return nil, nil
}

godot_allocator :: #force_inline proc "contextless" () -> (a: runtime.Allocator) {
    return mem.Allocator{procedure = godot_allocator_proc, data = interface}
}

@(private)
default_godot_allocator := godot_allocator()

@(private)
temp_arena := runtime.Arena {
    backing_allocator = default_godot_allocator,
}

@(private)
default_temp_godot_allocator := runtime.Allocator{runtime.arena_allocator_proc, &temp_arena}

godot_context :: #force_inline proc "contextless" () -> (c: runtime.Context) {
    c.allocator = default_godot_allocator
    c.allocator.data = interface
    c.temp_allocator = default_temp_godot_allocator
    return
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

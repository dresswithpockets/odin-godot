package core

import "../gdinterface"
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

    interface := cast(^gdinterface.Interface)allocator_data

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

godot_allocator :: proc "contextless" () -> (a: runtime.Allocator) {
    return mem.Allocator{procedure = godot_allocator_proc, data = interface}
}

godot_context :: proc "contextless" () -> (c: runtime.Context) {
    c.allocator = godot_allocator()
    return
}

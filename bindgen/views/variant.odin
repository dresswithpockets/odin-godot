package views

import g "../graph"
import "core:mem"
import "core:strings"

Import :: struct {
    name: string,
    path: string,
}

Enum :: struct {
    name:   string,
    values: []Enum_Value,
}

Enum_Value :: struct {
    name:  string,
    value: string,
}

File_Constant :: struct {
    name:  string,
    type:  string,
    value: string,
}

Init_Constant :: struct {
    name: string,
    type: string,
}

Constructor :: struct {
    name:  string,
    index: int,
    args:  []Constructor_Arg,
}

Constructor_Arg :: struct {
    name: string,
    type: string,
}

Getter :: struct {}

Setter :: struct {}

Method :: struct {}

Operator :: struct {}

Variant :: struct {
    imports:                   []Import,
    name:                      string,
    size_float32:              int,
    size_float64:              int,
    size_double32:             int,
    size_double64:             int,
    enums:                     []Enum,
    // constants rendered as compile-time constants (`x :: y` in Odin)
    file_constants:            []File_Constant,
    // constants rendered as a static variable that has to be initialized in a proc
    init_constants:            []Init_Constant,
    constructor_overload_name: string,
    // constructors rendered in the template that correlate 1-to-1 with a builtin constructor in Godot
    constructors:              []Constructor,
    // special constructor names written manually, these are included in the `new_XX` overload proc
    extern_constructors:       []string,
    destructor:                Maybe(string),
    getters:                   []Getter,
    setters:                   []Setter,
    methods:                   []Method,
    operators:                 []Operator,
}

variant :: proc(class: ^g.Builtin_Class) -> Variant {
    unimplemented()
}

free_variant :: proc(view: Variant) -> (error: mem.Allocator_Error) {
    unimplemented()
}

package views

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
    name:        string,
    type:        string,
    constructor: string,
    args:        []string,
}

Method :: struct {
    name:        string,
    vararg:      bool,
    hash:        i64,
    return_type: Maybe(string),
    args:        []Method_Arg,
}

Method_Arg :: struct {
    name: string,
    type: string,
}

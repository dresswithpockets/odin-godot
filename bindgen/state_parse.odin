package bindgen

import "core:fmt"
import "core:slice"
import "core:strings"

/*  Api_Graph


*/
Api_Graph :: struct {
    types: []Graph_Type,
}

Graph_Type :: struct {
    api: union {
        ^ApiBuiltinClass,
        ^ApiClass,
        ^ApiEnum,
        ^ApiNativeStructure,
    }
}

/*
State is all of the information transformed from the Api input

State calculates the following:
- odin-case struct, enum, and function names
- backing-field names for function pointers, default values
*/

State :: struct {
    options:       Options,
    api:           ^Api,

    // maps godot type names to their parsed type
    // all_types:         map[string]Type,

    // views that will be passed to templates
    global_enums:  []Enum,
    variant_types: []VariantType,
    // core_classes:      []Class,
    // core_singletons:   []Singleton,
    // editor_classes:    []Class,
    // editor_singletons: []Singleton,
    // native_structs:    []NativeStruct,
    // util_procs:        []UtilityFunction,
}

FileImport :: struct {
    name: string,
    path: string,
}

Enum :: struct {
    type_name: string,
    names:     []string,
    values:    []i64,
}

VariantType :: struct {
    package_path: string,
    file_name:    string,
    imports:      []FileImport,
    type_name:    string,
    members:      []Member,
    enums:        []Enum,
    constants:    []Constant,
    constructors: []Constructor,
    destructors:  []Destructor,
    methods:      []Method,
    operators:    []Operator,
}

parse_state :: proc(options: Options, api: ^Api) -> ^State {
    state := State{}
    // type pass

    // view pass
    for api_builtin in api.builtin_classes {
        godot_name := api_builtin.name
        odin_name := state.godot_to_odin[godot_name]

        variant_type := VariantType {
            package_path = "variant",
            file_name    = fmt.tprintf("%v.gen.odin", odin_name),
            imports      = nil,
            type_name    = odin_name,
            members      = nil,
            enums        = nil,
            constants    = nil,
            constructors = nil,
            destructors  = nil,
            methods      = nil,
            operators    = nil,
        }
    }
}

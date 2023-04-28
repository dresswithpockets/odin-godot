package bindgen

import "core:encoding/json"
import "core:fmt"
import "core:os"

Options :: struct {
    api_file: string,
}

ApiLoadError :: enum {
    CantOpenFile,
    CantParseJson,
}

Api :: struct {
    version: ApiVersion `json:"header"`,
    builtin_sizes: []ApiBuiltinClassSizes `json:"builtin_class_sizes"`,
    builtin_offsets: []ApiBuiltinClassMemberOffsets `json:"builtin_class_member_offsets"`,
    constants: []ApiGlobalConstant `json:"global_constants"`,
    enums: []ApiGlobalEnum `json:"global_enums"`,
    util_functions: []ApiUtilityFunction `json:"utility_functions"`,
    builtin_classes: []ApiBuiltinClass `json:"builtin_classes"`,
    classes: []ApiClass `json:"classes"`,
    singletons: []ApiSingleton `json:"singletons"`,
    native_structs: []ApiNativeStructure `json:"native_structures"`,
}

ApiVersion :: struct {
    major: uint `json:"version_major"`,
    minor: uint `json:"version_minor"`,
    patch: uint `json:"version_patch"`,
    status: string `json:"version_status"`,
    build: string `json:"version_build"`,
    full_name: string `json:"version_full_name"`,
}

ApiBuiltinClassSizes :: struct {
    configuration: string `json:"build_configuration"`,
    sizes: []ApiTypeSize,
}

ApiTypeSize :: struct {
    name: string,
    size: uint,
}

ApiBuiltinClassMemberOffsets :: struct {
    configuration: string `json:"build_configuration"`,
    classes: []ApiMemberOffsetClass `json:"classes"`,
}

ApiMemberOffsetClass :: struct {
    name: string `json:"name"`,
    members: []ApiMemberOffset `json:"members"`,
}

ApiMemberOffset :: struct {
    member: string `json:"member"`,
    offset: uint `json:"offset"`,
    meta: string `json:"meta"`,
}

ApiGlobalConstant :: struct {}

ApiGlobalEnum :: struct {
    name: string `json:"name"`,
}

ApiUtilityFunction :: struct {
    name: string `json:"name"`,
}

ApiBuiltinClass :: struct {
    name: string `json:"name"`,
}

ApiClass :: struct {
    name: string `json:"name"`,
}

ApiSingleton :: struct {
    name: string `json:"name"`,
}

ApiNativeStructure :: struct {
    name: string `json:"name"`,
}

print_usage :: proc() {
    fmt.printf("%v generates Odin bindings from godot's extension_api.json")
    fmt.println("Usage:\n")
    fmt.printf("\t%v (api_json_path)\n", os.args[0])
}

parse_args :: proc(options: ^Options) -> bool {
    options.api_file = os.args[1]
    return true
}

load_api :: proc(options: Options) -> (api: ^Api, ok: bool) {
    data := os.read_entire_file(options.api_file) or_return
    defer delete(data)

    api = new(Api)
    err := json.unmarshal(data, api)
    ok = err == nil
    return
}

// free_api :: proc(api: ^Api) {
//     for configuration in api.builtin_sizes {
//         delete(configuration.configuration)
//         delete(configuration.sizes)
//     }
//     delete(api.builtin_sizes)

//     for configuration in api.builtin_offsets {
//         delete(configuration.configuration)
//         for class in configuration.classes {
//             delete(class.members)
//         }
//         delete(configuration.classes)
//     }
//     delete(api.builtin_offsets)

//     delete(api.constants)
//     delete(api.enums)
//     delete(api.util_functions)
//     delete(api.builtin_classes)
//     delete(api.classes)
//     delete(api.singletons)
//     delete(api.native_structs)
//     free(api)
// }

main :: proc() {
    options: Options

    if len(os.args) != 2 {
        print_usage()
        os.exit(1)
    }

    if ok := parse_args(&options); !ok {
        os.exit(1)
    }

    api, ok := load_api(options)
    if !ok {
        fmt.println("There was an error loading the api from the file.")
        os.exit(1)
    }

    fmt.printf("Generating API for %v\n", api.version.full_name)
    // since we wanna keep api around until the end of the program's lifetime,
    // no need to be particular about freeing the bits and pieces of the struct (:
    free_all()
}

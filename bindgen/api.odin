package bindgen

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

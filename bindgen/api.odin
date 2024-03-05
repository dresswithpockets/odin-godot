//+private
package bindgen

Api :: struct {
    version:         ApiVersion `json:"header"`,
    builtin_sizes:   []ApiBuiltinClassSizes `json:"builtin_class_sizes"`,
    builtin_offsets: []ApiBuiltinClassMemberOffsets `json:"builtin_class_member_offsets"`,
    constants:       []ApiGlobalConstant `json:"global_constants"`,
    enums:           []ApiEnum `json:"global_enums"`,
    util_functions:  []ApiUtilityFunction `json:"utility_functions"`,
    builtin_classes: []ApiBuiltinClass `json:"builtin_classes"`,
    classes:         []ApiClass `json:"classes"`,
    singletons:      []ApiSingleton `json:"singletons"`,
    native_structs:  []ApiNativeStructure `json:"native_structures"`,
}

ApiVersion :: struct {
    major:     uint `json:"version_major"`,
    minor:     uint `json:"version_minor"`,
    patch:     uint `json:"version_patch"`,
    status:    string `json:"version_status"`,
    build:     string `json:"version_build"`,
    full_name: string `json:"version_full_name"`,
}

ApiBuiltinClassSizes :: struct {
    configuration: string `json:"build_configuration"`,
    sizes:         []ApiTypeSize,
}

ApiTypeSize :: struct {
    name: string,
    size: uint,
}

ApiBuiltinClassMemberOffsets :: struct {
    configuration: string `json:"build_configuration"`,
    classes:       []ApiMemberOffsetClass `json:"classes"`,
}

ApiMemberOffsetClass :: struct {
    name:    string `json:"name"`,
    members: []ApiMemberOffset `json:"members"`,
}

ApiMemberOffset :: struct {
    member: string `json:"member"`,
    offset: uint `json:"offset"`,
    meta:   string `json:"meta"`,
}

ApiGlobalConstant :: struct {}

ApiEnum :: struct {
    name:        string `json:"name"`,
    is_bitfield: bool `json:"is_bitfield"`,
    values:      []ApiEnumValue `json:"values"`,
}

ApiEnumValue :: struct {
    name:  string `json:"name"`,
    value: int `json:"value"`,
}

ApiUtilityFunction :: struct {
    name:        string `json:"name"`,
    return_type: Maybe(string) `json:"return_type"`,
    category:    string `json:"category"`,
    is_vararg:   bool `json:"is_vararg"`,
    hash:        i64 `json:"hash"`,
    arguments:   []ApiFunctionArgument `json:"arguments"`,
}

ApiFunctionArgument :: struct {
    name:          string `json:"name"`,
    type:          string `json:"type"`,
    default_value: Maybe(string) `json:"default_value"`,
}

ApiBuiltinClass :: struct {
    name:           string `json:"name"`,
    is_keyed:       bool `json:"is_keyed"`,
    has_destructor: bool `json:"has_destructor"`,
    operators:      []ApiClassOperator `json:"operators"`,
    enums:          []ApiEnum `json:"enums"`,
    methods:        []ApiBuiltinClassMethod `json:"methods"`,
    constructors:   []ApiClassConstructor `json:"constructors"`,
}

ApiClassOperator :: struct {
    name:        string `json:"name"`,
    right_type:  Maybe(string) `json:"right_type"`,
    return_type: string `json:"return_type"`,
}

ApiBuiltinClassMethod :: struct {
    name:        string `json:"string"`,
    return_type: Maybe(string) `json:"return_type"`,
    is_vararg:   bool `json:"is_vararg"`,
    is_const:    bool `json:"is_const"`,
    is_static:   bool `json:"is_static"`,
    hash:        i64 `json:"hash"`,
    arguments:   []ApiFunctionArgument `json:"arguments"`,
}

ApiClassConstructor :: struct {
    index:     u64 `json:"index"`,
    arguments: []ApiFunctionArgument `json:"arguments"`,
}

ApiClass :: struct {
    name:            string `json:"name"`,
    is_refcounted:   bool `json:"is_refcounted"`,
    is_instantiable: bool `json:"is_instantiable"`,
    inherits:        string `json:"inherits"`,
    api_type:        string `json:"api_type"`,
    enums:           []ApiEnum `json:"enums"`,
    constants:       []ApiConstant `json:"constants"`,
    methods:         []ApiClassMethod `json:"methods"`,
    signals:         []ApiClassSignal `json:"signals"`,
    operators:       []ApiClassOperator `json:"operators"`,
    properties:      []ApiClassProperty `json:"properties"`,
}

ApiConstant :: struct {
    name:  string `json:"name"`,
    value: int `json:"value"`,
}

ApiClassSignal :: struct {
    name: string `json:"name"`,
    arguments: []ApiClassSignalArgument `json:"arguments"`
}

ApiClassSignalArgument :: struct {
    name: string `json:"name"`,
    type: string `json:"type"`,
}

ApiClassProperty :: struct {
    type:   string `json:"type"`,
    name:   string `json:"name"`,
    setter: string `json:"setter"`,
    getter: string `json:"getter"`,
}

ApiClassMethod :: struct {
    name:         string `json:"string"`,
    is_vararg:    bool `json:"is_vararg"`,
    is_const:     bool `json:"is_const"`,
    is_static:    bool `json:"is_static"`,
    is_virtual:   bool `json:"is_virtual"`,
    hash:         i64 `json:"hash"`,
    return_value: Maybe(ApiClassMethodReturnValue) `json:"return_value"`,
    arguments:    []ApiClassMethodArguments `json:"arguments"`,
}

ApiClassMethodReturnValue :: struct {
    type: string `json:"type"`,
    meta: Maybe(string) `json:"meta"`,
}

ApiClassMethodArguments :: struct {
    name:          string `json:"name"`,
    type:          string `json:"type"`,
    meta:          Maybe(string) `json:"meta"`,
    default_value: Maybe(string) `json:"default_value"`,
}

ApiSingleton :: struct {
    name: string `json:"name"`,
    type: string `json:"type"`,
}

ApiNativeStructure :: struct {
    name:   string `json:"name"`,
    format: string `json:"format"`,
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

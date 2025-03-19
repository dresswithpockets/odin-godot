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

Bit_Field :: struct {
    name:   string,
    values: []Enum_Value,
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

/*
    Copyright 2025 Dresses Digital

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

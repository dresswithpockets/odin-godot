package bindgen

import "core:encoding/json"
import "core:fmt"
import "core:os"

Options :: struct {
    api_file: string,
}

default_options :: proc() -> Options {
    return Options{""}
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

main :: proc() {
    options := default_options()

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

    state := create_state(options, api)
    generate_bindings(state)

    // since we wanna keep state around until the end of the program's lifetime,
    // no need to be particular about freeing the bits and pieces of the struct (:
    free_all()
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

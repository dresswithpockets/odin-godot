package bindgen

import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:time"
import g "graph"
import "views"

Options :: struct {
    api_file:  string,
    job_count: int,
    map_mode:  views.Package_Map_Mode,
}

default_options :: proc() -> Options {
    return Options{api_file = "", job_count = 0, map_mode = .Nested}
}

print_usage :: proc() {
    fmt.println("bindgen generates Odin bindings from godot's extension_api.json")
    fmt.println("Usage:")
    fmt.println("\tbindgen api_json_path [options]")
    fmt.println("Options:")
    fmt.println("\t-jobs:<count>")
    fmt.println("\t\tThe number of threads to use when building the bindings.")
    fmt.println("\t\tDefaults to the number of logical CPU cores available.")
}

parse_args :: proc(options: ^Options) -> (ok: bool) {
    ok = true
    options.api_file = os.args[1]
    if len(os.args) > 1 {
        for i := 2; i < len(os.args); i += 1 {
            arg := os.args[i]
            if strings.contains_rune(arg, ':') {
                if strings.has_prefix(arg, "-jobs:") {
                    if len(arg) < 7 {
                        fmt.eprintln("Value missing for arg '-jobs'")
                        ok = false
                        continue
                    }

                    right := arg[6:]
                    if result, ok := strconv.parse_int(right); ok {
                        if result < 0 {
                            fmt.eprintln("Job count must be at least 0")
                            ok = false
                            continue
                        }
                        options.job_count = result
                    } else {
                        fmt.eprintfln("Expected an integer for job count, but got '%v' instead", right)
                        ok = false
                        continue
                    }

                    continue
                }
            }
            // we don't yet have any options which are just flags
            fmt.eprintfln("Invalid option: %v", arg)
            ok = false
        }
    }

    if options.job_count == 0 {
        options.job_count = num_processors()
    }
    return
}

load_api :: proc(options: Options) -> (api: ^g.Api, ok: bool) {
    data := os.read_entire_file(options.api_file) or_return
    defer delete(data)

    api = new(g.Api)
    err := json.unmarshal(data, api)
    ok = err == nil
    return
}

main :: proc() {
    options := default_options()

    if len(os.args) < 2 {
        print_usage()
        os.exit(1)
    }

    if ok := parse_args(&options); !ok {
        os.exit(1)
    }

    fmt.printfln("Parsing API: %v", options.api_file)
    api, ok := load_api(options)
    if !ok {
        fmt.println("There was an error loading the api from the file.")
        os.exit(1)
    }

    graph: g.Graph

    fmt.println("Running Pass: Init")
    g.graph_init(&graph, api, context.allocator)

    fmt.println("Running Pass: Map")
    g.graph_type_info_pass(&graph, api)
    g.graph_builtins_structure_pass(&graph, api)

    fmt.println("Running Pass: TDG")
    g.graph_relationship_pass(&graph, api)

    fmt.printfln("Running Codegen (%v)", api.version.full_name)
    generate_bindings(graph, options)

    // since we wanna keep state around until the end of the program's lifetime,
    // no need to be particular about freeing the bits and pieces of the struct (:
    free_all()
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

package bindgen

import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:time"
import g "graph"

Options :: struct {
    api_file:  string,
    job_count: int,
}

default_options :: proc() -> Options {
    return Options{"", 0}
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
                        if result < 1 {
                            fmt.eprintln("Job count must be at least 1")
                            ok = false
                            continue
                        }
                        options.job_count = result
                    } else {
                        fmt.eprintf("Expected an integer for job count, but got '%v' instead\n", right)
                        ok = false
                        continue
                    }

                    continue
                }
            }
            // we don't yet have any options which are just flags
            fmt.eprintf("Invalid option: %v", arg)
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

    fmt.printf("Parsing API Spec from %v.\n", options.api_file)
    api, ok := load_api(options)
    if !ok {
        fmt.println("There was an error loading the api from the file.")
        os.exit(1)
    }

    graph: g.Graph
    g.graph_init(&graph, api, context.allocator)

    fmt.printf("Generating API for %v, with up to %v threads.\n", api.version.full_name, options.job_count)
    generate_bindings(graph, options)

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

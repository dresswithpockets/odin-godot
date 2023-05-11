package godin

import "core:fmt"
import "core:os"

help_base :: #load("help.md", string)
help_build :: #load("help.build.md", string)
help_syntax :: #load("help.syntax.md", string)

help_docs := map[string]string {
    "build"  = help_build,
    "syntax" = help_syntax,
}

main :: proc() {

    if len(os.args) <= 1 {
        fmt.println(help_base)
        return
    }

    command := os.args[1]
    switch command {
    case "build":
        cmd_build()
    case "syntax":
        fmt.println(help_syntax)
    case "help":
        {
            if len(os.args) == 2 {
                fmt.println(help_base)
                return
            }

            help_target := os.args[2]
            if help_doc, ok := help_docs[help_target]; ok {
                fmt.println(help_doc)
                return
            }

            fmt.println(help_base)
        }
    case:
        {
            if help_doc, ok := help_docs[command]; ok {
                fmt.println(help_doc)
                return
            }

            fmt.println(help_base)
        }
    }
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

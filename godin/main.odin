package godin

import "core:fmt"
import "core:os"
import "core:strings"

help_base :: #load("help.md", string)
help_build :: #load("help.build.md", string)
help_syntax :: #load("help.syntax.md", string)

help_docs := map[string]string {
    "build" = help_build,
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

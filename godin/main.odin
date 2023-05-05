package godin
/*
Usage:
    godin class <package name> <class name> [inherits]

Parameters:

    class name - the PascalCase class name to use for code generation

    inherits - an inheritance expression
*/

import "core:fmt"
import "core:os"

class_help ::
    ""

base_help ::
    "godin is a tool to aid Godot dev with Odin\n" +
    "Usage:\n" +
    "    godin <command|topic> [args...]\n" +
    "\n" +
    "Commands:\n" +
    "    class - generates Odin code to create and register an Extension Class\n" +
    "\n" +
    "Topics:\n" +
    "    inherits - special syntax for describing inheritance\n" +
    "\n" +
    "For more information about a command or a topic, invoke help command:\n" +
    "    e.g. `godin help class` or `godin help inherits`\n" +
    "\n" +
    "You may also just invoke the topic on its own to see its help:\n" +
    "    e.g. `godin inherits`\n"

help_targets := map[string]string{
    "class" = class_help,
}

cmd_help :: proc() {
    if len(os.args) == 2 {
        fmt.println(base_help)
        return
    }

    help_target := os.args[2]
    if help_target not_in help_targets {
        
    }
}

cmd_class :: proc() {

}

main :: proc() {
    if len(os.args) <= 1 {
        fmt.println(base_help)
        return
    }

    command := os.args[1]
    switch command {
        case "class":
            cmd_class()
        case "help":
            cmd_help()
            return
    }
}

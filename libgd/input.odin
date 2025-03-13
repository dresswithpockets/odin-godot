package libgd

import "godot:core/input"
import core "../core"
import var "../variant"

get_input_vector :: proc "contextless" (negative_x: cstring, positive_x: cstring, negative_y: cstring, positive_y: cstring, static: bool) -> var.Vector2 {
    negative_x_name := var.new_string_name(negative_x, static)
    defer if !static {
        var.free_string_name(negative_x_name)
    }

    positive_x_name := var.new_string_name(positive_x, static)
    defer if !static {
        var.free_string_name(positive_x_name)
    }

    negative_y_name := var.new_string_name(negative_y, static)
    defer if !static {
        var.free_string_name(negative_y_name)
    }

    positive_y_name := var.new_string_name(positive_y, static)
    defer if !static {
        var.free_string_name(positive_y_name)
    }

    return input.get_vector(core.singleton_input(), negative_x_name, positive_x_name, negative_y_name, positive_y_name, -1.0)
}
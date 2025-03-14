package libgd

import "godot:godot"

get_input_vector :: proc "contextless" (negative_x: cstring, positive_x: cstring, negative_y: cstring, positive_y: cstring, static: bool) -> godot.Vector2 {
    negative_x_name := godot.new_string_name(negative_x, static)
    defer if !static {
        godot.free_string_name(negative_x_name)
    }

    positive_x_name := godot.new_string_name(positive_x, static)
    defer if !static {
        godot.free_string_name(positive_x_name)
    }

    negative_y_name := godot.new_string_name(negative_y, static)
    defer if !static {
        godot.free_string_name(negative_y_name)
    }

    positive_y_name := godot.new_string_name(positive_y, static)
    defer if !static {
        godot.free_string_name(positive_y_name)
    }

    return godot.input_get_vector(godot.singleton_input(), negative_x_name, positive_x_name, negative_y_name, positive_y_name, -1.0)
}

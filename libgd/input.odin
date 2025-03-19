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

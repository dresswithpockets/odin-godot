package godin

import "core:os"
import "core:fmt"
import "core:strings"
import scan "core:text/scanner"
import "core:io"

cmd_build :: proc() {
    if len(os.args) < 3 {
        fmt.println(help_build)
        return
    }

    options, ok := parse_build_args(os.args[2:])
    defer clean_build_options(&options)
    if !ok {
        return
    }

    state := State{
        classes = make(map[string]StateClass)
    }
    build_state(&state, options)

    gen_backend(state, options)

    delete(state.classes)
}

/*
class_template

This is a template string that expects the following format parameters, 
in the order given:

 0: package_name
 1: godot_import_path
 2: class_godot_name
 3: class_parent_name
 4: class_snake_name
 5: class_struct_name

 6:  set_func                 = {4:s}_set_bind
 7:  get_func                 = {4:s}_get_bind
 8:  get_property_list_func   = {4:s}_get_property_list_bind
 9:  free_property_list_func  = {4:s}_free_property_list_bind
 10: property_can_revert_func = {4:s}_property_can_revert_bind
 11: property_get_revert_func = {4:s}_property_get_revert_bind
 12: notification_func        = {4:s}_notification_bind
*/
class_template :: #load("templates/class.odin.template", string)

// TODO: turns out the template is only nice when the output isnt conditional, so lets use live formatting (:

template_format_class :: proc(
    package_name, godot_import_path, class_godot_name, class_parent_name, class_snake_name, class_struct_name: string,
    has_set_func, has_get_func, has_get_property_list_func, has_property_can_revert_func, has_notification_func: bool,
) -> string {
    sb := strings.Builder{}
    strings.builder_init(&sb)
    defer strings.builder_destroy(&sb)

    set_func := "nil"
    get_func := "nil"
    get_property_list_func := "nil"
    free_property_list_func := "nil"
    property_can_revert_func := "nil"
    property_get_revert_func := "nil"
    notification_func := "nil"

    if has_set_func {
        set_func = strings.concatenate({class_snake_name, "_set_bind"})
    }

    if has_get_func {
        get_func = strings.concatenate({class_snake_name, "_get_bind"})
    }

    if has_get_property_list_func {
        get_property_list_func = strings.concatenate({class_snake_name, "_get_property_list_bind"})
        free_property_list_func = strings.concatenate({class_snake_name, "_free_property_list_bind"})
    }

    if has_property_can_revert_func {
        property_can_revert_func = strings.concatenate({class_snake_name, "_property_can_revert_bind"})
        property_get_revert_func = strings.concatenate({class_snake_name, "_property_get_revert_bind"})
    }

    if has_notification_func {
        notification_func = strings.concatenate({class_snake_name, "_notification_bind"})
    }

    fmt.sbprintf(
        &sb,
        class_template,

        package_name,
        godot_import_path,
        class_godot_name,
        class_parent_name,
        class_snake_name,
        class_struct_name,

        set_func,
        get_func,
        get_property_list_func,
        free_property_list_func,
        property_can_revert_func,
        property_get_revert_func,
        notification_func,
    )

    if has_set_func {
        delete(set_func)
    }

    if has_get_func {
        delete(get_func)
    }

    if has_get_property_list_func {
        delete(get_property_list_func)
        delete(free_property_list_func)
    }

    if has_property_can_revert_func {
        delete(property_can_revert_func)
        delete(property_get_revert_func)
    }

    if has_notification_func {
        delete(notification_func)
    }

    return strings.clone(strings.to_string(sb))
}

gen_backend :: proc(state: State, options: BuildOptions) {
    for _, class in state.classes {
        fmt.printf(
            "Found StateClass '%v', extends '%v', backend path: '%v'.\n",
            class.name,
            class.extends,
            class.out_file,
        )

        out_file_handle, err := os.open(class.out_file, os.O_CREATE | os.O_TRUNC | os.O_RDWR)
        if err != 0 {
            print_err(err, class.out_file)
            return
        }

        // streams take ownership of the handle, so we dont need to close the handle ourselves
        stream := os.stream_from_handle(out_file_handle)
        defer io.destroy(stream)

        writer, ok := io.to_writer(stream)
        if !ok {
            fmt.printf("There was an error opening a writer on the file: %v\n", class.out_file)
            return
        }

        fmt.println("Package name: ", class.source.package_name)

        sb := strings.Builder{}
        strings.builder_init(&sb)
        defer strings.builder_destroy(&sb)

        class_snake_name := odin_to_snake_case(class.name)
        defer delete(class_snake_name)

        class_backend := template_format_class(
            class.source.package_name,
            options.godot_import_prefix,
            class.name,
            class.extends,
            class_snake_name,
            class.odin_struct_name,
            false,
            false,
            false,
            false,
            false,
        )
        defer delete(class_backend)

        io.write_string(writer, class_backend)

        // TODO: import dependent packages (i.e other generated classes)

        io.write_string(writer, strings.to_string(sb))
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

package views

import "core:fmt"
import "core:strings"
import "core:unicode"
import "core:unicode/utf8"

// godot uses ACRONYMPascalCase, but we use AcronymPascalCase
// return string must be freed
godot_to_odin_case :: proc(name: string) -> (s: string) {
    assert(len(name) > 0)

    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    runes := utf8.string_to_runes(name)
    defer delete(runes)

    fmt.sbprint(&sb, unicode.to_upper(runes[0]))
    for i := 1; i < len(runes) - 1; i += 1 {
        r := runes[i]
        previous := runes[i - 1]
        next := runes[i + 1]
        if r == '.' {
            fmt.sbprint(&sb, '_')
            continue
        }
        if unicode.is_upper(r) &&
           (unicode.is_upper(previous) || unicode.is_number(previous)) &&
           unicode.is_upper(next) {
            fmt.sbprint(&sb, unicode.to_lower(r))
            continue
        }

        fmt.sbprint(&sb, r)
    }
    // always push the last rune as lower
    if len(runes) > 1 {
        fmt.sbprint(&sb, unicode.to_lower(runes[len(runes) - 1]))
    }

    s = strings.clone(strings.to_string(sb))
    return
}

godot_to_snake_case :: proc(name: string) -> (s: string) {
    // lol (:
    s = odin_to_snake_case(godot_to_odin_case(name))
    return
}

odin_to_snake_case :: proc(name: string) -> (s: string) {
    assert(len(name) > 0)

    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    runes := utf8.string_to_runes(name)
    defer delete(runes)

    fmt.sbprint(&sb, unicode.to_lower(runes[0]))
    for i := 1; i < len(runes); i += 1 {
        r := runes[i]
        if unicode.is_alpha(r) && unicode.is_upper(r) {
            fmt.sbprint(&sb, "_")
            fmt.sbprint(&sb, unicode.to_lower(r))
            continue
        }

        fmt.sbprint(&sb, unicode.to_lower(r))
    }

    s = strings.clone(strings.to_string(sb))
    return
}

odin_to_const_case :: proc(name: string) -> (s: string) {
    assert(len(name) > 0)

    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    runes := utf8.string_to_runes(name)
    defer delete(runes)

    fmt.sbprint(&sb, runes[0])
    for i := 1; i < len(runes); i += 1 {
        r := runes[i]
        if unicode.is_alpha(r) && unicode.is_upper(r) {
            fmt.sbprint(&sb, "_")
            fmt.sbprint(&sb, r)
            continue
        }

        fmt.sbprint(&sb, unicode.to_upper(r))
    }

    s = strings.clone(strings.to_string(sb))
    return
}

const_to_odin_case :: proc(name: string) -> (s: string) {
    assert(len(name) > 0)

    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    runes := utf8.string_to_runes(name)
    defer delete(runes)

    if unicode.is_number(runes[0]) {
        fmt.sbprint(&sb, "_")
    }

    fmt.sbprint(&sb, runes[0])
    for i := 1; i < len(runes); i += 1 {
        r := runes[i]
        if r == '_' {
            continue
        }

        previous := runes[i - 1]
        if previous == '_' {
            fmt.sbprint(&sb, r)
            continue
        }

        fmt.sbprint(&sb, unicode.to_lower(r))
    }

    s = strings.clone(strings.to_string(sb))
    return
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

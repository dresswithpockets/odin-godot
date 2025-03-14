package names

import "core:fmt"
import "core:strings"
import "core:unicode"
import "core:unicode/utf8"

// ACRONYMPascalCase
Godot_Name :: distinct string

// Acronym_Ada_Case
Odin_Name :: distinct string

// CONST_CASE
Const_Name :: distinct string

// snake_case
Snake_Name :: distinct string

to_odin :: proc {
    godot_to_odin,
    const_to_odin,
    snake_to_odin,
}

to_snake :: proc {
    odin_to_snake,
    godot_to_snake,
}

to_const :: proc {
    godot_to_const,
    odin_to_const,
}

// godot uses ACRONYMPascalCase, but we use AcronymPascalCase
// return string must be freed
godot_to_odin :: proc(name: Godot_Name) -> (s: Odin_Name) {
    assert(len(name) > 0)

    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    runes := utf8.string_to_runes(cast(string)name)
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

        // we're at a new word, prefix with underscore; but, only if it isnt already
        // prefixed by an underscore, due to a dot
        if unicode.is_upper(r) && !unicode.is_upper(next) && previous != '.' {
            fmt.sbprint(&sb, '_')
            fmt.sbprint(&sb, r)
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

    s = cast(Odin_Name)strings.clone(strings.to_string(sb))
    return
}

godot_to_snake :: proc(name: Godot_Name) -> (s: Snake_Name) {
    // lol (:
    s = odin_to_snake(godot_to_odin(name))
    return
}

odin_to_snake :: proc(name: Odin_Name) -> (s: Snake_Name) {
    assert(len(name) > 0)

    return cast(Snake_Name)strings.to_lower(cast(string)name)
}

// ACROYNM0ACRONYMNormalWord to ACRONYM0ACRONYM_NORMAL_WORD
godot_to_const :: proc(name: Godot_Name) -> (s: Const_Name) {
    assert(len(name) > 0)

    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    runes := utf8.string_to_runes(cast(string)name)
    defer delete(runes)

    in_acronym := false

    for i := 0; i < len(runes) - 1; i += 1 {
        r := runes[i]
        peek := runes[i + 1]
        if i > 0 {
            if !unicode.is_digit(r) && unicode.is_upper(r) && unicode.is_lower(peek) {
                fmt.sbprint(&sb, '_')
                fmt.sbprint(&sb, r)
                in_acronym = false
                continue
            }

            if !in_acronym && unicode.is_upper(peek) {
                if unicode.is_digit(r) {
                    fmt.sbprint(&sb, r)
                    in_acronym = true
                    continue
                } else if unicode.is_upper(r) {
                    fmt.sbprint(&sb, '_')
                    fmt.sbprint(&sb, r)
                    in_acronym = true
                    continue
                }
            }
        }

        fmt.sbprint(&sb, unicode.to_upper(r))
    }

    fmt.sbprint(&sb, unicode.to_upper(runes[len(runes) - 1]))
    s = cast(Const_Name)strings.clone(strings.to_string(sb))
    return
}

// Ada_Case to CONST_CASE
// Acroynm3dAcronym_More_Words becomes ACRONYM3DACRONYM_MORE_WORDS
odin_to_const :: proc(name: Odin_Name) -> (s: Const_Name) {
    assert(len(name) > 0)
    return cast(Const_Name)strings.to_upper(cast(string)name)
}

// CONST_CASE to Ada_Case
// ACRONYM3DACRONYM_MORE_WORDS becomes Acroynm3dAcronym_More_Words
const_to_odin :: proc(name: Const_Name) -> (s: Odin_Name) {
    assert(len(name) > 0)

    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    runes := utf8.string_to_runes(cast(string)name)
    defer delete(runes)

    if unicode.is_number(runes[0]) {
        fmt.sbprint(&sb, "_")
    }

    fmt.sbprint(&sb, runes[0])
    for i := 1; i < len(runes); i += 1 {
        r := runes[i]

        previous := runes[i - 1]
        if previous == '_' {
            fmt.sbprint(&sb, r)
            continue
        }

        fmt.sbprint(&sb, unicode.to_lower(r))
    }

    s = cast(Odin_Name)strings.clone(strings.to_string(sb))
    return
}

snake_to_odin :: proc(name: Snake_Name) -> (s: Odin_Name) {
    assert(len(name) > 0)

    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)

    runes := utf8.string_to_runes(cast(string)name)
    defer delete(runes)

    fmt.sbprint(&sb, unicode.to_upper(runes[0]))
    for i := 1; i < len(runes); i += 1 {
        r := runes[i]
        previous := runes[i - 1]
        if r == '.' {
            fmt.sbprint(&sb, '_')
            continue
        }

        // we're at a new word, print upper case
        if previous == '_' && r != '_' {
            fmt.sbprint(&sb, unicode.to_upper(r))
            continue
        }

        fmt.sbprint(&sb, r)
    }

    s = cast(Odin_Name)strings.clone(strings.to_string(sb))
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

package godin

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

package variant

import gd "../gdextension"
import "core:mem"
import "core:strings"

@(private)
EmptyString := String{}

@(private)
EmptyStringName := String_Name{}

string_empty :: proc "contextless" () -> String {
    return EmptyString
}

string_name_empty :: proc "contextless" () -> String_Name {
    return EmptyStringName
}

string_empty_ref :: proc "contextless" () -> ^String {
    return &EmptyString
}

string_name_empty_ref :: proc "contextless" () -> ^String_Name {
    return &EmptyStringName
}

/*
Clones a UTF8 Odin string into a Godot String

Inputs:
- from: The string to be cloned

Returns:
- res: A cloned Godot String
*/
new_string_odin :: proc "contextless" (from: string) -> (ret: String) {
    ret = String{}

    // N.B. we're transmuting the odin string into a cstring regardless of if it has a terminating null
    // byte or not. `string_new_with_utf8_chars_and_len2` takes a length, so we don't depend on the
    // terminating null byte.
    as_cstring := cast(cstring)(transmute(mem.Raw_String)from).data
    gd.string_new_with_utf8_chars_and_len2(&ret, as_cstring, cast(i64)len(from))
    return
}

/*
Clones a UTF8 cstring into a Godot String

Inputs:
- from: The cstring to be cloned. Must be null-terminated.

Returns:
- res: A cloned Godot String
*/
new_string_cstring :: proc "contextless" (from: cstring) -> (ret: String) {
    ret = String{}
    gd.string_new_with_utf8_chars(&ret, from)
    return
}

/*
Clones a UTF8 Odin string into a Godot String_Name

Inputs:
- from: The string to be cloned

Returns:
- res: A cloned Godot String_Name
*/
new_string_name_odin :: proc "contextless" (from: string) -> (ret: String_Name) {
    ret = String_Name{}

    // N.B. we're transmuting the odin string into a cstring regardless of if it has a terminating null
    // byte or not. `string_new_with_utf8_chars_and_len2` takes a length, so we don't depend on the
    // terminating null byte.
    as_cstring := cast(cstring)(transmute(mem.Raw_String)from).data
    gd.string_name_new_with_utf8_chars_and_len(&ret, as_cstring, cast(i64)len(from))
    return
}

/*
Clones a UTF8 cstring into a Godot String_Name

Inputs:
- from: The cstring to be cloned. Must be null-terminated.

Returns:
- res: A cloned Godot String_Name
*/
new_string_name_cstring :: proc "contextless" (from: cstring, static: bool) -> (ret: String_Name) {
    ret = String_Name{}
    gd.string_name_new_with_utf8_chars(&ret, from)
    return
}


new_node_path_cstring :: proc "contextless" (from: cstring) -> Node_Path {
    str: String
    gd.string_new_with_utf8_chars(&str, from)
    return new_node_path_string(str)
}

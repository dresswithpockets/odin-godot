#+private
package godin

// taken from core:os

is_path_separator :: proc(c: byte) -> bool {
    return c == '/' || c == '\\'
}

is_abs_path :: proc(path: string) -> bool {
    if len(path) > 0 && path[0] == '/' {
        return true
    }
    when ODIN_OS == .Windows {
        if len(path) > 2 {
            switch path[0] {
            case 'A' ..= 'Z', 'a' ..= 'z':
                return path[1] == ':' && is_path_separator(path[2])
            }
        }
    }
    return false
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

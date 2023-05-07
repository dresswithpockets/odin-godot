//+private
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
			case 'A'..='Z', 'a'..='z':
				return path[1] == ':' && is_path_separator(path[2])
			}
		}
	}
	return false
}

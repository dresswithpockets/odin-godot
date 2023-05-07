package godin

import "core:os"
import "core:fmt"
import "core:strings"

BuildOptions :: struct {
    target_path: string,
    allow_single_file: bool,
    backend_suffix: string,

    target_path_handle: os.Handle,
    target_files: [dynamic]os.Handle,
}

setup_build_options :: proc(options: ^BuildOptions) {
    // no default target_path
    options.allow_single_file = false
    options.backend_suffix = "_gde_backend.odin"

    options.target_files = make([dynamic]os.Handle)
}

clean_build_options :: proc(options: ^BuildOptions) {
    if options.target_path_handle != os.INVALID_HANDLE {
        os.close(options.target_path_handle)
    }
    delete(options.target_files)
}

parse_build_args :: proc(args: []string) -> (options: BuildOptions, success: bool) {
    success = false

    setup_build_options(&options)

    // first arg is always a file or folder path
    options.target_path = os.args[0]

    // the rest are options
    for i := 1; i < len(os.args); i += 1 {
        left_arg := os.args[i]
        right_arg : Maybe(string) = nil
        if strings.contains_rune(left_arg, ':') {
            split := strings.split_n(left_arg, ":", 2)
            defer delete(split)

            left_arg = split[0]
            right_arg = split[1]
        }

        switch left_arg {
            case "-file":
                options.allow_single_file = true
            case "-backend-suffix":
                right_val, ok := right_arg.(string)
                if !ok {
                    fmt.printf("Error: '-backend-suffix' was given without a value. Correct example usage: `-backend-suffix:_my_suffix.odin`.\n")
                    return
                }
                options.backend_suffix = right_val
        }
    }

    // verify the options are valid together
    // path must exist
    if !os.exists(options.target_path) {
        fmt.printf("Error: the path '%v' does not exist\n", options.target_path)
    }

    target_handle, err := os.open(options.target_path, os.O_RDWR)
    if err != 0 {
        print_err(err, options.target_path)
        return
    }

    options.target_path_handle = target_handle

    // target_path must be a file if -file is specified, otherwise
    // it must be a directory
    path_is_dir := os.is_dir(options.target_path)
    if options.allow_single_file {
        if path_is_dir {
            fmt.printf("Error: the path '%v' points to a directory, but '-file' was specified.\n", options.target_path)
            return
        }
    } else {
        if !path_is_dir {
            fmt.printf("Error: the path '%v' points to a directory, but '-file' was specified.\n", options.target_path)
            return
        }

        files, target_err := os.read_dir(target_handle, -1)
        if target_err != 0 {
            print_err(target_err, options.target_path)
            return
        }

        // store a list of every valid odin file, recursively
        _recurse_files :: proc(files: []os.File_Info, target_files: ^[dynamic]os.Handle) {
            directories := [dynamic]os.File_Info{}
            for file in files {
                if file.is_dir {
                    append(&directories, file)
                } else if strings.has_suffix(file.fullpath, ".odin") {
                    odin_file, odin_file_err := os.open(file.fullpath)
                    if odin_file_err != 0 {
                        print_err(odin_file_err, file.fullpath)
                        return
                    }
                    append(target_files, odin_file)
                }
            }

            for dir in directories {
                dir_handle, dir_err := os.open(dir.fullpath)
                if dir_err != 0 {
                    print_err(dir_err, dir.fullpath)
                    return
                }

                defer os.close(dir_handle)
                dir_files, dir_read_err := os.read_dir(dir_handle, -1)
                if dir_read_err != 0 {
                    print_err(dir_err, dir.fullpath)
                    return
                }

                _recurse_files(dir_files, target_files)
            }
        }

        _recurse_files(files, &options.target_files)
    }

    success = true
    return
}

cmd_build :: proc() {
    if len(os.args) < 4 {
        fmt.println(help_build)
        return
    }

    options, ok := parse_build_args(os.args[3:])
    defer clean_build_options(&options)
    if !ok {
        return
    }

    // TODO: iterate through every file and process (:
}

when ODIN_OS == .Windows {
    _err_map := map[os.Errno]string {
        os.ERROR_FILE_NOT_FOUND = "That file or directory couldn't be found.",
    }
} else {
    _err_map := map[os.Errno]string {}
}

print_err :: proc(err: os.Errno, file: string) {
    if err_string, ok := _err_map[err]; ok {
        fmt.println("Error opening '%v': %v", file, err_string)
        return
    }

    fmt.println("Unknown errno when opening '%v': %v", file, err)
}

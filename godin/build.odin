package godin

import "core:os"
import "core:fmt"
import "core:strings"
import scan "core:text/scanner"

State :: struct {
    classes: [dynamic]StateClass,
}

StateClass :: struct {
    name: string,
    extends: string,
    out_file: string,

    source: Source,
    odin_struct_name: string,
}

Source :: struct {
    file: os.File_Info,
    handle: os.Handle,
    line: int,
    col: int,
}

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

    state := State{}
    build_state(&state, options)

    gen_backend(state, options)
}

gen_backend :: proc(state: State, options: BuildOptions) {
    for class in state.classes {
        assert(class.out_file != nil, "Class out_file should never be nil in gen_backend")
        fmt.printf("Found StateClass '%v', extends '%v', backend path: '%v'.\n", class.name, class.extends, class.out_file)
        // TODO: write generated backend to out_file
    }

    unimplemented()
}

build_state :: proc(state: ^State, options: BuildOptions) {
    for file in options.target_files {
        file_info, err := os.fstat(file)
        assert(err == 0)

        fmt.printf("Parsing %v\n", file_info.fullpath)

        data, ok := os.read_entire_file(file)
        defer delete(data)
        assert(ok)

        contents := strings.clone_from_bytes(data)
        defer delete(contents)

        scanner := scan.Scanner{}
        scan.init(&scanner, contents, file_info.fullpath)

        // skip everything except for Comments
        scanner.flags -= {.Skip_Comments}
        scanner.error = scanner_error

        t := scan.scan(&scanner)
        for {
            for t != scan.Comment && t != scan.EOF {
                t = scan.scan(&scanner)
            }

            if t == scan.EOF {
                break
            }

            comment := scan.token_text(&scanner)
            comment = strings.trim_right_space(comment)
            if !strings.has_prefix(comment, "//+") {
                continue
            }

            decl := comment[3:]
            source := Source{
                col = 0,
                line = scanner.line - 1,
                file = file_info,
                handle = file,
            }
            add_state_from_decl(state, decl, source)

            t = scan.scan(&scanner)
        }
    }

    for class in &state.classes {
        out_file, out_file_ok := class.out_file.(string)
        if out_file_ok {
            if !is_abs_path(out_file) {
                base_path := strings.trim_suffix(class.source.file.fullpath, class.source.file.name)
                out_file = strings.concatenate([]string{base_path, out_file})
            }
        } else {
            out_file = strings.trim_suffix(class.source.file.fullpath, ".odin")
            out_file = strings.concatenate([]string{out_file, options.backend_suffix})
        }

        class.out_file = out_file
    }
}

scanner_error :: proc(s: ^scan.Scanner, msg: string) {
    fmt.println(msg)
}

scan_state_class :: proc(scanner: ^scan.Scanner) -> (class: StateClass, success: bool) {
    success = false

    tok := scan.scan(scanner)
    class.name = scan.token_text(scanner)

    if tok != scan.Ident {
        scan.errorf(scanner, "Expected a class name identifier in class declaration, got '%v' (%v) instead.", class.name, scan.token_string(tok))
        return
    }

    tok = scan.scan(scanner)
    extends := scan.token_text(scanner)

    if tok != scan.Ident || extends != "extends" {
        scan.errorf(scanner, "Expected an Ident, 'extends' in class declaration. Got '%v' (%v) instead.", extends, scan.token_string(tok))
        return
    }

    tok = scan.scan(scanner)
    class.extends = scan.token_text(scanner)

    if tok != scan.Ident {
        scan.errorf(scanner, "Expected a class name identifier in class 'extends' declaration, got '%v' (%v) instead.", class.extends, scan.token_string(tok))
        return
    }

    tok = scan.scan(scanner)
    if tok != scan.EOF {
        if tok != '@' {
            scan.errorf(scanner, "Unexpected '%v' at end of class declaration.", scan.token_string(tok))
            return
        }

        if scan.peek(scanner) == scan.EOF {
            scan.error(scanner, "Expected filename after @ in class declaration, got EOL instead.")
            return
        }

        class.out_file = scanner.src[scanner.pos.offset+1:]
        for tok != scan.EOF {
            tok = scan.scan(scanner)
        }
    }

    success = true
    return
}

add_state_from_decl :: proc(state: ^State, decl: string, source: Source) {
    scanner := scan.Scanner{}
    scan.init(&scanner, decl, source.file.fullpath)
    scanner.error = scanner_error
    
    tok := scan.scan(&scanner)
    if tok != scan.Ident {
        return
    }

    decl_type := scan.token_text(&scanner)
    switch decl_type {
        case "class":
            state_class, ok := scan_state_class(&scanner)
            if !ok {
                fmt.println("There were errors parsing.")
                return
            }
            state_class.source = source
            // verify that there is a struct definition after our class declaration
            {
                t := scan.scan(parent_scanner)
                text := scan.token_text(parent_scanner)
                if t != scan.Ident {
                    scan.errorf(parent_scanner, "Expected a Identifier for a struct declaration after class declaration, got '%v' instead.", )
                    return
                }

                state_class.odin_struct_name = text

                t_comp : rune = ':'
                t = scan.scan(parent_scanner)
                text = scan.token_text(parent_scanner)
                if t != ':' {
                    scan.errorf(parent_scanner, "Expected '::' in struct declaration, got '%v' (%v) instead.", text, cast(int)t)
                    return
                }

                t = scan.scan(parent_scanner)
                text = scan.token_text(parent_scanner)
                if t != ':' {
                    scan.errorf(parent_scanner, "Expected '::' in struct declaration, got '%v' (%v) instead.", text, cast(int)t)
                    return
                }

                t = scan.scan(parent_scanner)
                text = scan.token_text(parent_scanner)
                if t != scan.Ident || text != "struct" {
                    scan.errorf(parent_scanner, "Expected struct delcaration after class declaration, got '%v' instead..", text)
                    return
                }
            }

            append(&state.classes, state_class)
        case "static":
            unimplemented()
        case "method":
            unimplemented()
        case "property":
            unimplemented()
        case "enum":
            unimplemented()
        case "signal":
            unimplemented()
        case "group":
            unimplemented()
        case "subgroup":
            unimplemented()
        case "const":
            unimplemented()
    }
}

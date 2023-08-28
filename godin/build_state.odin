package godin

import "core:os"
import "core:fmt"
import "core:strings"
import scan "core:text/scanner"

import "core:odin/ast"
import "core:odin/parser"
import "core:odin/tokenizer"

State :: struct {
    classes: map[string]StateClass,
    methods: [dynamic]StateMethod,

    error_handler: parser.Error_Handler,
}

StateClass :: struct {
    name:             string,
    extends:          string,
    out_file:         string,
    odin_struct_name: string,
    source:           Source,
}

StateMethod :: struct {
    name:           string,
    is_static:      bool,
    class:          string,
    source:         Source,
    odin_proc_name: string,
}

Source :: struct {
    file:         os.File_Info,
    handle:       os.Handle,
    line:         int,
    col:          int,
    package_name: string,
}

Godin_Comment :: struct {
    is_godin:    bool,
    error_count: int,
    pos:         tokenizer.Pos,

    value:       Godin_Comment_Value,
}

Godin_Comment_Value :: union {
    Godin_Comment_Class,
}

Godin_Comment_Class :: struct {
    name:    string,
    extends: string,
}

Godin_Comment_Method :: struct {
    name:      string,
    is_static: bool,
    class:     string,
}

get_comment_source :: proc(root: ^ast.File, comment_group: ^ast.Comment_Group) -> string {
    return root.src[comment_group.pos.offset : comment_group.end.offset]
}

parse_godin_comment :: proc(comment: string) -> (godin_comment: ^Godin_Comment, ok: bool) {
    godin_comment = new(Godin_Comment)

    unimplemented()

    // ok = true
    // return
}

build_state :: proc(state: ^State, options: BuildOptions) {
    for file_handle in options.target_files {
        file_info, err := os.fstat(file_handle)
        assert(err == 0)

        fmt.printf("Parsing %v\n", file_info.fullpath)

        data, ok := os.read_entire_file(file_handle)
        defer delete(data)
        assert(ok, "Error reading file.")

        ast_parser := parser.Parser{
            flags = {parser.Flag.Optional_Semicolons},
            err = state.error_handler,
        }

        ast_file := ast.File{
            src = string(data),
            fullpath = file_info.fullpath,
        }

        ok = parser.parse_file(&ast_parser, &ast_file)
        assert(ok, "Error parsing file.")
        assert(ast_parser.error_count == 0, "There were errors parsing the file.")

        root := ast_parser.file

        // godin comments have special meaning; we build State from godin comments on types,
        // methods, etc. The key is the line number of the end of the comment group, which we
        // will use to match with type/proc declarations.
        comments := make(map[int]^Godin_Comment)
        for comment in root.comments {
            comment_source := get_comment_source(root, comment)
            fmt.printf("Comment: %s\n", comment_source)
            godin_comment, ok := parse_godin_comment(comment_source)
            assert(ok, "Error parsing comment.")

            if godin_comment.is_godin {
                comments[comment.end.line] = godin_comment
            }

            assert(godin_comment.error_count == 0, "There were errors parsing the godin comment.")
        }

        for stmt, index in root.decls {
            if decl, ok := stmt.derived.(^ast.Value_Decl); ok {
                godin_comment, comment_exists := comments[decl.pos.line - 1]

                // if there isnt a godin attribute prepended to the declaration, then we can just 
                // ignore the declaration.
                if !comment_exists do continue

                #partial switch v in decl.values[0].derived {
                    case ^ast.Struct_Type:
                        // TODO: state_class, ok := parse_state_class(state, v, godin_comment)
                        // TODO: assert(ok, "There were errors parsing ")
                        unimplemented()
                    case ^ast.Proc_Lit:
                        unimplemented()
                    case ^ast.Enum_Type:
                        unimplemented()
                }
            }
        }
    }

    for _, class in &state.classes {
        class.out_file = strings.trim_suffix(class.source.file.fullpath, ".odin")
        class.out_file = strings.concatenate([]string{class.out_file, options.backend_suffix})
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
        scan.errorf(
            scanner,
            "Expected a class name identifier in class declaration, got '%v' (%v) instead.",
            class.name,
            scan.token_string(tok),
        )
        return
    }

    class.name = strings.clone(class.name)

    tok = scan.scan(scanner)
    extends := scan.token_text(scanner)
    if tok != scan.Ident || extends != "extends" {
        scan.errorf(
            scanner,
            "Expected an Ident, 'extends' in class declaration. Got '%v' (%v) instead.",
            extends,
            scan.token_string(tok),
        )
        return
    }

    tok = scan.scan(scanner)
    class.extends = scan.token_text(scanner)

    if tok != scan.Ident {
        scan.errorf(
            scanner,
            "Expected a class name identifier in class 'extends' declaration, got '%v' (%v) instead.",
            class.extends,
            scan.token_string(tok),
        )
        return
    }

    class.extends = strings.clone(class.extends)

    success = true
    return
}

ensure_struct_follows_class :: proc(parent_scanner: ^scan.Scanner, state_class: ^StateClass) -> bool {
    t := scan.scan(parent_scanner)
    text := scan.token_text(parent_scanner)
    if t != scan.Ident {
        scan.errorf(
            parent_scanner,
            "Expected a Identifier for a struct declaration after class declaration, got '%v' instead.",
        )
        return false
    }

    state_class.odin_struct_name = text

    t_comp: rune = ':'
    t = scan.scan(parent_scanner)
    text = scan.token_text(parent_scanner)
    if t != ':' {
        scan.errorf(
            parent_scanner,
            "Expected '::' in struct declaration, got '%v' (%v) instead.",
            text,
            cast(int)t,
        )
        return false
    }

    t = scan.scan(parent_scanner)
    text = scan.token_text(parent_scanner)
    if t != ':' {
        scan.errorf(
            parent_scanner,
            "Expected '::' in struct declaration, got '%v' (%v) instead.",
            text,
            cast(int)t,
        )
        return false
    }

    t = scan.scan(parent_scanner)
    text = scan.token_text(parent_scanner)
    if t != scan.Ident || text != "struct" {
        scan.errorf(
            parent_scanner,
            "Expected struct delcaration after class declaration, got '%v' instead..",
            text,
        )
        return false
    }
    return true
}

scan_state_method :: proc(scanner: ^scan.Scanner) -> (method: StateMethod, ok: bool) {
    unimplemented()
}

ensure_proc_follows_method :: proc(scanner: ^scan.Scanner, method: ^StateMethod) -> bool {
    unimplemented()
}

add_state_from_decl :: proc(state: ^State, decl: string, source: Source, parent_scanner: ^scan.Scanner) {
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
        class, ok := scan_state_class(&scanner)
        if !ok {
            fmt.println("There were errors parsing.")
            return
        }
        class.source = source
        // verify that there is a struct definition after our class declaration
        if !ensure_struct_follows_class(parent_scanner, &class) {
            return
        }

        state.classes[class.name] = class
    case "static":
        unimplemented()
    case "method":
        // TODO: support special method overriding
        method, ok := scan_state_method(&scanner)
        if !ok {
            fmt.println("There were errors parsing.")
            return
        }

        method.source = source
        if !ensure_proc_follows_method(parent_scanner, &method) {
            return
        }

        append(&state.methods, method)
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

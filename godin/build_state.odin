package godin

import "core:os"
import "core:fmt"
import "core:strings"
import scan "core:text/scanner"

import "core:odin/ast"
import "core:odin/parser"
import "core:odin/tokenizer"

GODIN_COMMENT_PREFIX :: "//+"
DEFAULT_BASE_CLASS :: "Node"

State :: struct {
    classes: map[string]StateClass,
    methods: [dynamic]StateMethod,

    error_handler: parser.Error_Handler,
}

StateClass :: struct {
    name:             string,
    extends:          string,
    odin_struct_name: string,
    source:           Source,
    out_file:         string,
}

StateMethod :: struct {
    name:           string,
    is_static:      bool,
    class:          string,
    odin_proc_name: string,
    source:         Source,
}

Source :: struct {
    file:         os.File_Info,
    pos:          tokenizer.Pos,
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
    extends: Maybe(string),
}

Godin_Comment_Method :: struct {
    name:      string,
    is_static: bool,
    class:     string,
}

get_comment_source :: proc(root: ^ast.File, comment_group: ^ast.Comment_Group) -> string {
    return root.src[comment_group.pos.offset : comment_group.end.offset]
}

parse_godin_comment_class :: proc(scanner: ^scan.Scanner) -> (comment_class: Godin_Comment_Class, success: bool) {
    success = false

    tok := scan.scan(scanner)
    comment_class.name = scan.token_text(scanner)
    if tok != scan.Ident {
        scan.errorf(
            scanner,
            "Expected a class name identifier in class declaration, got '%v' (%v) instead.",
            comment_class.name,
            scan.token_string(tok),
        )
        return
    }

    comment_class.name = strings.clone(comment_class.name)

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
    comment_class.extends = scan.token_text(scanner)

    if tok != scan.Ident {
        scan.errorf(
            scanner,
            "Expected a class name identifier in class 'extends' declaration, got '%v' (%v) instead.",
            comment_class.extends,
            scan.token_string(tok),
        )
        return
    }

    comment_class.extends = strings.clone(comment_class.extends.(string))

    success = true
    return
}

parse_godin_comment :: proc(comment: string, filepath: string) -> (godin_comment: ^Godin_Comment, success: bool) {
    godin_comment = new(Godin_Comment)

    scanner := scan.Scanner{}
    scan.init(&scanner, comment, filepath)
    scanner.error = scanner_error

    success = true
    tok := scan.scan(&scanner)
    if tok != scan.Ident {
        godin_comment.is_godin = false
        return
    }

    godin_comment.is_godin = true
    decl_type := scan.token_text(&scanner)
    switch decl_type {
    case "class":
        godin_comment.value, success = parse_godin_comment_class(&scanner)
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

    return
}

parse_state_class :: proc(state: ^State, value_decl: ^ast.Value_Decl, struct_type: ^ast.Struct_Type, godin_decl: ^Godin_Comment) -> (class: StateClass, success: bool) {
    comment_class, is_class := godin_decl.value.(Godin_Comment_Class)
    if !is_class {
        // TODO: properly report this error
        success = false
        return
    }
    class.odin_struct_name = value_decl.names[0].derived.(^ast.Ident).name
    class.name = comment_class.name
    class.extends = comment_class.extends.(string) or_else DEFAULT_BASE_CLASS

    success = true
    return
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
        for comment_group in root.comments {
            comment_lines := strings.split_lines(get_comment_source(root, comment_group))
            for line in comment_lines {
                godin_comment_text := strings.trim_right_space(line)

                if !strings.has_prefix(godin_comment_text, GODIN_COMMENT_PREFIX) {
                    continue
                }

                // eat the //+ at the beginning of the declaration
                godin_comment_text = line[3:]

                godin_comment, ok := parse_godin_comment(godin_comment_text, file_info.fullpath)
                assert(ok, "Error parsing comment.")

                if godin_comment.is_godin {
                    comments[comment_group.end.line] = godin_comment
                }
            }
        }

        for line, comment in comments {
            fmt.printf("Line %d Comment: '%s'\n", line, comment)
        }

        for stmt, index in root.decls {
            if decl, ok := stmt.derived.(^ast.Value_Decl); ok {
                godin_comment, comment_exists := comments[decl.pos.line - 1]
                fmt.printf("Checking decl: %v\n", decl)
                fmt.printf("Comment exists: %v\n", comment_exists)

                // if there isnt a godin attribute prepended to the declaration, then we can just 
                // ignore the declaration.
                if !comment_exists do continue

                #partial switch v in decl.values[0].derived {
                    case ^ast.Struct_Type:
                        state_class, ok := parse_state_class(state, decl, v, godin_comment)
                        assert(ok, "There were errors parsing the class.")

                        state_class.source.file = file_info
                        state_class.source.pos = decl.pos
                        state.classes[state_class.name] = state_class
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

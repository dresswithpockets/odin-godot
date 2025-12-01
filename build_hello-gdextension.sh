#!/bin/bash -eu

OUT_DIR="examples/hello-gdextension/bin"

mkdir -p $OUT_DIR

# windows
odin build examples/hello-gdextension/src -collection:godot=. -vet -strict-style -build-mode:dll -out:$OUT_DIR/example.dll -warnings-as-errors -default-to-nil-allocator -show-timings -debug

# linux
#odin build examples/hello-gdextension/src -collection:godot=. -vet -strict-style -build-mode:shared -out:$OUT_DIR/example.so -warnings-as-errors -default-to-nil-allocator -show-timings -debug
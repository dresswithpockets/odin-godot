#!/bin/bash -eu

OUT_DIR="build"

mkdir -p $OUT_DIR

# windows (w/ Git Bash)
#odin build src/mylib -vet -build-mode:dll -out:$OUT_DIR/mylib.dll -collection:godot=src/odin-godot -show-timings
#cp ./$OUT_DIR/mylib.lib ./src/mylib_tests

# linux
odin build src/mylib -vet -build-mode:dll -out:$OUT_DIR/mylib.so -collection:godot=src/odin-godot -show-timings
cp ./$OUT_DIR/mylib.so ./src/mylib_tests

echo "lib created in ${OUT_DIR} dir"

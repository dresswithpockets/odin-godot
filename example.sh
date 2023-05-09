odin build ./godin -vet -out:./godin/godin.exe -warnings-as-errors
./godin/godin.exe build ./example_project/src -godot-import-path:../../
odin build ./example_project/src -define:BUILD_CONFIG=float_64 -vet -build-mode:shared -out:./example_project/bin/example.windows.x86_64.dll -warnings-as-errors -default-to-nil-allocator -target:windows_amd64 -debug

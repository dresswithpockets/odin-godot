odin build ./src -define:BUILD_CONFIG=float_64 -build-mode:shared -out:./bin/example.windows.x86_64.dll -warnings-as-errors -default-to-nil-allocator -target:windows_amd64 -debug

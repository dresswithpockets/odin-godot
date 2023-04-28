# Odin Bindings for Godot GDExtension

This binding is WIP and not stable. Its currently targeting Godot v4.0.2.

At the moment, the bindings generator only produces global enums.

## C API Bindings

The C bindings are in `./gdinterface/`. They're based on `godot-cpp/gdextension/gdextension_interface.h`.

## Generating Complete Bindings

Clone & generate bindings
```sh
git clone --recursive-submodules -j8 https://github.com/dresswithpockets/odin-godot 
cd odin-godot
./bindgen.sh
```

> **N.B.** `bindgen.sh` expects odin on path, submodules updated, and odin-godot is the working directory.
>
> If you'd like, you may build and run `bindgen` yourself, for example:
> ```sh
> odin build ./bindgen -o:speed -out:./bindgen/bindgen.exe
> ./bindgen/bindgen.exe godot-cpp/gdextension/extension_api.json
> ```

## Creating a GDExtension

Create and export an entrypoint for your extension:

```odin
package example

import gd "godot:gdinterface"

@(export)
example_init :: proc "c" (
    interface: ^gd.Interface,
    library: gd.ExtensionClassLibraryPtr,
    initialization: ^gd.Initialization,
) -> bool {
    // do usual initialization
    return true
}
```

Build as a shared library
```sh
odin build . -build-mode:shared -collection:godot=path/to/odin-godot
```

Then, follow the instructions for [using the extension module](https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/gdextension_cpp_example.html#using-the-gdextension-module).

## Using Generated Bindings

WIP

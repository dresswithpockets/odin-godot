# Odin Bindings for Godot GDExtension

## C API Bindings

The C bindings are in `./gdinterface/`. They're based on `godot-cpp/gdextension/gdextension_interface.h`.

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
odin build . -build-mode:shared
```

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

## Using Generated Bindings

WIP

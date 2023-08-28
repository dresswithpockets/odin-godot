# Godot Toolkit for Odin

| :warning: This toolkit is not in a usable state!                                                  |
|:--------------------------------------------------------------------------------------------------|
| If you are using parts of it, beware of sudden major changes to the API, structure, and features. |

This currently targets Godot v4.1.1.

## C API Bindings

The C bindings are in `./gdextension/lib.odin`. They're based on `godot-cpp/gdextension/gdextension_interface.h`.

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

See [the example godot project](example_project/) for a working usage of these bindings.

Otherwise, create and export an entrypoint for your extension:

```odin
package example

// assuming odin-godot was cloned into your defacto shared collection
import gd "shared:odin-godot/gdextension"

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

Then, follow the instructions for [using the extension module](https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/gdextension_cpp_example.html#using-the-gdextension-module).

## Using Generated Bindings

WIP

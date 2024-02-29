# Godot Toolkit for Odin

> [!WARNING]
> **This toolkit is a Work In Progress!**
>
> If you are using parts of it, beware of sudden major changes to the API, structure, and features.

This currently targets Godot v4.2. This may work with v4.1, **but it will not work with v4.0**. For a version which works with `v4.0` use the [dev-4.0-2024-02 release](https://github.com/dresswithpockets/odin-godot/tree/dev-4.0-2024-02).

## Base GDExtension Bindings

The bindings to the C Interface are in `./gdextension/lib.odin`. They're based on `godot-cpp/gdextension/gdextension_interface.h`.

## Generating Complete Bindings

Clone & generate bindings
```sh
git clone --recursive-submodules -j8 https://github.com/dresswithpockets/odin-godot
cd odin-godot
make bindings
```

Bindings for all enums, classes, utility functions, singletons, and native structs will be generated in `core`, `editor`, and `variant`.

> [!NOTE]
> `make bindings` expects odin on path, all submodules updated, and odin-godot (this repo) is the working directory.

Alternatively, you may build and run `bindgen` yourself:
```sh
# temple is the templating engine used by bindgen, temple_cli is temple's preprocessor.
odin build temple/cli/ -o:speed -out:bin/temple_cli.exe

# temple_cli will recursively search all odin files in the specified directory for
# usages of `compiled` and `compiled_inline`, then it will generate Odin code with
# the built templates in templates.odin, in the specified directory. in this case,
# its looking in the bindgen directory, and outputs to temple/templates.odin.
./bin/temple_cli.exe bindgen temple

# bindgen is the tool which uses the temple templates to generate the entire
# GDExtension binding
odin build bindgen/ -o:speed -out:bin/bindgen.exe

# bindgen requires a path to a json file which describes the GDExtension API.
# One is available in godot-cpp.
./bin/bindgen.exe godot-cpp/gdextension/extension_api.json
```

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

## Godin

Godin is a preprocessor which generates most of the boilerplate for Extension Classes, Methods, Enums, Properties, Signals, Groups, and Subgroups.

For example, the following Odin code will produce all of the boilerplate for an extension class "Player" that extends "Node2D".
```odin
package test

//+class Player extends Node2D
Player :: struct {
    health: i64,
}
```

To build Godin:
```sh
# while in the odin-godot directory
./build_godin.sh
```

Run `godin help` for usage details, including documentation about the Godin preprocessor syntax.

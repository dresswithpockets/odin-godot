# GDExtension Bindings for Odin

## Usage

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

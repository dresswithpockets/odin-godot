ifeq ($(OS),Windows_NT)
	exe_suffix := .exe
	shared_suffix := .dll
endif

OUT_DIR := bin/
GD_BUILD_CONFIG := float_64

temple_cli_dir := temple/cli/
temple_cli_deps := $(wildcard $(temple_cli_dir)*.odin)
temple_cli_out := $(OUT_DIR)/temple_cli$(exe_suffix)

bindgen_dir := bindgen/
bindgen_deps := $(wildcard $(bindgen_dir)*.odin) $(bindgen_dir)templates.odin
bindgen_out := $(OUT_DIR)/bindgen$(exe_suffix)
debug_bindgen_out := $(OUT_DIR)/bindgen_debug$(exe_suffix)

temple_dir := temple
temple_deps := $(wildcard templates/*.temple.twig) $(bindgen_dir)temple.odin

gdextension_api := ./godot-cpp/gdextension/extension_api.json

bindings: core/init.gen.odin

# hack: we don't need to regenerate if core/init is up to date!
core/init.gen.odin: $(bindgen_out) $(gdextension_api)
	$(bindgen_out) $(gdextension_api)

debug_bindings: $(debug_bindgen_out) $(gdextension_api)
	$(debug_bindgen_out) $(gdextension_api)

### temple
$(temple_cli_out): $(temple_cli_deps)
	odin build $(temple_cli_dir) -out:$(temple_cli_out) -o:minimal -show-timings
temple: $(temple_cli_deps)
	odin build $(temple_cli_dir) -out:$(temple_cli_out) -o:minimal -show-timings
###

### templates
bindgen/templates.odin: $(temple_cli_out) $(temple_deps)
	$(temple_cli_out) $(bindgen_dir) $(bindgen_dir) bindgen
templates: $(temple_cli_out) $(temple_deps)
	$(temple_cli_out) $(bindgen_dir) $(bindgen_dir) bindgen
###

### bindgen
$(bindgen_out): $(bindgen_deps)
	odin build $(bindgen_dir) -out:$(bindgen_out) -o:minimal -show-timings
bindgen: $(bindgen_deps)
	odin build $(bindgen_dir) -out:$(bindgen_out) -o:minimal -show-timings

$(debug_bindgen_out): $(bindgen_deps)
	odin build $(bindgen_dir) -out:$(debug_bindgen_out) -show-timings -debug
debug_bindgen: $(bindgen_deps)
	odin build $(bindgen_dir) -out:$(debug_bindgen_out) -show-timings -debug
###


### examples
examples_hello_dir := examples/hello-gdextension/
examples_hello_deps := $(wildcard $(examples_hello_dir)src/*.odin)
examples_hello_out := $(examples_hello_dir)bin/example$(shared_suffix)

examples_game_dir := examples/game/
examples_game_deps := $(wildcard $(examples_game_dir)src/*.odin)
examples_game_out := $(examples_game_dir)bin/game$(shared_suffix)

$(examples_hello_out): core/init.gen.odin $(examples_hello_deps)
	odin build $(examples_hello_dir)src/ \
		-define:BUILD_CONFIG=$(GD_BUILD_CONFIG) \
		-build-mode:shared \
		-out:$(examples_hello_out) \
		-warnings-as-errors \
		-default-to-nil-allocator \
		-target:windows_amd64 \
		-debug \
		-show-timings

$(examples_game_out): core/init.gen.odin $(examples_game_deps)
	odin build $(examples_game_dir)src/ \
		-define:BUILD_CONFIG=$(GD_BUILD_CONFIG) \
		-build-mode:shared \
		-out:$(examples_game_out) \
		-warnings-as-errors \
		-default-to-nil-allocator \
		-target:windows_amd64 \
		-debug \
		-show-timings

examples: core/init.gen.odin $(examples_hello_out) $(examples_game_out)

examples/game/cbin/game.dll: $(wildcard examples/game/csrc/*)
	cl.exe /std:clatest /ZI /D_USRDLL /D_WINDLL $(wildcard examples/game/csrc/*.c) /link /DLL /OUT:examples/game/cbin/game.dll

cexamples: examples/game/cbin/game.dll
###

check:
	odin check gdextension/ -no-entry-point

.PHONY: clean

clean:
	rm -f $(OUT_DIR)/*
	rm -f editor/*.gen.odin
	rm -f core/*.gen.odin
	rm -f variant/*.gen.odin
	rm -f $(examples_hello_dir)bin/*
	rm -f $(examples_game_dir)bin/*
	rm -f examples/game/cbin/*

ifeq ($(OS),Windows_NT)
	exe_suffix := .exe
	shared_suffix := .dll
endif

OUT_DIR := bin/
REAL_PRECISION := single
JOBS := 0

temple_cli_dir := temple/cli/
temple_cli_deps := $(wildcard $(temple_cli_dir)*.odin)
temple_cli_out := $(OUT_DIR)/temple_cli$(exe_suffix)

bindgen_dir := bindgen/
bindgen_deps := $(wildcard $(bindgen_dir)*.odin) $(wildcard $(bindgen_dir)**/*.odin) $(bindgen_dir)templates.odin $(wildcard temple/*.odin)
bindgen_out := $(OUT_DIR)/bindgen$(exe_suffix)
debug_bindgen_out := $(OUT_DIR)/bindgen_debug$(exe_suffix)

temple_dir := temple
temple_deps := $(wildcard templates/*.temple.twig) $(bindgen_dir)temple.odin

gdextension_api := ./godot-cpp/gdextension/extension_api.json

bindings: godot/godot.gen.odin

# hack: we don't need to regenerate if core/init is up to date!
godot/godot.gen.odin: $(bindgen_out) $(gdextension_api)
	$(bindgen_out) $(gdextension_api) -jobs:$(JOBS)

debug_bindings: $(debug_bindgen_out) $(gdextension_api)
	$(debug_bindgen_out) $(gdextension_api)

### temple
$(temple_cli_out): $(temple_cli_deps)
	odin build $(temple_cli_dir) -out:$(temple_cli_out) -o:speed -show-timings
temple: $(temple_cli_out)
###

### templates
bindgen/templates.odin: $(temple_cli_out) $(temple_deps)
	$(temple_cli_out) $(bindgen_dir) $(bindgen_dir) bindgen
templates: bindgen/templates.odin
###

### bindgen
$(bindgen_out): $(bindgen_deps)
	odin build $(bindgen_dir) -out:$(bindgen_out) -o:speed -show-timings
bindgen: $(bindgen_out)

$(debug_bindgen_out): $(bindgen_deps)
	odin build $(bindgen_dir) -out:$(debug_bindgen_out) -show-timings -debug
debug_bindgen: $(debug_bindgen_out)
###


### examples
examples_hello_dir := examples/hello-gdextension/
examples_hello_deps := $(wildcard $(examples_hello_dir)src/*.odin)
examples_hello_out := $(examples_hello_dir)bin/example$(shared_suffix)

examples_game_dir := examples/game/
examples_game_deps := $(wildcard $(examples_game_dir)src/*.odin)
examples_game_out := $(examples_game_dir)bin/game$(shared_suffix)

$(examples_hello_out): godot/godot.gen.odin $(examples_hello_deps)
	odin build $(examples_hello_dir)src/ \
		-define:REAL_PRECISION=$(REAL_PRECISION) \
		-collection:godot=. \
		-build-mode:shared \
		-out:$(examples_hello_out) \
		-warnings-as-errors \
		-default-to-nil-allocator \
		-target:windows_amd64 \
		-debug \
		-show-timings \
		-use-single-module

$(examples_game_out): godot/godot.gen.odin $(examples_game_deps)
	odin build $(examples_game_dir)src/ \
		-define:REAL_PRECISION=$(REAL_PRECISION) \
		-collection:godot=. \
		-build-mode:shared \
		-out:$(examples_game_out) \
		-warnings-as-errors \
		-default-to-nil-allocator \
		-target:windows_amd64 \
		-debug \
		-show-timings \
		-use-single-module

examples/tests/bin/tests$(shared_suffix): godot/godot.gen.odin $(wildcard examples/tests/src/*.odin)
	odin build examples/tests/src/ \
		-define:REAL_PRECISION=$(REAL_PRECISION) \
		-collection:godot=. \
		-build-mode:shared \
		-out:examples/tests/bin/tests$(shared_suffix) \
		-warnings-as-errors \
		-default-to-nil-allocator \
		-target:windows_amd64 \
		-debug \
		-show-timings \
		-use-single-module

examples: examples/tests/bin/tests$(shared_suffix) $(examples_hello_out) $(examples_game_out)

examples/game/cbin/game.dll: $(wildcard examples/game/csrc/*)
	cl.exe /std:clatest /ZI /D_USRDLL /D_WINDLL $(wildcard examples/game/csrc/*.c) /link /DLL /OUT:examples/game/cbin/game.dll

cexamples: examples/game/cbin/game.dll
###

tests:
	odin test bindgen/ -all-packages -debug -out:$(bindgen_out)

check:
	odin check bindgen/
	odin check gdextension/ -no-entry-point -collection:godot=. -vet
	odin check godot/ -no-entry-point -collection:godot=. -define:REAL_PRECISION=$(REAL_PRECISION) -vet
	odin check examples/tests/src -no-entry-point -collection:godot=. -define:REAL_PRECISION=$(REAL_PRECISION) -vet

.PHONY: clean

clean:
	rm -f bindgen/templates.odin
	rm -f $(OUT_DIR)/*
	rm -f godot/*.gen.odin
	rm -f $(examples_hello_dir)bin/*
	rm -f $(examples_game_dir)bin/*
	rm -f examples/tests/bin/*
	rm -f examples/game/cbin/*

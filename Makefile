ifeq ($(OS),Windows_NT)
	exe_suffix := .exe
endif

OUT_DIR := bin/

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

bindings: $(bindgen_out) $(gdextension_api)
	$(bindgen_out) $(gdextension_api)

debug_bindings: $(debug_bindgen_out) $(gdextension_api)
	$(debug_bindgen_out) $(gdextension_api)

### temple
$(temple_cli_out): $(temple_cli_deps)
	odin build $(temple_cli_dir) -out:$(temple_cli_out) -o:speed -show-timings
temple: $(temple_cli_deps)
	odin build $(temple_cli_dir) -out:$(temple_cli_out) -o:speed -show-timings
###

### templates
bindgen/templates.odin: $(temple_cli_out) $(temple_deps)
	$(temple_cli_out) $(bindgen_dir) $(bindgen_dir) bindgen
templates: $(temple_cli_out) $(temple_deps)
	$(temple_cli_out) $(bindgen_dir) $(bindgen_dir) bindgen
###

### bindgen
$(bindgen_out): $(bindgen_deps)
	odin build $(bindgen_dir) -out:$(bindgen_out) -o:speed -show-timings
bindgen: $(bindgen_deps)
	odin build $(bindgen_dir) -out:$(bindgen_out) -o:speed -show-timings

$(debug_bindgen_out): $(bindgen_deps)
	odin build $(bindgen_dir) -out:$(debug_bindgen_out) -show-timings -debug
debug_bindgen: $(bindgen_deps)
	odin build $(bindgen_dir) -out:$(debug_bindgen_out) -show-timings -debug
###

.PHONY: clean

clean:
	rm -f $(OUT_DIR)/*
	rm -f editor/*.gen.odin
	rm -f core/*.gen.odin
	rm -f variant/*.gen.odin

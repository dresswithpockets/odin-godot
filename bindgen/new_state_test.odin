package bindgen

import "core:testing"
import "core:encoding/json"

@(private)
TEST_JSON_SPEC :: "./godot-cpp/gdextension/extension_api.json"

@(test)
state_type_map_contains_every_referred_type :: proc(t: ^testing.T) {
    options := Options{
        api_file = TEST_JSON_SPEC,
    }
    api, ok := load_api(options)
    testing.expect(t, ok, "There was an error loading the api from the file.\n")

    state := create_new_state(options, api)

    for builtin_class in api.builtin_classes {
        for constant in builtin_class.constants {
            testing.expectf(t, new_state_godot_type_in_map(state, constant.type), "Expected '%v' in all_types map", constant.type)
        }

        for constructor in builtin_class.constructors {
            for argument in constructor.arguments {
                testing.expectf(t, new_state_godot_type_in_map(state, argument.type), "Expected '%v' in all_types map", argument.type)
            }
        }

        if indexing_return_type, ok := builtin_class.indexing_return_type.(string); ok {
            testing.expectf(t, new_state_godot_type_in_map(state, indexing_return_type), "Expected '%v' in all_types map", indexing_return_type)
        }

        for member in builtin_class.members {
            testing.expectf(t, new_state_godot_type_in_map(state, member.type), "Expected '%v' in all_types map", member.type)
        }

        for method in builtin_class.methods {
            for argument in method.arguments {
                testing.expectf(t, new_state_godot_type_in_map(state, argument.type), "Expected '%v' in all_types map", argument.type)
            }

            if return_type, ok := method.return_type.(string); ok {
                testing.expectf(t, new_state_godot_type_in_map(state, return_type), "Expected '%v' in all_types map", return_type)
            }
        }

        for operator in builtin_class.operators {
            testing.expectf(t, new_state_godot_type_in_map(state, operator.return_type), "Expected '%v' in all_types map", operator.return_type)
            if right_type, ok := operator.right_type.(string); ok {
                testing.expectf(t, new_state_godot_type_in_map(state, right_type), "Expected '%v' in all_types map", right_type)
            }
        }
    }

    for class in api.classes {
        for constant in class.constants {
            if len(constant.type) > 0 {
                testing.expectf(t, new_state_godot_type_in_map(state, constant.type), "Expected '%v' in all_types map", constant.type)
            } else {
                // testing.logf(t, "Constant '%v.%v' has empty type", class.name, constant.name)
            }
        }

        for method in class.methods {
            for argument in method.arguments {
                testing.expectf(t, new_state_godot_type_in_map(state, argument.type), "Expected '%v' in all_types map", argument.type)
            }

            if return_value, ok := method.return_value.(ApiClassMethodReturnValue); ok{
                testing.expectf(t, new_state_godot_type_in_map(state, return_value.type), "Expected '%v' in all_types map", return_value.type)
                if meta, ok := return_value.meta.(string); ok {
                    testing.expectf(t, new_state_godot_type_in_map(state, meta), "Expected '%v' in all_types map", meta)
                }
            }
        }

        for operator in class.operators {
            testing.expectf(t, new_state_godot_type_in_map(state, operator.return_type), "Expected '%v' in all_types map", operator.return_type)
            if right_type, ok := operator.right_type.(string); ok {
                testing.expectf(t, new_state_godot_type_in_map(state, right_type), "Expected '%v' in all_types map", right_type)
            }
        }
    }
}
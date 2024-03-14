package bindgen

import "core:testing"
import "core:encoding/json"

@(private)
TEST_JSON_SPEC :: "./godot-cpp/gdextension/extension_api.json"

@(test)
state_type_map_contains_every_pod_type :: proc(t: ^testing.T) {
    options := Options{
        api_file = TEST_JSON_SPEC,
    }
    api, ok := load_api(options)
    testing.expect(t, ok, "There was an error loading the api from the file.\n")

    state := create_new_state(options, api)

    for godot_type, odin_type in new_pod_type_map {
        state_type, has_type := state.all_types[godot_type]
        testing.expectf(t, has_type, "couldn't find type '%v' in all_types", godot_type)
        _, ok := state_type.type.(NewStatePodType)
        #partial switch _ in state_type.type {
            case NewStateClass:
                testing.errorf(t, "Expected POD derived type for '%v', got Class instead", godot_type)
            case NewStateEnum:
                testing.errorf(t, "Expected POD derived type for '%v', got Enum instead", godot_type)
            case NewStateNativeStructure:
                testing.errorf(t, "Expected POD derived type for '%v', got Native Struct instead", godot_type)
        }

        testing.expect_value(t, state_type.odin_type, odin_type)
    }
}

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

/*
    Copyright 2023 Dresses Digital

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
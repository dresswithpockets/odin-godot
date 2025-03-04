package bindgen

import "core:fmt"
import "core:slice"
import "core:strings"

global_enums_template := temple_compiled("../templates/bindgen_global_enums.temple.twig", ^State)
builtin_class_template := temple_compiled("../templates/bindgen_builtin_class.temple.twig", ^StateType)
util_functions_template := temple_compiled("../templates/bindgen_utility_functions.temple.twig", ^State)
engine_class_template := temple_compiled("../templates/bindgen_class.temple.twig", ^StateType)
native_struct_template := temple_compiled("../templates/bindgen_native_structs.temple.twig", ^State)
variant_init_template := temple_compiled("../templates/bindgen_variant_init.temple.twig", ^State)
core_init_template := temple_compiled("../templates/bindgen_init_core.temple.twig", ^State)
editor_init_template := temple_compiled("../templates/bindgen_init_editor.temple.twig", ^State)

bindgen_class_reference_type :: proc(type: ^StateType) -> string {
    // HACK: Variant.Type and Variant.Operator are provided by the gdextension interface
    if type.godot_type == "Variant.Type" {
        return "__bindgen_gde.VariantType"
    }

    if type.godot_type == "Variant.Operator" {
        return "__bindgen_gde.VariantOperator"
    }

    if class, is_class := type.derived.(StateClass); is_class && class.is_builtin {
        caret_index := strings.last_index(type.odin_type, "^")
        if caret_index == -1 {
            return fmt.tprintf("__bindgen_var.%s", type.odin_type)
        }

        carets, carets_ok := strings.substring_to(type.odin_type, caret_index + 1)
        assert(carets_ok)
        odin_name, odin_name_ok := strings.substring_from(type.odin_type, caret_index + 1)
        assert(odin_name_ok)

        return fmt.tprintf("%s__bindgen_var.%s", carets, odin_name)
    }

    if enum_type, is_enum_type := type.derived.(StateEnum); is_enum_type && enum_type.parent_class != nil {
        parent_class := enum_type.parent_class.(^StateType).derived.(StateClass)
        if parent_class.is_builtin {
            return fmt.tprintf("__bindgen_var.%s", type.odin_type)
        }
    }

    return type.odin_type
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

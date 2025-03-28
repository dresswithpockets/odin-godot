package bindgen

import "core:fmt"
import "core:slice"
import "core:strings"
import "views"

variant_template := temple_compiled("../templates/bindgen_view_variant.temple.twig", views.Variant)
engine_class_template := temple_compiled("../templates/bindgen_view_engine.temple.twig", views.Engine_Class)
core_template := temple_compiled("../templates/bindgen_view_core.temple.twig", views.Godot_Package)
structs_template := temple_compiled("../templates/bindgen_view_structs.temple.twig", views.Structs)

/*
    Copyright 2025 Dresses Digital

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

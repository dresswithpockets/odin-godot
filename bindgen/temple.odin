package bindgen

global_enums_template := temple_compiled("../templates/bindgen_global_enums.temple.twig", ^NewState)
builtin_class_template := temple_compiled("../templates/bindgen_builtin_class.temple.twig", ^NewStateType)
util_functions_template := temple_compiled("../templates/bindgen_utility_functions.temple.twig", ^NewState)
engine_class_template := temple_compiled("../templates/bindgen_class.temple.twig", ^NewStateType)

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
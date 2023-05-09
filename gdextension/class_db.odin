package gdextension

// called by Godot the first time i calls a virtual func, it caches the result per object instance.
// So, it can happen from different threads at once. 
// N.B. ported from godot-cpp/src/core/class_db.cpp
//
// for our implementation, we dont support virtual method binding (yet), so this will always return
// nil
class_db_get_virtual_func :: proc "c" (user_data: rawptr, name: StringNamePtr) -> ExtensionClassCallVirtual {
    return nil
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

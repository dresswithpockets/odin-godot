#+build windows
package bindgen

import "core:sys/windows"

num_processors :: proc() -> int {
    system_info: windows.SYSTEM_INFO
    windows.GetSystemInfo(&system_info)
    return cast(int)system_info.dwNumberOfProcessors
}

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

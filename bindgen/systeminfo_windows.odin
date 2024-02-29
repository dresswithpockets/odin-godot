//+build windows
package bindgen

import "core:sys/windows"

num_processors :: proc() -> int {
    system_info: windows.SYSTEM_INFO
    windows.GetSystemInfo(&system_info)
    return cast(int)system_info.dwNumberOfProcessors
}

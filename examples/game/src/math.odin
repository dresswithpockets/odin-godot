package game

import gd "../../../gdextension"
import "core:math"
import "core:math/linalg"

exp_decay :: proc "contextless" (a, b: $T, decay, delta: gd.float) -> T {
    return b + (a - b) * math.exp(-decay * delta)
}

CMP_EPSILON :: 0.00001

is_zero_approx :: proc "contextless" (a: [3]gd.float) -> bool {
    return abs(a.x) < CMP_EPSILON && abs(a.y) < CMP_EPSILON && abs(a.z) < CMP_EPSILON
}

limit_length :: proc "contextless" (v: [3]gd.float, max_length: gd.float) -> (r: [3]gd.float) {
    r = v
    length := linalg.length(v)
    if length > 0 && max_length < length {
        r /= length
        r *= max_length
    }

    return
}

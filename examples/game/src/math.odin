package game

import "godot:godot"
import "core:math"
import "core:math/linalg"

exp_decay :: proc "contextless" (a, b: $T, decay, delta: $F) -> T {
    return b + (a - b) * math.exp(-decay * delta)
}

CMP_EPSILON :: 0.00001

is_zero_approx :: proc "contextless" (a: godot.Vector3) -> bool {
    return abs(a.x) < CMP_EPSILON && abs(a.y) < CMP_EPSILON && abs(a.z) < CMP_EPSILON
}

limit_length :: proc "contextless" (v: godot.Vector3, max_length: godot.Float) -> (r: godot.Vector3) {
    r = v
    length := linalg.length(v)
    if length > 0 && godot.Real(max_length) < length {
        r /= length
        r *= godot.Real(max_length)
    }

    return
}

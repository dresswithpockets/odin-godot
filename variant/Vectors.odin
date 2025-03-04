package variant

import gd "../gdextension"

components :: proc{
    components_v2,
    components_v2i,
    components_v3,
    components_v3i,
    components_v4,
    components_v4i,
}

components_v2 :: proc "contextless" (v: Vector2) -> (x: gd.float, y: gd.float) {
    return vector2_get_x(v), vector2_get_y(v)
}

components_v2i :: proc "contextless" (v: Vector2i) -> (x: int, y: int) {
    return vector2i_get_x(v), vector2i_get_y(v)
}

components_v3 :: proc "contextless" (v: Vector3) -> (x: gd.float, y: gd.float, z: gd.float) {
    return vector3_get_x(v), vector3_get_y(v), vector3_get_z(v)
}

components_v3i :: proc "contextless" (v: Vector3i) -> (x: int, y: int, z: int) {
    return vector3i_get_x(v), vector3i_get_y(v), vector3i_get_z(v)
}

components_v4 :: proc "contextless" (v: Vector4) -> (x: gd.float, y: gd.float, z: gd.float, w: gd.float) {
    return vector4_get_x(v), vector4_get_y(v), vector4_get_z(v), vector4_get_w(v)
}

components_v4i :: proc "contextless" (v: Vector4i) -> (x: int, y: int, z: int, w: int) {
    return vector4i_get_x(v), vector4i_get_y(v), vector4i_get_z(v), vector4i_get_w(v)
}

array :: proc{
    array_v2,
    array_v2i,
    array_v3,
    array_v3i,
    array_v4,
    array_v4i,
}

array_v2 :: proc "contextless" (v: Vector2) -> [2]gd.float {
    return [2]gd.float{vector2_get_x(v), vector2_get_y(v)}
}

array_v2i :: proc "contextless" (v: Vector2i) -> [2]int {
    return [2]int{vector2i_get_x(v), vector2i_get_y(v)}
}

array_v3 :: proc "contextless" (v: Vector3) -> [3]gd.float {
    return [3]gd.float{vector3_get_x(v), vector3_get_y(v), vector3_get_z(v)}
}

array_v3i :: proc "contextless" (v: Vector3i) -> [3]int {
    return [3]int{vector3i_get_x(v), vector3i_get_y(v), vector3i_get_z(v)}
}

array_v4 :: proc "contextless" (v: Vector4) -> [4]gd.float {
    return [4]gd.float{vector4_get_x(v), vector4_get_y(v), vector4_get_z(v), vector4_get_w(v)}
}

array_v4i :: proc "contextless" (v: Vector4i) -> [4]int {
    return [4]int{vector4i_get_x(v), vector4i_get_y(v), vector4i_get_z(v), vector4i_get_w(v)}
}

ARRAY_VEC3_ZERO :: [3]gd.float{0, 0, 0}
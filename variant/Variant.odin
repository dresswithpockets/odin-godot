package variant

import gd "../gdextension"

variant_from :: proc {
    variant_from_string,
    variant_from_string_name,
    variant_from_float,
    variant_from_node_path,
    variant_from_object,
    variant_from_vector2,
    variant_from_vector3,
}

variant_from_string :: proc "contextless" (from: ^String) -> (ret: Variant) {
    variant_constructor := gd.get_variant_from_type_constructor(.String)
    ret = Variant{}
    variant_constructor(&ret, from)
    return
}

variant_from_string_name :: proc "contextless" (from: ^StringName) -> (ret: Variant) {
    variant_constructor := gd.get_variant_from_type_constructor(.StringName)
    ret = Variant{}
    variant_constructor(&ret, from)
    return
}

variant_from_float :: proc "contextless" (from: ^gd.float) -> (ret: Variant) {
    variant_constructor := gd.get_variant_from_type_constructor(.Float)
    ret = Variant{}
    variant_constructor(&ret, from)
    return
}

variant_from_node_path :: proc "contextless" (from: ^NodePath) -> (ret: Variant) {
    variant_constructor := gd.get_variant_from_type_constructor(.NodePath)
    ret = Variant{}
    variant_constructor(&ret, from)
    return
}

variant_from_object :: proc "contextless" (from: ^$T/gd.ObjectPtr) -> (ret: Variant) {
    variant_constructor := gd.get_variant_from_type_constructor(.Object)
    ret = Variant{}
    variant_constructor(&ret, from)
    return
}

variant_from_vector2 :: proc "contextless" (from: ^Vector2) -> (ret: Variant) {
    variant_constructor := gd.get_variant_from_type_constructor(.Vector2)
    ret = Variant{}
    variant_constructor(&ret, from)
    return
}


variant_from_vector3 :: proc "contextless" (from: ^Vector3) -> (ret: Variant) {
    variant_constructor := gd.get_variant_from_type_constructor(.Vector3)
    ret = Variant{}
    variant_constructor(&ret, from)
    return
}

variant_to_object :: proc "contextless" (from: ^Variant, to: $T) {
    variant_converter := gd.get_variant_to_type_constructor(.Object)
    variant_converter(to, from)
}

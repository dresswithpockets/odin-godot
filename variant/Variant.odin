package variant

import gd "../gdextension"

variant_from :: proc {
    variant_from_float,
    variant_from_string_name,
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
package variant

import gd "../gdextension"

variant_from :: proc "contextless" (from: ^$T) -> (ret: Variant)
    where T == StringName ||
        T == gd.float {

    from := from
    variant_constructor: gd.VariantFromTypeConstructorProc
    when type_of(from) == StringName {
        variant_constructor = gd.get_variant_from_type_constructor(.StringName)
    } else when type_of(from) == gd.float {
        variant_constructor = gd.get_variant_from_type_constructor(.Float)
    }

    ret = Variant{}
    variant_constructor(&ret, from)
    return
}

package godot

import gd "godot:gdext"
import "base:intrinsics"
import "core:math"

REAL_PRECISION :: #config(REAL_PRECISION, "float_64")

when REAL_PRECISION == "double" {
    Real :: f64
    Quat :: quaternion256
    REAL_INF :: math.INF_F64
} else {
    Real :: f32
    Quat :: quaternion128
    REAL_INF :: math.INF_F32
}

Bool :: bool
Int :: i64
Float :: f64

Opaque :: struct(I: int) {
    opaque: [I]uintptr,
}

Variant :: struct {
    type:   gd.Variant_Type,
    opaque: Opaque(4),
}

Vector2 :: [2]Real
Vector3 :: [3]Real
Vector4 :: [4]Real
Vector2i :: [2]i32
Vector3i :: [3]i32
Vector4i :: [4]i32

Rect2 :: struct {
    position: Vector2,
    size:     Vector2,
}

Rect2i :: struct {
    position: Vector2i,
    size:     Vector2i,
}

Transform2d :: struct {
    x:      Vector2,
    y:      Vector2,
    origin: Vector2,
}

Plane :: struct {
    normal: Vector3,
    d:      Real,
}

Quaternion :: Quat

Aabb :: struct {
    position: Vector3,
    size:     Vector3,
}

Basis :: [3]Vector3

Transform3d :: struct {
    basis:  Basis,
    origin: Vector3,
}

Projection :: [4]Vector4

Color :: distinct [4]Real

Rid :: distinct Opaque(2)
String :: distinct Opaque(1)
String_Name :: distinct Opaque(1)
Node_Path :: distinct Opaque(1)
Callable :: distinct Opaque(4)
Signal :: distinct Opaque(4)
Dictionary :: distinct Opaque(1)
Array :: distinct Opaque(1)

Typed_Array :: struct($T: typeid) where intrinsics.type_is_variant_of(Variantable_Type, T) || intrinsics.type_is_specialization_of(T, Packed_Array) {
    using untyped: Array,
}

Packed_Array :: struct($T: typeid) where intrinsics.type_is_variant_of(Some_Packable, T) {
    proxy:       rawptr,
    data_unsafe: [^]T,
}

Packed_Byte_Array :: Packed_Array(byte)
Packed_Int32_Array :: Packed_Array(i32)
Packed_Int64_Array :: Packed_Array(i64)
Packed_Float32_Array :: Packed_Array(f32)
Packed_Float64_Array :: Packed_Array(f64)
Packed_String_Array :: Packed_Array(String)
Packed_Vector2_Array :: Packed_Array(Vector2)
Packed_Vector3_Array :: Packed_Array(Vector3)
Packed_Vector4_Array :: Packed_Array(Vector4)
Packed_Color_Array :: Packed_Array(Color)

Object :: gd.ObjectPtr
Ref_Counted :: ^Object

Some_Packable :: union {
    byte,
    i32,
    i64,
    f32,
    f64,
    String,
    Vector2,
    Vector3,
    Vector4,
    Color,
}

Variantable_Type :: union {
    // vectors
    Vector2,
    Vector2i,
    Vector3,
    Vector3i,
    Vector4,
    Vector4i,

    // primitives
    Bool,
    Int,
    Float,
    Rect2,
    Rect2i,
    Transform2d,
    Plane,
    Quaternion,
    Aabb,
    Basis,
    Transform3d,
    Projection,
    Color,

    // unique/opaque types
    Object,
    Ref_Counted,
    String,
    String_Name,
    Node_Path,
    Rid,
    Callable,
    Signal,
    Dictionary,
    Array,
}

Vector2_Zero :: Vector2{0, 0}
Vector2_One :: Vector2{1, 1}
Vector2_Inf :: Vector2{REAL_INF, REAL_INF}
Vector2_Left :: Vector2{-1, 0}
Vector2_Right :: Vector2{1, 0}
Vector2_Up :: Vector2{0, -1}
Vector2_Down :: Vector2{0, 1}

Vector2i_Zero :: Vector2i{0, 0}
Vector2i_One :: Vector2i{1, 1}
Vector2i_Min :: Vector2i{min(i32), min(i32)}
Vector2i_Max :: Vector2i{max(i32), max(i32)}
Vector2i_Left :: Vector2i{-1, 0}
Vector2i_Right :: Vector2i{1, 0}
Vector2i_Up :: Vector2i{0, -1}
Vector2i_Down :: Vector2i{0, 1}

VECTOR3_ZERO :: Vector3{0, 0, 0}
VECTOR3_ONE :: Vector3{1, 1, 1}
VECTOR3_INF :: Vector3{REAL_INF, REAL_INF, REAL_INF}
VECTOR3_LEFT :: Vector3{-1, 0, 0}
VECTOR3_RIGHT :: Vector3{1, 0, 0}
VECTOR3_UP :: Vector3{0, 1, 0}
VECTOR3_DOWN :: Vector3{0, -1, 0}
VECTOR3_FORWARD :: Vector3{0, 0, -1}
VECTOR3_BACK :: Vector3{0, 0, 1}
VECTOR3_MODEL_LEFT :: Vector3{1, 0, 0}
VECTOR3_MODEL_RIGHT :: Vector3{-1, 0, 0}
VECTOR3_MODEL_TOP :: Vector3{0, 1, 0}
VECTOR3_MODEL_BOTTOM :: Vector3{0, -1, 0}
VECTOR3_MODEL_FRONT :: Vector3{0, 0, 1}
VECTOR3_MODEL_REAR :: Vector3{0, 0, -1}

VECTOR3I_ZERO :: Vector3i{0, 0, 0}
VECTOR3I_ONE :: Vector3i{1, 1, 1}
VECTOR3I_MIN :: Vector3i{-2147483648, -2147483648, -2147483648}
VECTOR3I_MAX :: Vector3i{2147483647, 2147483647, 2147483647}
VECTOR3I_LEFT :: Vector3i{-1, 0, 0}
VECTOR3I_RIGHT :: Vector3i{1, 0, 0}
VECTOR3I_UP :: Vector3i{0, 1, 0}
VECTOR3I_DOWN :: Vector3i{0, -1, 0}
VECTOR3I_FORWARD :: Vector3i{0, 0, -1}
VECTOR3I_BACK :: Vector3i{0, 0, 1}

TRANSFORM2D_IDENTITY :: Transform2d{{1, 0}, {0, 1}, {0, 0}}
TRANSFORM2D_FLIP_X :: Transform2d{{-1, 0}, {0, 1}, {0, 0}}
TRANSFORM2D_FLIP_Y :: Transform2d{{1, 0}, {0, -1}, {0, 0}}

VECTOR4_ZERO :: Vector4{0, 0, 0, 0}
VECTOR4_ONE :: Vector4{1, 1, 1, 1}
VECTOR4_INF :: Vector4{REAL_INF, REAL_INF, REAL_INF, REAL_INF}

VECTOR4I_ZERO :: Vector4i{0, 0, 0, 0}
VECTOR4I_ONE :: Vector4i{1, 1, 1, 1}
VECTOR4I_MIN :: Vector4i{-2147483648, -2147483648, -2147483648, -2147483648}
VECTOR4I_MAX :: Vector4i{2147483647, 2147483647, 2147483647, 2147483647}

Plane_PLANE_YZ :: Plane{{1, 0, 0}, 0}
Plane_PLANE_XZ :: Plane{{0, 1, 0}, 0}
Plane_PLANE_XY :: Plane{{0, 0, 1}, 0}

QUATERNION_IDENTITY :: quaternion(
    real = cast(Real)0,
    imag = cast(Real)0,
    jmag = cast(Real)0,
    kmag = cast(Real)1,
)

BASIS_IDENTITY :: Basis{Vector3{1, 0, 0}, Vector3{0, 1, 0}, Vector3{0, 0, 1}}
BASIS_FLIP_X :: Basis{Vector3{-1, 0, 0}, Vector3{0, 1, 0}, Vector3{0, 0, 1}}
BASIS_FLIP_Y :: Basis{Vector3{1, 0, 0}, Vector3{0, -1, 0}, Vector3{0, 0, 1}}
BASIS_FLIP_Z :: Basis{Vector3{1, 0, 0}, Vector3{0, 1, 0}, Vector3{0, 0, -1}}

TRANSFORM3D_IDENTITY :: Transform3d {
    basis  = BASIS_IDENTITY,
    origin = VECTOR3_ZERO,
}
TRANSFORM3D_FLIP_X :: Transform3d {
    basis  = BASIS_FLIP_X,
    origin = VECTOR3_ZERO,
}
TRANSFORM3D_FLIP_Y :: Transform3d {
    basis  = BASIS_FLIP_Y,
    origin = VECTOR3_ZERO,
}
TRANSFORM3D_FLIP_Z :: Transform3d {
    basis  = BASIS_FLIP_Z,
    origin = VECTOR3_ZERO,
}

PROJECTION_IDENTITY :: Projection{{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}}
PROJECTION_ZERO :: Projection{{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}

COLOR_ALICE_BLUE :: Color{0.941176, 0.972549, 1, 1}
COLOR_ANTIQUE_WHITE :: Color{0.980392, 0.921569, 0.843137, 1}
COLOR_AQUA :: Color{0, 1, 1, 1}
COLOR_AQUAMARINE :: Color{0.498039, 1, 0.831373, 1}
COLOR_AZURE :: Color{0.941176, 1, 1, 1}
COLOR_BEIGE :: Color{0.960784, 0.960784, 0.862745, 1}
COLOR_BISQUE :: Color{1, 0.894118, 0.768627, 1}
COLOR_BLACK :: Color{0, 0, 0, 1}
COLOR_BLANCHED_ALMOND :: Color{1, 0.921569, 0.803922, 1}
COLOR_BLUE :: Color{0, 0, 1, 1}
COLOR_BLUE_VIOLET :: Color{0.541176, 0.168627, 0.886275, 1}
COLOR_BROWN :: Color{0.647059, 0.164706, 0.164706, 1}
COLOR_BURLYWOOD :: Color{0.870588, 0.721569, 0.529412, 1}
COLOR_CADET_BLUE :: Color{0.372549, 0.619608, 0.627451, 1}
COLOR_CHARTREUSE :: Color{0.498039, 1, 0, 1}
COLOR_CHOCOLATE :: Color{0.823529, 0.411765, 0.117647, 1}
COLOR_CORAL :: Color{1, 0.498039, 0.313726, 1}
COLOR_CORNFLOWER_BLUE :: Color{0.392157, 0.584314, 0.929412, 1}
COLOR_CORNSILK :: Color{1, 0.972549, 0.862745, 1}
COLOR_CRIMSON :: Color{0.862745, 0.0784314, 0.235294, 1}
COLOR_CYAN :: Color{0, 1, 1, 1}
COLOR_DARK_BLUE :: Color{0, 0, 0.545098, 1}
COLOR_DARK_CYAN :: Color{0, 0.545098, 0.545098, 1}
COLOR_DARK_GOLDENROD :: Color{0.721569, 0.52549, 0.0431373, 1}
COLOR_DARK_GRAY :: Color{0.662745, 0.662745, 0.662745, 1}
COLOR_DARK_GREEN :: Color{0, 0.392157, 0, 1}
COLOR_DARK_KHAKI :: Color{0.741176, 0.717647, 0.419608, 1}
COLOR_DARK_MAGENTA :: Color{0.545098, 0, 0.545098, 1}
COLOR_DARK_OLIVE_GREEN :: Color{0.333333, 0.419608, 0.184314, 1}
COLOR_DARK_ORANGE :: Color{1, 0.54902, 0, 1}
COLOR_DARK_ORCHID :: Color{0.6, 0.196078, 0.8, 1}
COLOR_DARK_RED :: Color{0.545098, 0, 0, 1}
COLOR_DARK_SALMON :: Color{0.913725, 0.588235, 0.478431, 1}
COLOR_DARK_SEA_GREEN :: Color{0.560784, 0.737255, 0.560784, 1}
COLOR_DARK_SLATE_BLUE :: Color{0.282353, 0.239216, 0.545098, 1}
COLOR_DARK_SLATE_GRAY :: Color{0.184314, 0.309804, 0.309804, 1}
COLOR_DARK_TURQUOISE :: Color{0, 0.807843, 0.819608, 1}
COLOR_DARK_VIOLET :: Color{0.580392, 0, 0.827451, 1}
COLOR_DEEP_PINK :: Color{1, 0.0784314, 0.576471, 1}
COLOR_DEEP_SKY_BLUE :: Color{0, 0.74902, 1, 1}
COLOR_DIM_GRAY :: Color{0.411765, 0.411765, 0.411765, 1}
COLOR_DODGER_BLUE :: Color{0.117647, 0.564706, 1, 1}
COLOR_FIREBRICK :: Color{0.698039, 0.133333, 0.133333, 1}
COLOR_FLORAL_WHITE :: Color{1, 0.980392, 0.941176, 1}
COLOR_FOREST_GREEN :: Color{0.133333, 0.545098, 0.133333, 1}
COLOR_FUCHSIA :: Color{1, 0, 1, 1}
COLOR_GAINSBORO :: Color{0.862745, 0.862745, 0.862745, 1}
COLOR_GHOST_WHITE :: Color{0.972549, 0.972549, 1, 1}
COLOR_GOLD :: Color{1, 0.843137, 0, 1}
COLOR_GOLDENROD :: Color{0.854902, 0.647059, 0.12549, 1}
COLOR_GRAY :: Color{0.745098, 0.745098, 0.745098, 1}
COLOR_GREEN :: Color{0, 1, 0, 1}
COLOR_GREEN_YELLOW :: Color{0.678431, 1, 0.184314, 1}
COLOR_HONEYDEW :: Color{0.941176, 1, 0.941176, 1}
COLOR_HOT_PINK :: Color{1, 0.411765, 0.705882, 1}
COLOR_INDIAN_RED :: Color{0.803922, 0.360784, 0.360784, 1}
COLOR_INDIGO :: Color{0.294118, 0, 0.509804, 1}
COLOR_IVORY :: Color{1, 1, 0.941176, 1}
COLOR_KHAKI :: Color{0.941176, 0.901961, 0.54902, 1}
COLOR_LAVENDER :: Color{0.901961, 0.901961, 0.980392, 1}
COLOR_LAVENDER_BLUSH :: Color{1, 0.941176, 0.960784, 1}
COLOR_LAWN_GREEN :: Color{0.486275, 0.988235, 0, 1}
COLOR_LEMON_CHIFFON :: Color{1, 0.980392, 0.803922, 1}
COLOR_LIGHT_BLUE :: Color{0.678431, 0.847059, 0.901961, 1}
COLOR_LIGHT_CORAL :: Color{0.941176, 0.501961, 0.501961, 1}
COLOR_LIGHT_CYAN :: Color{0.878431, 1, 1, 1}
COLOR_LIGHT_GOLDENROD :: Color{0.980392, 0.980392, 0.823529, 1}
COLOR_LIGHT_GRAY :: Color{0.827451, 0.827451, 0.827451, 1}
COLOR_LIGHT_GREEN :: Color{0.564706, 0.933333, 0.564706, 1}
COLOR_LIGHT_PINK :: Color{1, 0.713726, 0.756863, 1}
COLOR_LIGHT_SALMON :: Color{1, 0.627451, 0.478431, 1}
COLOR_LIGHT_SEA_GREEN :: Color{0.12549, 0.698039, 0.666667, 1}
COLOR_LIGHT_SKY_BLUE :: Color{0.529412, 0.807843, 0.980392, 1}
COLOR_LIGHT_SLATE_GRAY :: Color{0.466667, 0.533333, 0.6, 1}
COLOR_LIGHT_STEEL_BLUE :: Color{0.690196, 0.768627, 0.870588, 1}
COLOR_LIGHT_YELLOW :: Color{1, 1, 0.878431, 1}
COLOR_LIME :: Color{0, 1, 0, 1}
COLOR_LIME_GREEN :: Color{0.196078, 0.803922, 0.196078, 1}
COLOR_LINEN :: Color{0.980392, 0.941176, 0.901961, 1}
COLOR_MAGENTA :: Color{1, 0, 1, 1}
COLOR_MAROON :: Color{0.690196, 0.188235, 0.376471, 1}
COLOR_MEDIUM_AQUAMARINE :: Color{0.4, 0.803922, 0.666667, 1}
COLOR_MEDIUM_BLUE :: Color{0, 0, 0.803922, 1}
COLOR_MEDIUM_ORCHID :: Color{0.729412, 0.333333, 0.827451, 1}
COLOR_MEDIUM_PURPLE :: Color{0.576471, 0.439216, 0.858824, 1}
COLOR_MEDIUM_SEA_GREEN :: Color{0.235294, 0.701961, 0.443137, 1}
COLOR_MEDIUM_SLATE_BLUE :: Color{0.482353, 0.407843, 0.933333, 1}
COLOR_MEDIUM_SPRING_GREEN :: Color{0, 0.980392, 0.603922, 1}
COLOR_MEDIUM_TURQUOISE :: Color{0.282353, 0.819608, 0.8, 1}
COLOR_MEDIUM_VIOLET_RED :: Color{0.780392, 0.0823529, 0.521569, 1}
COLOR_MIDNIGHT_BLUE :: Color{0.0980392, 0.0980392, 0.439216, 1}
COLOR_MINT_CREAM :: Color{0.960784, 1, 0.980392, 1}
COLOR_MISTY_ROSE :: Color{1, 0.894118, 0.882353, 1}
COLOR_MOCCASIN :: Color{1, 0.894118, 0.709804, 1}
COLOR_NAVAJO_WHITE :: Color{1, 0.870588, 0.678431, 1}
COLOR_NAVY_BLUE :: Color{0, 0, 0.501961, 1}
COLOR_OLD_LACE :: Color{0.992157, 0.960784, 0.901961, 1}
COLOR_OLIVE :: Color{0.501961, 0.501961, 0, 1}
COLOR_OLIVE_DRAB :: Color{0.419608, 0.556863, 0.137255, 1}
COLOR_ORANGE :: Color{1, 0.647059, 0, 1}
COLOR_ORANGE_RED :: Color{1, 0.270588, 0, 1}
COLOR_ORCHID :: Color{0.854902, 0.439216, 0.839216, 1}
COLOR_PALE_GOLDENROD :: Color{0.933333, 0.909804, 0.666667, 1}
COLOR_PALE_GREEN :: Color{0.596078, 0.984314, 0.596078, 1}
COLOR_PALE_TURQUOISE :: Color{0.686275, 0.933333, 0.933333, 1}
COLOR_PALE_VIOLET_RED :: Color{0.858824, 0.439216, 0.576471, 1}
COLOR_PAPAYA_WHIP :: Color{1, 0.937255, 0.835294, 1}
COLOR_PEACH_PUFF :: Color{1, 0.854902, 0.72549, 1}
COLOR_PERU :: Color{0.803922, 0.521569, 0.247059, 1}
COLOR_PINK :: Color{1, 0.752941, 0.796078, 1}
COLOR_PLUM :: Color{0.866667, 0.627451, 0.866667, 1}
COLOR_POWDER_BLUE :: Color{0.690196, 0.878431, 0.901961, 1}
COLOR_PURPLE :: Color{0.627451, 0.12549, 0.941176, 1}
COLOR_REBECCA_PURPLE :: Color{0.4, 0.2, 0.6, 1}
COLOR_RED :: Color{1, 0, 0, 1}
COLOR_ROSY_BROWN :: Color{0.737255, 0.560784, 0.560784, 1}
COLOR_ROYAL_BLUE :: Color{0.254902, 0.411765, 0.882353, 1}
COLOR_SADDLE_BROWN :: Color{0.545098, 0.270588, 0.0745098, 1}
COLOR_SALMON :: Color{0.980392, 0.501961, 0.447059, 1}
COLOR_SANDY_BROWN :: Color{0.956863, 0.643137, 0.376471, 1}
COLOR_SEA_GREEN :: Color{0.180392, 0.545098, 0.341176, 1}
COLOR_SEASHELL :: Color{1, 0.960784, 0.933333, 1}
COLOR_SIENNA :: Color{0.627451, 0.321569, 0.176471, 1}
COLOR_SILVER :: Color{0.752941, 0.752941, 0.752941, 1}
COLOR_SKY_BLUE :: Color{0.529412, 0.807843, 0.921569, 1}
COLOR_SLATE_BLUE :: Color{0.415686, 0.352941, 0.803922, 1}
COLOR_SLATE_GRAY :: Color{0.439216, 0.501961, 0.564706, 1}
COLOR_SNOW :: Color{1, 0.980392, 0.980392, 1}
COLOR_SPRING_GREEN :: Color{0, 1, 0.498039, 1}
COLOR_STEEL_BLUE :: Color{0.27451, 0.509804, 0.705882, 1}
COLOR_TAN :: Color{0.823529, 0.705882, 0.54902, 1}
COLOR_TEAL :: Color{0, 0.501961, 0.501961, 1}
COLOR_THISTLE :: Color{0.847059, 0.74902, 0.847059, 1}
COLOR_TOMATO :: Color{1, 0.388235, 0.278431, 1}
COLOR_TRANSPARENT :: Color{1, 1, 1, 0}
COLOR_TURQUOISE :: Color{0.25098, 0.878431, 0.815686, 1}
COLOR_VIOLET :: Color{0.933333, 0.509804, 0.933333, 1}
COLOR_WEB_GRAY :: Color{0.501961, 0.501961, 0.501961, 1}
COLOR_WEB_GREEN :: Color{0, 0.501961, 0, 1}
COLOR_WEB_MAROON :: Color{0.501961, 0, 0, 1}
COLOR_WEB_PURPLE :: Color{0.501961, 0, 0.501961, 1}
COLOR_WHEAT :: Color{0.960784, 0.870588, 0.701961, 1}
COLOR_WHITE :: Color{1, 1, 1, 1}
COLOR_WHITE_SMOKE :: Color{0.960784, 0.960784, 0.960784, 1}
COLOR_YELLOW :: Color{1, 1, 0, 1}
COLOR_YELLOW_GREEN :: Color{0.603922, 0.803922, 0.196078, 1}

type_is_some_variant :: proc "contextless" (
    $T: typeid,
) -> bool where intrinsics.type_is_specialization_of(Packed_Array, T) ||
    intrinsics.type_is_variant_of(Variantable_Type, T) {
    return true
}

variant_from :: proc {
    variant_from_bool,
    variant_from_int,
    variant_from_float,
    variant_from_string,
    variant_from_vector2,
    variant_from_vector2i,
    variant_from_rect2,
    variant_from_rect2i,
    variant_from_vector3,
    variant_from_vector3i,
    variant_from_transform2d,
    variant_from_vector4,
    variant_from_vector4i,
    variant_from_plane,
    variant_from_quaternion,
    variant_from_aabb,
    variant_from_basis,
    variant_from_transform3d,
    variant_from_projection,
    variant_from_color,
    variant_from_string_name,
    variant_from_node_path,
    variant_from_rid,
    variant_from_object,
    variant_from_callable,
    variant_from_signal,
    variant_from_dictionary,
    variant_from_array,
    variant_from_packed_byte_array,
    variant_from_packed_int32_array,
    variant_from_packed_int64_array,
    variant_from_packed_float32_array,
    variant_from_packed_float64_array,
    variant_from_packed_string_array,
    variant_from_packed_vector2_array,
    variant_from_packed_vector3_array,
    variant_from_packed_color_array,
    variant_from_packed_vector4_array,
}

variant_from_bool :: proc "contextless" (from: ^bool) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Bool)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_int :: proc "contextless" (from: ^Int) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Int)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_float :: proc "contextless" (from: ^Float) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Float)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_string :: proc "contextless" (from: ^String) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.String)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_vector2 :: proc "contextless" (from: ^Vector2) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Vector2)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_vector2i :: proc "contextless" (from: ^Vector2i) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Vector2i)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_rect2 :: proc "contextless" (from: ^Rect2) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Rect2)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_rect2i :: proc "contextless" (from: ^Rect2i) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Rect2i)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_vector3 :: proc "contextless" (from: ^Vector3) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Vector3)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_vector3i :: proc "contextless" (from: ^Vector3i) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Vector3i)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_transform2d :: proc "contextless" (from: ^Transform2d) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Transform2d)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_vector4 :: proc "contextless" (from: ^Vector4) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Vector4)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_vector4i :: proc "contextless" (from: ^Vector4i) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Vector4i)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_plane :: proc "contextless" (from: ^Plane) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Plane)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_quaternion :: proc "contextless" (from: ^Quaternion) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Quaternion)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_aabb :: proc "contextless" (from: ^Aabb) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Aabb)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_basis :: proc "contextless" (from: ^Basis) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Basis)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_transform3d :: proc "contextless" (from: ^Transform3d) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Transform3d)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_projection :: proc "contextless" (from: ^Projection) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Projection)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_color :: proc "contextless" (from: ^Color) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Color)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_string_name :: proc "contextless" (from: ^String_Name) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.String_Name)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_node_path :: proc "contextless" (from: ^Node_Path) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Node_Path)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_rid :: proc "contextless" (from: ^Rid) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Rid)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_object :: proc "contextless" (from: ^Object) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Object)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_callable :: proc "contextless" (from: ^Callable) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Callable)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_signal :: proc "contextless" (from: ^Signal) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Signal)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_dictionary :: proc "contextless" (from: ^Dictionary) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Dictionary)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_array :: proc "contextless" (from: ^Array) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Array)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_packed_byte_array :: proc "contextless" (from: ^Packed_Byte_Array) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Packed_Byte_Array)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_packed_int32_array :: proc "contextless" (from: ^Packed_Int32_Array) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Packed_Int32_Array)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_packed_int64_array :: proc "contextless" (from: ^Packed_Int64_Array) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Packed_Int64_Array)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_packed_float32_array :: proc "contextless" (from: ^Packed_Float32_Array) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Packed_Float32_Array)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_packed_float64_array :: proc "contextless" (from: ^Packed_Float64_Array) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Packed_Float64_Array)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_packed_string_array :: proc "contextless" (from: ^Packed_String_Array) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Packed_String_Array)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_packed_vector2_array :: proc "contextless" (from: ^Packed_Vector2_Array) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Packed_Vector2_Array)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_packed_vector3_array :: proc "contextless" (from: ^Packed_Vector3_Array) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Packed_Vector3_Array)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_packed_color_array :: proc "contextless" (from: ^Packed_Color_Array) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Packed_Color_Array)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_from_packed_vector4_array :: proc "contextless" (from: ^Packed_Vector4_Array) -> (ret: Variant) {
    @(static) constructor: gd.VariantFromTypeConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_from_type_constructor(.Packed_Vector4_Array)
    }
    ret = Variant{}
    constructor(&ret, from)
    return
}

variant_into_ptr :: proc "contextless" (
    value: ^$V,
    ret: ^Variant,
) where intrinsics.type_is_specialization_of(Packed_Array, V) ||
    intrinsics.type_is_variant_of(Variantable_Type, V) {
    constructor := gd.get_variant_from_type_constructor(variant_type(V))
    constructor(cast(gd.UninitializedVariantPtr)ret, cast(gd.TypePtr)value)
}

// variant_to :: proc{
//     variant_to_bool,
//     variant_to_int,
//     variant_to_float,
//     variant_to_string,
//     variant_to_vector2,
//     variant_to_vector2i,
//     variant_to_rect2,
//     variant_to_rect2i,
//     variant_to_vector3,
//     variant_to_vector3i,
//     variant_to_transform2d,
//     variant_to_vector4,
//     variant_to_vector4i,
//     variant_to_plane,
//     variant_to_quaternion,
//     variant_to_aabb,
//     variant_to_basis,
//     variant_to_transform3d,
//     variant_to_projection,
//     variant_to_color,
//     variant_to_string_name,
//     variant_to_node_path,
//     variant_to_rid,
//     variant_to_object,
//     variant_to_callable,
//     variant_to_signal,
//     variant_to_dictionary,
//     variant_to_array,
//     variant_to_packed_byte_array,
//     variant_to_packed_int32_array,
//     variant_to_packed_int64_array,
//     variant_to_packed_float32_array,
//     variant_to_packed_float64_array,
//     variant_to_packed_string_array,
//     variant_to_packed_vector2_array,
//     variant_to_packed_vector3_array,
//     variant_to_packed_color_array,
//     variant_to_packed_vector4_array,
// }

variant_to :: proc "contextless" (
    from: ^Variant,
    $T: typeid,
    loc := #caller_location,
) -> (
    ret: T,
) where intrinsics.type_is_specialization_of(Packed_Array, T) ||
    intrinsics.type_is_variant_of(Variantable_Type, T) {
    when T == bool {
        return variant_to_bool(from)
    } else when T == i64 {
        return variant_to_int(from)
    } else when T == Float {
        return variant_to_float(from)
    } else when T == String {
        return variant_to_string(from)
    } else when T == Vector2 {
        return variant_to_vector2(from)
    } else when T == Vector2i {
        return variant_to_vector2i(from)
    } else when T == Rect2 {
        return variant_to_rect2(from)
    } else when T == Rect2i {
        return variant_to_rect2i(from)
    } else when T == Vector3 {
        return variant_to_vector3(from)
    } else when T == Vector3i {
        return variant_to_vector3i(from)
    } else when T == Transform2d {
        return variant_to_transform2d(from)
    } else when T == Vector4 {
        return variant_to_vector4(from)
    } else when T == Vector4i {
        return variant_to_vector4i(from)
    } else when T == Plane {
        return variant_to_plane(from)
    } else when T == Quaternion {
        return variant_to_quaternion(from)
    } else when T == Aabb {
        return variant_to_aabb(from)
    } else when T == Basis {
        return variant_to_basis(from)
    } else when T == Transform3d {
        return variant_to_transform3d(from)
    } else when T == Projection {
        return variant_to_projection(from)
    } else when T == Color {
        return variant_to_color(from)
    } else when T == String_Name {
        return variant_to_string_name(from)
    } else when T == Node_Path {
        return variant_to_node_path(from)
    } else when T == Rid {
        return variant_to_rid(from)
    } else when T == Object {
        return variant_to_object(from)
    } else when T == Callable {
        return variant_to_callable(from)
    } else when T == Signal {
        return variant_to_signal(from)
    } else when T == Dictionary {
        return variant_to_dictionary(from)
    } else when T == Array {
        return variant_to_array(from)
    } else when T == Packed_Byte_Array {
        return variant_to_packed_byte_array(from)
    } else when T == Packed_Int32_Array {
        return variant_to_packed_int32_array(from)
    } else when T == Packed_Int64_Array {
        return variant_to_packed_int64_array(from)
    } else when T == Packed_Float32_Array {
        return variant_to_packed_float32_array(from)
    } else when T == Packed_Float64_Array {
        return variant_to_packed_float64_array(from)
    } else when T == Packed_String_Array {
        return variant_to_packed_string_array(from)
    } else when T == Packed_Vector2_Array {
        return variant_to_packed_vector2_array(from)
    } else when T == Packed_Vector3_Array {
        return variant_to_packed_vector3_array(from)
    } else when T == Packed_Color_Array {
        return variant_to_packed_color_array(from)
    } else when T == Packed_Vector4_Array {
        return variant_to_packed_vector4_array(from)
    } else {
        #panic("invalid type in variant_to call", loc = loc)
    }
}

variant_to_bool :: proc "contextless" (from: ^Variant) -> (ret: bool) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Bool)
    }
    constructor(&ret, from)
    return
}

variant_to_int :: proc "contextless" (from: ^Variant) -> (ret: Int) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Int)
    }
    ret = Int{}
    constructor(&ret, from)
    return
}

variant_to_float :: proc "contextless" (from: ^Variant) -> (ret: Float) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Float)
    }
    ret = Float{}
    constructor(&ret, from)
    return
}

variant_to_string :: proc "contextless" (from: ^Variant) -> (ret: String) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.String)
    }
    ret = String{}
    constructor(&ret, from)
    return
}

variant_to_vector2 :: proc "contextless" (from: ^Variant) -> (ret: Vector2) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Vector2)
    }
    ret = Vector2{}
    constructor(&ret, from)
    return
}

variant_to_vector2i :: proc "contextless" (from: ^Variant) -> (ret: Vector2i) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Vector2i)
    }
    ret = Vector2i{}
    constructor(&ret, from)
    return
}

variant_to_rect2 :: proc "contextless" (from: ^Variant) -> (ret: Rect2) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Rect2)
    }
    ret = Rect2{}
    constructor(&ret, from)
    return
}

variant_to_rect2i :: proc "contextless" (from: ^Variant) -> (ret: Rect2i) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Rect2i)
    }
    ret = Rect2i{}
    constructor(&ret, from)
    return
}

variant_to_vector3 :: proc "contextless" (from: ^Variant) -> (ret: Vector3) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Vector3)
    }
    ret = Vector3{}
    constructor(&ret, from)
    return
}

variant_to_vector3i :: proc "contextless" (from: ^Variant) -> (ret: Vector3i) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Vector3i)
    }
    ret = Vector3i{}
    constructor(&ret, from)
    return
}

variant_to_transform2d :: proc "contextless" (from: ^Variant) -> (ret: Transform2d) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Transform2d)
    }
    ret = Transform2d{}
    constructor(&ret, from)
    return
}

variant_to_vector4 :: proc "contextless" (from: ^Variant) -> (ret: Vector4) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Vector4)
    }
    ret = Vector4{}
    constructor(&ret, from)
    return
}

variant_to_vector4i :: proc "contextless" (from: ^Variant) -> (ret: Vector4i) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Vector4i)
    }
    ret = Vector4i{}
    constructor(&ret, from)
    return
}

variant_to_plane :: proc "contextless" (from: ^Variant) -> (ret: Plane) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Plane)
    }
    ret = Plane{}
    constructor(&ret, from)
    return
}

variant_to_quaternion :: proc "contextless" (from: ^Variant) -> (ret: Quaternion) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Quaternion)
    }
    ret = Quaternion{}
    constructor(&ret, from)
    return
}

variant_to_aabb :: proc "contextless" (from: ^Variant) -> (ret: Aabb) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Aabb)
    }
    ret = Aabb{}
    constructor(&ret, from)
    return
}

variant_to_basis :: proc "contextless" (from: ^Variant) -> (ret: Basis) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Basis)
    }
    ret = Basis{}
    constructor(&ret, from)
    return
}

variant_to_transform3d :: proc "contextless" (from: ^Variant) -> (ret: Transform3d) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Transform3d)
    }
    ret = Transform3d{}
    constructor(&ret, from)
    return
}

variant_to_projection :: proc "contextless" (from: ^Variant) -> (ret: Projection) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Projection)
    }
    ret = Projection{}
    constructor(&ret, from)
    return
}

variant_to_color :: proc "contextless" (from: ^Variant) -> (ret: Color) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Color)
    }
    ret = Color{}
    constructor(&ret, from)
    return
}

variant_to_string_name :: proc "contextless" (from: ^Variant) -> (ret: String_Name) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.String_Name)
    }
    ret = String_Name{}
    constructor(&ret, from)
    return
}

variant_to_node_path :: proc "contextless" (from: ^Variant) -> (ret: Node_Path) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Node_Path)
    }
    ret = Node_Path{}
    constructor(&ret, from)
    return
}

variant_to_rid :: proc "contextless" (from: ^Variant) -> (ret: Rid) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Rid)
    }
    ret = Rid{}
    constructor(&ret, from)
    return
}

variant_to_object :: proc "contextless" (from: ^Variant) -> (ret: Object) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Object)
    }
    ret = Object{}
    constructor(&ret, from)
    return
}

variant_to_callable :: proc "contextless" (from: ^Variant) -> (ret: Callable) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Callable)
    }
    ret = Callable{}
    constructor(&ret, from)
    return
}

variant_to_signal :: proc "contextless" (from: ^Variant) -> (ret: Signal) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Signal)
    }
    ret = Signal{}
    constructor(&ret, from)
    return
}

variant_to_dictionary :: proc "contextless" (from: ^Variant) -> (ret: Dictionary) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Dictionary)
    }
    ret = Dictionary{}
    constructor(&ret, from)
    return
}

variant_to_array :: proc "contextless" (from: ^Variant) -> (ret: Array) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Array)
    }
    ret = Array{}
    constructor(&ret, from)
    return
}

variant_to_packed_byte_array :: proc "contextless" (from: ^Variant) -> (ret: Packed_Byte_Array) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Packed_Byte_Array)
    }
    ret = Packed_Byte_Array{}
    constructor(&ret, from)
    return
}

variant_to_packed_int32_array :: proc "contextless" (from: ^Variant) -> (ret: Packed_Int32_Array) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Packed_Int32_Array)
    }
    ret = Packed_Int32_Array{}
    constructor(&ret, from)
    return
}

variant_to_packed_int64_array :: proc "contextless" (from: ^Variant) -> (ret: Packed_Int64_Array) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Packed_Int64_Array)
    }
    ret = Packed_Int64_Array{}
    constructor(&ret, from)
    return
}

variant_to_packed_float32_array :: proc "contextless" (from: ^Variant) -> (ret: Packed_Float32_Array) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Packed_Float32_Array)
    }
    ret = Packed_Float32_Array{}
    constructor(&ret, from)
    return
}

variant_to_packed_float64_array :: proc "contextless" (from: ^Variant) -> (ret: Packed_Float64_Array) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Packed_Float64_Array)
    }
    ret = Packed_Float64_Array{}
    constructor(&ret, from)
    return
}

variant_to_packed_string_array :: proc "contextless" (from: ^Variant) -> (ret: Packed_String_Array) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Packed_String_Array)
    }
    ret = Packed_String_Array{}
    constructor(&ret, from)
    return
}

variant_to_packed_vector2_array :: proc "contextless" (from: ^Variant) -> (ret: Packed_Vector2_Array) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Packed_Vector2_Array)
    }
    ret = Packed_Vector2_Array{}
    constructor(&ret, from)
    return
}

variant_to_packed_vector3_array :: proc "contextless" (from: ^Variant) -> (ret: Packed_Vector3_Array) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Packed_Vector3_Array)
    }
    ret = Packed_Vector3_Array{}
    constructor(&ret, from)
    return
}

variant_to_packed_color_array :: proc "contextless" (from: ^Variant) -> (ret: Packed_Color_Array) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Packed_Color_Array)
    }
    ret = Packed_Color_Array{}
    constructor(&ret, from)
    return
}

variant_to_packed_vector4_array :: proc "contextless" (from: ^Variant) -> (ret: Packed_Vector4_Array) {
    @(static) constructor: gd.TypeFromVariantConstructorProc
    if constructor == nil {
        constructor = gd.get_variant_to_type_constructor(.Packed_Vector4_Array)
    }
    ret = Packed_Vector4_Array{}
    constructor(&ret, from)
    return
}

variant_type :: proc "contextless" (
    $T: typeid,
) -> gd.Variant_Type where intrinsics.type_is_specialization_of(Packed_Array, T) ||
    intrinsics.type_is_variant_of(Variantable_Type, T) {
    when T == bool {
        return .Bool
    } else when T == Int {
        return .Int
    } else when T == Float {
        return .Float
    } else when T == String {
        return .String
    } else when T == Vector2 {
        return .Vector2
    } else when T == Vector2i {
        return .Vector2i
    } else when T == Rect2 {
        return .Rect2
    } else when T == Rect2i {
        return .Rect2i
    } else when T == Vector3 {
        return .Vector3
    } else when T == Vector3i {
        return .Vector3i
    } else when T == Transform2d {
        return .Transform2d
    } else when T == Vector4 {
        return .Vector4
    } else when T == Vector4i {
        return .Vector4i
    } else when T == Plane {
        return .Plane
    } else when T == Quaternion {
        return .Quaternion
    } else when T == Aabb {
        return .Aabb
    } else when T == Basis {
        return .Basis
    } else when T == Transform3d {
        return .Transform3d
    } else when T == Projection {
        return .Projection
    } else when T == Color {
        return .Color
    } else when T == String_Name {
        return .String_Name
    } else when T == Node_Path {
        return .Node_Path
    } else when T == Rid {
        return .Rid
    } else when T == Object {
        return .Object
    } else when T == Callable {
        return .Callable
    } else when T == Signal {
        return .Signal
    } else when T == Dictionary {
        return .Dictionary
    } else when T == Array {
        return .Array
    } else when T == Packed_Byte_Array {
        return .Packed_Byte_Array
    } else when T == Packed_Int32_Array {
        return .Packed_Int32_Array
    } else when T == Packed_Int64_Array {
        return .Packed_Int64_Array
    } else when T == Packed_Float32_Array {
        return .Packed_Float32_Array
    } else when T == Packed_Float64_Array {
        return .Packed_Float64_Array
    } else when T == Packed_String_Array {
        return .Packed_String_Array
    } else when T == Packed_Vector2_Array {
        return .Packed_Vector2_Array
    } else when T == Packed_Vector3_Array {
        return .Packed_Vector3_Array
    } else when T == Packed_Color_Array {
        return .Packed_Color_Array
    } else {
        #panic("Unknown type passed to variant_type")
    }
}

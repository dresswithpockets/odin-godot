package gdextension

import "core:c"

BUILD_CONFIG :: #config(BUILD_CONFIG, "float_64")

// In this API there are multiple functions which expect the caller to pass a pointer
// on return value as parameter.
// In order to make it clear if the caller should initialize the return value or not
// we have two flavor of types:
// - `GDExtensionXXXPtr` for pointer on an initialized value
// - `GDExtensionUninitializedXXXPtr` for pointer on uninitialized value
//
// Notes:
// - Not respecting those requirements can seems harmless, but will lead to unexpected
//   segfault or memory leak (for instance with a specific compiler/OS, or when two
//   native extensions start doing ptrcall on each other).
// - Initialization must be done with the function pointer returned by `variant_get_ptr_constructor`,
//   zero-initializing the variable should not be considered a valid initialization method here !
// - Some types have no destructor (see `extension_api.json`'s `has_destructor` field), for
//   them it is always safe to skip the constructor for the return value if you are in a hurry ;-)

VariantPtr :: rawptr
UninitializedVariantPtr :: rawptr
StringNamePtr :: rawptr
UninitializedStringNamePtr :: rawptr
StringPtr :: rawptr
UninitializedStringPtr :: rawptr
ObjectPtr :: rawptr
UninitializedObjectPtr :: rawptr
TypePtr :: rawptr
UninitializedTypePtr :: rawptr

ObjectInstanceId :: u64
MethodBindPtr :: rawptr
RefPtr :: rawptr

Variant_Type :: enum u64 {
    Nil,

    /* atomic types */
    Bool,
    Int,
    Float,
    String,

    /* math types */
    Vector2,
    Vector2i,
    Rect2,
    Rect2i,
    Vector3,
    Vector3i,
    Transform2d,
    Vector4,
    Vector4i,
    Plane,
    Quaternion,
    Aabb,
    Basis,
    Transform3d,
    Projection,

    /* misc types */
    Color,
    String_Name,
    Node_Path,
    Rid,
    Object,
    Callable,
    Signal,
    Dictionary,
    Array,

    /* typed arrays */
    Packed_Byte_Array,
    Packed_Int32_Array,
    Packed_Int64_Array,
    Packed_Float32_Array,
    Packed_Float64_Array,
    Packed_String_Array,
    Packed_Vector2_Array,
    Packed_Vector3_Array,
    Packed_Color_Array,
    Packed_Vector4_Array,

    /* enum max */
    Variant_Max,
}

VariantOperator :: enum c.int {
    /* comparison */
    Equal,
    Not_Equal,
    Less,
    Less_Equal,
    Greater,
    Greater_Equal,

    /* mathematic */
    Add,
    Subtract,
    Multiply,
    Divide,
    Negate,
    Positive,
    Module,
    Power,

    /* bitwise */
    Shift_Left,
    Shift_Right,
    Bit_And,
    Bit_Or,
    Bit_Xor,
    Bit_Negate,

    /* logic */
    And,
    Or,
    Xor,
    Not,

    /* containment */
    In,
    Max,
}

CallErrorType :: enum c.int {
    Ok,
    Invalid_Method,
    Invalid_Argument,
    Too_Many_Arguments,
    Too_Few_Arguments,
    Instance_Is_Null,
    Method_Not_Const,
}

CallError :: struct {
    error:    CallErrorType,
    argument: i32,
    expected: i32,
}

VariantFromTypeConstructorProc :: #type proc "c" (variant: UninitializedVariantPtr, type: TypePtr)
TypeFromVariantConstructorProc :: #type proc "c" (type: TypePtr, variant: VariantPtr)
VariantGetInternalPtrFunc :: #type proc "c" (variant: VariantPtr) -> rawptr
PtrOperatorEvaluator :: #type proc "c" (left: TypePtr, right: TypePtr, result: TypePtr)
PtrBuiltInMethod :: #type proc "c" (base: TypePtr, args: ^TypePtr, returns: TypePtr, arg_count: int)
PtrConstructor :: #type proc "c" (base: UninitializedTypePtr, args: ^TypePtr)
PtrDestructor :: #type proc "c" (base: TypePtr)
PtrSetter :: #type proc "c" (base: TypePtr, value: TypePtr)
PtrGetter :: #type proc "c" (base: TypePtr, value: TypePtr)
PtrIndexedSetter :: #type proc "c" (base: TypePtr, index: i64, value: TypePtr)
PtrIndexedGetter :: #type proc "c" (base: TypePtr, key: TypePtr, value: TypePtr)
PtrKeyedSetter :: #type proc "c" (base: TypePtr, key: TypePtr, value: TypePtr)
PtrKeyedGetter :: #type proc "c" (base: TypePtr, key: TypePtr, value: TypePtr)
PtrKeyedChecker :: #type proc "c" (base: VariantPtr, key: VariantPtr) -> u32
PtrUtilityFunction :: #type proc "c" (returns: TypePtr, args: [^]TypePtr, arg_count: int)

ClassConstructor :: #type proc "c" () -> ObjectPtr

InstanceBindingCreateCallback :: #type proc "c" (token: rawptr, instance: rawptr) -> rawptr
InstanceBindingFreeCallback :: #type proc "c" (token: rawptr, instance: rawptr, binding: rawptr)
InstanceBindingReferenceCallback :: #type proc "c" (token: rawptr, binding: rawptr, reference: bool) -> bool

InstanceBindingCallbacks :: struct {
    create:    InstanceBindingCreateCallback,
    free:      InstanceBindingFreeCallback,
    reference: InstanceBindingReferenceCallback,
}

// Extension Classes

ExtensionClassInstancePtr :: rawptr

ExtensionClassSet :: #type proc "c" (
    instance: ExtensionClassInstancePtr,
    name: StringNamePtr,
    value: VariantPtr,
) -> bool
ExtensionClassGet :: #type proc "c" (instance: ExtensionClassInstancePtr, name: StringNamePtr, ret: VariantPtr) -> bool
ExtensionClassGetRid :: #type proc "c" (instance: ExtensionClassInstancePtr) -> u64

PropertyInfo :: struct {
    type:        Variant_Type,
    name:        StringNamePtr,
    class_name:  StringNamePtr,
    // bitfield of PropertyHint (defined in extension_api.json)
    hint:        u32,
    hint_string: StringPtr,
    // bitfield of PropertyUsageFlags (defined in extension_api.json)
    usage:       u32,
}

MethodInfo :: struct {
    name:                   StringNamePtr,
    return_value:           PropertyInfo,
    // bitfield of ExtensionClassMethodFlags
    flags:                  u32,
    id:                     i32,
    argument_count:         u32,
    arguments:              [^]PropertyInfo,
    default_argument_count: u32,
    default_arguments:      [^]VariantPtr,
}

ExtensionClassGetPropertyList :: #type proc "c" (instance: ExtensionClassInstancePtr, count: ^u32) -> [^]PropertyInfo
ExtensionClassFreePropertyList :: #type proc "c" (instance: ExtensionClassInstancePtr, list: ^PropertyInfo)
ExtensionClassFreePropertyList2 :: #type proc "c" (
    instance: ExtensionClassInstancePtr,
    list: ^PropertyInfo,
    count: c.uint32_t,
)
ExtensionClassPropertyCanRevert :: #type proc "c" (instance: ExtensionClassInstancePtr, name: StringNamePtr) -> bool
ExtensionClassPropertyGetRevert :: #type proc "c" (
    instance: ExtensionClassInstancePtr,
    name: StringNamePtr,
    ret: VariantPtr,
) -> bool
ExtensionClassValidateProperty :: #type proc "c" (instance: ExtensionClassInstancePtr, property: ^PropertyInfo) -> bool
// ExtensionClassNotification is deprecated, use ExtensionClassNotification2 instead
ExtensionClassNotification :: #type proc "c" (instance: ExtensionClassInstancePtr, what: i32)
ExtensionClassNotification2 :: #type proc "c" (instance: ExtensionClassInstancePtr, what: i32, reversed: bool)
ExtensionClassToString :: #type proc "c" (instance: ExtensionClassInstancePtr, is_valid: ^bool, out: StringPtr)
ExtensionClassReference :: #type proc "c" (instance: ExtensionClassInstancePtr)
ExtensionClassUnreference :: #type proc "c" (instance: ExtensionClassInstancePtr)
ExtensionClassCallVirtual :: #type proc "c" (instance: ExtensionClassInstancePtr, args: [^]TypePtr, ret: TypePtr)
ExtensionClassCreateInstance :: #type proc "c" (class_user_data: rawptr) -> ObjectPtr
ExtensionClassCreateInstance2 :: #type proc "c" (class_user_data: rawptr, notify_postinitialize: bool) -> ObjectPtr
ExtensionClassFreeInstance :: #type proc "c" (class_user_data: rawptr, instance: ExtensionClassInstancePtr)
ExtensionClassRecreateInstance :: #type proc "c" (
    class_user_data: rawptr,
    object: ObjectPtr,
) -> ExtensionClassInstancePtr
ExtensionClassGetVirtual :: #type proc "c" (class_user_data: rawptr, name: StringNamePtr) -> ExtensionClassCallVirtual
ExtensionClassGetVirtual2 :: #type proc "c" (class_user_data: rawptr, name: StringNamePtr, hash: rawptr) -> ExtensionClassCallVirtual
ExtensionClassGetVirtualCallData :: #type proc "c" (class_user_data: rawptr, name: StringNamePtr) -> rawptr
ExtensionClassGetVirtualCallData2 :: #type proc "c" (class_user_data: rawptr, name: StringNamePtr, hash: u32) -> rawptr
ExtensionClassCallVirtualWithData :: #type proc "c" (
    instance: ExtensionClassInstancePtr,
    name: StringNamePtr,
    virtual_call_userdata: rawptr,
    args: [^]TypePtr,
    ret: TypePtr,
)

// Deprecated. Use ExtensionClassCreationInfo4 instead.
ExtensionClassCreationInfo :: struct {
    is_virtual:               bool,
    is_abstract:              bool,
    set_func:                 ExtensionClassSet,
    get_func:                 ExtensionClassGet,
    get_property_list_func:   ExtensionClassGetPropertyList,
    free_property_list_func:  ExtensionClassFreePropertyList,
    property_can_revert_func: ExtensionClassPropertyCanRevert,
    property_get_revert_func: ExtensionClassPropertyGetRevert,
    notification_func:        ExtensionClassNotification,
    to_string_func:           ExtensionClassToString,
    reference_func:           ExtensionClassReference,
    unreference_func:         ExtensionClassUnreference,
    // (Default) constructor; mandatory. If the class is not instantiable, consider making it virtual or abstract.
    create_instance_func:     ExtensionClassCreateInstance,
    // Destructor; mandatory.
    free_instance_func:       ExtensionClassFreeInstance,
    // Queries a virtual function by name and returns a callback to invoke the requested virtual function.
    get_virtual_func:         ExtensionClassGetVirtual,
    get_rid_func:             ExtensionClassGetRid,
    // Per-class user data, later accessible in instance bindings.
    class_user_data:          rawptr,
}

// Deprecated. Use ExtensionClassCreationInfo4 instead.
ExtensionClassCreationInfo2 :: struct {
    is_virtual:                  bool,
    is_abstract:                 bool,
    is_exposed:                  bool,
    set_func:                    ExtensionClassSet,
    get_func:                    ExtensionClassGet,
    get_property_list_func:      ExtensionClassGetPropertyList,
    free_property_list_func:     ExtensionClassFreePropertyList,
    property_can_revert_func:    ExtensionClassPropertyCanRevert,
    property_get_revert_func:    ExtensionClassPropertyGetRevert,
    validate_property_func:      ExtensionClassValidateProperty,
    notification_func:           ExtensionClassNotification2,
    to_string_func:              ExtensionClassToString,
    reference_func:              ExtensionClassReference,
    unreference_func:            ExtensionClassUnreference,
    create_instance_func:        ExtensionClassCreateInstance, // (Default) constructor; mandatory. If the class is not instantiable, consider making it virtual or abstract.
    free_instance_func:          ExtensionClassFreeInstance, // Destructor; mandatory.
    recreate_instance_func:      ExtensionClassRecreateInstance,
    // Queries a virtual function by name and returns a callback to invoke the requested virtual function.
    get_virtual_func:            ExtensionClassGetVirtual,
    // Paired with `call_virtual_with_data_func`, this is an alternative to `get_virtual_func` for extensions that
    // need or benefit from extra data when calling virtual functions.
    // Returns user data that will be passed to `call_virtual_with_data_func`.
    // Returning `NULL` from this function signals to Godot that the virtual function is not overridden.
    // Data returned from this function should be managed by the extension and must be valid until the extension is deinitialized.
    // You should supply either `get_virtual_func`, or `get_virtual_call_data_func` with `call_virtual_with_data_func`.
    get_virtual_call_data_func:  ExtensionClassGetVirtualCallData,
    // Used to call virtual functions when `get_virtual_call_data_func` is not null.
    call_virtual_with_data_func: ExtensionClassCallVirtualWithData,
    get_rid_func:                ExtensionClassGetRid,
    class_userdata:              rawptr, // Per-class user data, later accessible in instance bindings.
}

// Deprecated. Use ExtensionClassCreationInfo4 instead.
ExtensionClassCreationInfo3 :: struct {
    is_virtual:                  bool,
    is_abstract:                 bool,
    is_exposed:                  bool,
    is_runtime:                  bool,
    set_func:                    ExtensionClassSet,
    get_func:                    ExtensionClassGet,
    get_property_list_func:      ExtensionClassGetPropertyList,
    free_property_list_func:     ExtensionClassFreePropertyList2,
    property_can_revert_func:    ExtensionClassPropertyCanRevert,
    property_get_revert_func:    ExtensionClassPropertyGetRevert,
    validate_property_func:      ExtensionClassValidateProperty,
    notification_func:           ExtensionClassNotification2,
    to_string_func:              ExtensionClassToString,
    reference_func:              ExtensionClassReference,
    unreference_func:            ExtensionClassUnreference,
    create_instance_func:        ExtensionClassCreateInstance, // (Default) constructor; mandatory. If the class is not instantiable, consider making it virtual or abstract.
    free_instance_func:          ExtensionClassFreeInstance, // Destructor; mandatory.
    recreate_instance_func:      ExtensionClassRecreateInstance,
    // Queries a virtual function by name and returns a callback to invoke the requested virtual function.
    get_virtual_func:            ExtensionClassGetVirtual,
    // Paired with `call_virtual_with_data_func`, this is an alternative to `get_virtual_func` for extensions that
    // need or benefit from extra data when calling virtual functions.
    // Returns user data that will be passed to `call_virtual_with_data_func`.
    // Returning `NULL` from this function signals to Godot that the virtual function is not overridden.
    // Data returned from this function should be managed by the extension and must be valid until the extension is deinitialized.
    // You should supply either `get_virtual_func`, or `get_virtual_call_data_func` with `call_virtual_with_data_func`.
    get_virtual_call_data_func:  ExtensionClassGetVirtualCallData,
    // Used to call virtual functions when `get_virtual_call_data_func` is not null.
    call_virtual_with_data_func: ExtensionClassCallVirtualWithData,
    get_rid_func:                ExtensionClassGetRid,
    class_userdata:              rawptr, // Per-class user data, later accessible in instance bindings.
}

ExtensionClassCreationInfo4 :: struct {
    is_virtual: bool,
    is_abstract: bool,
    is_exposed: bool,
    is_runtime: bool,
    icon_path: StringPtr,
    set_func: ExtensionClassSet,
    get_func: ExtensionClassGet,
    get_property_list_func: ExtensionClassGetPropertyList,
    free_property_list_func: ExtensionClassFreePropertyList2,
    property_can_revert_func: ExtensionClassPropertyCanRevert,
    property_get_revert_func: ExtensionClassPropertyGetRevert,
    validate_property_func: ExtensionClassValidateProperty,
    notification_func: ExtensionClassNotification2,
    to_string_func: ExtensionClassToString,
    reference_func: ExtensionClassReference,
    unreference_func: ExtensionClassUnreference,
    create_instance_func: ExtensionClassCreateInstance2, // (Default) constructor; mandatory. If the class is not instantiable, consider making it virtual or abstract.
    free_instance_func: ExtensionClassFreeInstance, // Destructor; mandatory.
    recreate_instance_func: ExtensionClassRecreateInstance,
    // Queries a virtual function by name and returns a callback to invoke the requested virtual function.
    get_virtual_func: ExtensionClassGetVirtual2,
    // Paired with `call_virtual_with_data_func`, this is an alternative to `get_virtual_func` for extensions that
    // need or benefit from extra data when calling virtual functions.
    // Returns user data that will be passed to `call_virtual_with_data_func`.
    // Returning `NULL` from this function signals to Godot that the virtual function is not overridden.
    // Data returned from this function should be managed by the extension and must be valid until the extension is deinitialized.
    // You should supply either `get_virtual_func`, or `get_virtual_call_data_func` with `call_virtual_with_data_func`.
    get_virtual_call_data_func: ExtensionClassGetVirtualCallData2,
    // Used to call virtual functions when `get_virtual_call_data_func` is not null.
    call_virtual_with_data_func: ExtensionClassCallVirtualWithData,
    class_userdata: rawptr, // Per-class user data, later accessible in instance bindings.
}

ExtensionClassLibraryPtr :: distinct rawptr

// Method

ExtensionClassMethodFlags :: enum c.int {
    Normal  = 1,
    Editor  = 2,
    Const   = 4,
    Virtual = 8,
    Vararg  = 16,
    Static  = 32,
    Default = Normal,
}

ExtensionClassMethodArgumentMetadata :: enum c.int {
    None,
    Int_Is_Int8,
    Int_Is_Int16,
    Int_Is_Int32,
    Int_Is_Int64,
    Int_Is_UInt8,
    Int_Is_UInt16,
    Int_Is_UInt32,
    Int_Is_UInt64,
    Real_Is_Float,
    Real_Is_Double,
}

ExtensionClassMethodCall :: #type proc "c" (
    method_user_data: rawptr,
    instance: ExtensionClassInstancePtr,
    args: [^]VariantPtr,
    argument_count: i64,
    ret: VariantPtr,
    error: ^CallError,
)
ExtensionClassMethodValidateCall :: #type proc "c" (
    method_user_data: rawptr,
    instance: ExtensionClassInstancePtr,
    args: [^]VariantPtr,
    ret: VariantPtr,
)
ExtensionClassMethodPtrCall :: #type proc "c" (
    method_user_data: rawptr,
    instance: ExtensionClassInstancePtr,
    args: [^]TypePtr,
    ret: TypePtr,
)

ExtensionClassMethodInfo :: struct {
    name:                   StringNamePtr,
    method_user_data:       rawptr,
    call_func:              ExtensionClassMethodCall,
    ptr_call_func:          ExtensionClassMethodPtrCall,
    // bitfield of ExtensionClassMethodFlags 
    method_flags:           c.uint32_t,

    /* If `has_return_value` is false, `return_value_info` and `return_value_metadata` are ignored.
	 *
	 * @todo Consider dropping `has_return_value` and making the other two properties match `GDExtensionMethodInfo` and `GDExtensionClassVirtualMethod` for consistency in future version of this struct.
	 */
    has_return_value:       c.bool,
    return_value_info:      ^PropertyInfo,
    return_value_metadata:  ExtensionClassMethodArgumentMetadata,

    /* Arguments: `arguments_info` and `arguments_metadata` are array of size `argument_count`.
     * Name and hint information for the argument can be omitted in release builds. Class name should always be present if it applies.
	 *
	 * @todo Consider renaming `arguments_info` to `arguments` for consistency in future version of this struct.
	 */
    argument_count:         c.uint32_t,
    arguments_info:         [^]PropertyInfo,
    arguments_metadata:     [^]ExtensionClassMethodArgumentMetadata,

    // Default arguments: `default_arguments` is an array of size `default_argument_count`.
    default_argument_count: c.uint32_t,
    default_arguments:      [^]VariantPtr,
}

ExtensionClassVirtualMethodInfo :: struct {
    name:                  StringNamePtr,
    method_flags:          c.uint32_t, // Bitfield of `GDExtensionClassMethodFlags`.
    return_value:          PropertyInfo,
    return_value_metadata: ExtensionClassMethodArgumentMetadata,
    argument_count:        c.uint32_t,
    arguments:             [^]PropertyInfo,
    arguments_metadata:    [^]ExtensionClassMethodArgumentMetadata,
}

ExtensionCallableCustomCall :: #type proc "c" (
    callable_userdata: rawptr,
    args: [^]VariantPtr,
    arg_count: i64,
    ret: VariantPtr,
    error: ^CallError,
)
ExtensionCallableCustomIsValid :: #type proc "c" (callable_userdata: rawptr) -> bool
ExtensionCallableCustomFree :: #type proc "c" (callable_userdata: rawptr)

ExtensionCallableCustomHash :: #type proc "c" (callable_userdata: rawptr) -> c.uint32_t
ExtensionCallableCustomEqual :: #type proc "c" (callable_userdata_a, callable_userdata_b: rawptr) -> bool
ExtensionCallableCustomLessThan :: #type proc "c" (callable_userdata_a, callable_userdata_b: rawptr) -> bool

ExtensionCallableCustomToString :: #type proc "c" (callable_userdata: rawptr, is_valid: ^bool, out: StringPtr)

ExtensionCallableCustomGetArgumentCount :: #type proc "c" (callable_userdata: rawptr, is_valid: ^bool) -> i64

// Deprecated. Use ExtensionCallableCustomInfo2 instead.
ExtensionCallableCustomInfo :: struct {
    /* Only `call_func` and `token` are strictly required, however, `object_id` should be passed if its not a static method.
     *
     * `token` should point to an address that uniquely identifies the GDExtension (for example, the
     * `ExtensionClassLibraryPtr` passed to the entry symbol function.
     *
     * `hash_func`, `equal_func`, and `less_than_func` are optional. If not provided both `call_func` and
     * `callable_userdata` together are used as the identity of the callable for hashing and comparison purposes.
     *
     * The hash returned by `hash_func` is cached, `hash_func` will not be called more than once per callable.
     *
     * `is_valid_func` is necessary if the validity of the callable can change before destruction.
     *
     * `free_func` is necessary if `callable_userdata` needs to be cleaned up when the callable is freed.
     */
    callable_userdata: rawptr,
    token:             rawptr,
    object_id:         c.uint64_t,
    call_func:         ExtensionCallableCustomCall,
    is_valid_func:     ExtensionCallableCustomIsValid,
    free_func:         ExtensionCallableCustomFree,
    hash_func:         ExtensionCallableCustomHash,
    equal_func:        ExtensionCallableCustomEqual,
    less_than_func:    ExtensionCallableCustomLessThan,
    to_string_func:    ExtensionCallableCustomToString,
}

ExtensionCallableCustomInfo2 :: struct {
    /* Only `call_func` and `token` are strictly required, however, `object_id` should be passed if its not a static method.
     *
     * `token` should point to an address that uniquely identifies the GDExtension (for example, the
     * `ExtensionClassLibraryPtr` passed to the entry symbol function.
     *
     * `hash_func`, `equal_func`, and `less_than_func` are optional. If not provided both `call_func` and
     * `callable_userdata` together are used as the identity of the callable for hashing and comparison purposes.
     *
     * The hash returned by `hash_func` is cached, `hash_func` will not be called more than once per callable.
     *
     * `is_valid_func` is necessary if the validity of the callable can change before destruction.
     *
     * `free_func` is necessary if `callable_userdata` needs to be cleaned up when the callable is freed.
     */
    callable_userdata:       rawptr,
    token:                   rawptr,
    object_id:               c.uint64_t,
    call_func:               ExtensionCallableCustomCall,
    is_valid_func:           ExtensionCallableCustomIsValid,
    free_func:               ExtensionCallableCustomFree,
    hash_func:               ExtensionCallableCustomHash,
    equal_func:              ExtensionCallableCustomEqual,
    less_than_func:          ExtensionCallableCustomLessThan,
    to_string_func:          ExtensionCallableCustomToString,
    get_argument_count_func: ExtensionCallableCustomGetArgumentCount,
}

/* SCRIPT INSTANCE EXTENSION */

// Pointer to custom ScriptInstance native implementation.
ExtensionScriptInstanceDataPtr :: distinct rawptr

ExtensionScriptInstanceSet :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    name: StringNamePtr,
    value: VariantPtr,
) -> bool
ExtensionScriptInstanceGet :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    name: StringNamePtr,
    ret: VariantPtr,
) -> bool
ExtensionScriptInstanceGetPropertyList :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    count: ^u32,
) -> [^]PropertyInfo
// Deprecated. Use ExtensionScriptInstanceFreePropertyList2 instead.
ExtensionScriptInstanceFreePropertyList :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    list: ^PropertyInfo,
)
ExtensionScriptInstanceFreePropertyList2 :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    list: ^PropertyInfo,
    count: u32,
)
ExtensionScriptInstanceGetClassCategory :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    class_category: ^PropertyInfo,
) -> bool
ExtensionScriptInstanceGetPropertyType :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    name: StringNamePtr,
    is_valid: ^bool,
) -> Variant_Type
ExtensionScriptInstanceValidateProperty :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    property: ^PropertyInfo,
) -> bool
ExtensionScriptInstancePropertyCanRevert :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    name: StringNamePtr,
) -> bool
ExtensionScriptInstancePropertyGetRevert :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    name: StringNamePtr,
    ret: VariantPtr,
) -> bool
ExtensionScriptInstanceGetOwner :: #type proc "c" (instance: ExtensionScriptInstanceDataPtr) -> ObjectPtr
ExtensionScriptInstancePropertyStateAdd :: #type proc "c" (name: StringNamePtr, value: VariantPtr, user_data: rawptr)
ExtensionScriptInstanceGetPropertyState :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    add_func: ExtensionScriptInstancePropertyStateAdd,
    user_data: rawptr,
)

ExtensionScriptInstanceGetMethodList :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    count: ^u32,
) -> [^]MethodInfo
// Deprecated. Use ExtensionScriptInstanceFreeMethodList2 instead.
ExtensionScriptInstanceFreeMethodList :: #type proc "c" (instance: ExtensionScriptInstanceDataPtr, list: ^MethodInfo)
ExtensionScriptInstanceFreeMethodList2 :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    list: ^MethodInfo,
    count: u32,
)

ExtensionScriptInstanceHasMethod :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    name: StringNamePtr,
) -> bool

ExtensionScriptInstanceGetMethodArgumentCount :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    name: StringNamePtr,
    is_valid: ^bool,
) -> i64

ExtensionScriptInstanceCall :: #type proc "c" (
    self: ExtensionScriptInstanceDataPtr,
    method: StringNamePtr,
    args: [^]VariantPtr,
    argument_count: i64,
    ret: VariantPtr,
    error: ^CallError,
)
// Deprecated. Use ExtensionScriptInstanceNotification2 instead
ExtensionScriptInstanceNotification :: #type proc "c" (instance: ExtensionScriptInstanceDataPtr, what: i32)
ExtensionScriptInstanceNotification2 :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    what: i32,
    reversed: bool,
)
ExtensionScriptInstanceToString :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    is_valid: ^bool,
    out: StringPtr,
)

ExtensionScriptInstanceRefCountIncremented :: #type proc "c" (instance: ExtensionScriptInstanceDataPtr)
ExtensionScriptInstanceRefCountDecremented :: #type proc "c" (instance: ExtensionScriptInstanceDataPtr) -> bool

ExtensionScriptInstanceGetScript :: #type proc "c" (instance: ExtensionScriptInstanceDataPtr) -> ObjectPtr
ExtensionScriptInstanceIsPlaceholder :: #type proc "c" (instance: ExtensionScriptInstanceDataPtr) -> bool

ExtensionScriptLanguagePtr :: distinct rawptr

ExtensionScriptInstanceGetLanguage :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
) -> ExtensionScriptLanguagePtr

ExtensionScriptInstanceFree :: #type proc "c" (instance: ExtensionScriptInstanceDataPtr)

// Pointer to ScriptInstance.
ScriptInstancePtr :: distinct rawptr

// Deprecated. Use ExtensionScriptInstanceInfo3 instead.
ExtensionScriptInstanceInfo :: struct {
    set_func:                  ExtensionScriptInstanceSet,
    get_func:                  ExtensionScriptInstanceGet,
    get_property_list_func:    ExtensionScriptInstanceGetPropertyList,
    free_property_list_func:   ExtensionScriptInstanceFreePropertyList,
    property_can_revert_func:  ExtensionScriptInstancePropertyCanRevert,
    property_get_revert_func:  ExtensionScriptInstancePropertyGetRevert,
    get_owner_func:            ExtensionScriptInstanceGetOwner,
    get_property_state_func:   ExtensionScriptInstanceGetPropertyState,
    get_method_list_func:      ExtensionScriptInstanceGetMethodList,
    free_method_list_func:     ExtensionScriptInstanceFreeMethodList,
    get_property_type_func:    ExtensionScriptInstanceGetPropertyType,
    has_method_func:           ExtensionScriptInstanceHasMethod,
    call_func:                 ExtensionScriptInstanceCall,
    notification_func:         ExtensionScriptInstanceNotification,
    to_string_func:            ExtensionScriptInstanceToString,
    refcount_incremented_func: ExtensionScriptInstanceRefCountIncremented,
    refcount_decremented_func: ExtensionScriptInstanceRefCountDecremented,
    get_script_func:           ExtensionScriptInstanceGetScript,
    is_placeholder_func:       ExtensionScriptInstanceIsPlaceholder,
    set_fallback_func:         ExtensionScriptInstanceSet,
    get_fallback_func:         ExtensionScriptInstanceGet,
    get_language_func:         ExtensionScriptInstanceGetLanguage,
    free_func:                 ExtensionScriptInstanceFree,
}

ExtensionScriptInstanceInfo2 :: struct {
    set_func:                  ExtensionScriptInstanceSet,
    get_func:                  ExtensionScriptInstanceGet,
    get_property_list_func:    ExtensionScriptInstanceGetPropertyList,
    free_property_list_func:   ExtensionScriptInstanceFreePropertyList,
    // Optional. Set to NULL for the default behavior.
    get_class_category_func:   ExtensionScriptInstanceGetClassCategory,
    property_can_revert_func:  ExtensionScriptInstancePropertyCanRevert,
    property_get_revert_func:  ExtensionScriptInstancePropertyGetRevert,
    get_owner_func:            ExtensionScriptInstanceGetOwner,
    get_property_state_func:   ExtensionScriptInstanceGetPropertyState,
    get_method_list_func:      ExtensionScriptInstanceGetMethodList,
    free_method_list_func:     ExtensionScriptInstanceFreeMethodList,
    get_property_type_func:    ExtensionScriptInstanceGetPropertyType,
    validate_property_func:    ExtensionScriptInstanceValidateProperty,
    has_method_func:           ExtensionScriptInstanceHasMethod,
    call_func:                 ExtensionScriptInstanceCall,
    notification_func:         ExtensionScriptInstanceNotification2,
    to_string_func:            ExtensionScriptInstanceToString,
    refcount_incremented_func: ExtensionScriptInstanceRefCountIncremented,
    refcount_decremented_func: ExtensionScriptInstanceRefCountDecremented,
    get_script_func:           ExtensionScriptInstanceGetScript,
    is_placeholder_func:       ExtensionScriptInstanceIsPlaceholder,
    set_fallback_func:         ExtensionScriptInstanceSet,
    get_fallback_func:         ExtensionScriptInstanceGet,
    get_language_func:         ExtensionScriptInstanceGetLanguage,
    free_func:                 ExtensionScriptInstanceFree,
}

ExtensionScriptInstanceInfo3 :: struct {
    set_func:                       ExtensionScriptInstanceSet,
    get_func:                       ExtensionScriptInstanceGet,
    get_property_list_func:         ExtensionScriptInstanceGetPropertyList,
    free_property_list_func:        ExtensionScriptInstanceFreePropertyList2,
    get_class_category_func:        ExtensionScriptInstanceGetClassCategory, // Optional. Set to NULL for the default behavior.
    property_can_revert_func:       ExtensionScriptInstancePropertyCanRevert,
    property_get_revert_func:       ExtensionScriptInstancePropertyGetRevert,
    get_owner_func:                 ExtensionScriptInstanceGetOwner,
    get_property_state_func:        ExtensionScriptInstanceGetPropertyState,
    get_method_list_func:           ExtensionScriptInstanceGetMethodList,
    free_method_list_func:          ExtensionScriptInstanceFreeMethodList2,
    get_property_type_func:         ExtensionScriptInstanceGetPropertyType,
    validate_property_func:         ExtensionScriptInstanceValidateProperty,
    has_method_func:                ExtensionScriptInstanceHasMethod,
    get_method_argument_count_func: ExtensionScriptInstanceGetMethodArgumentCount,
    call_func:                      ExtensionScriptInstanceCall,
    notification_func:              ExtensionScriptInstanceNotification2,
    to_string_func:                 ExtensionScriptInstanceToString,
    refcount_incremented_func:      ExtensionScriptInstanceRefCountIncremented,
    refcount_decremented_func:      ExtensionScriptInstanceRefCountDecremented,
    get_script_func:                ExtensionScriptInstanceGetScript,
    is_placeholder_func:            ExtensionScriptInstanceIsPlaceholder,
    set_fallback_func:              ExtensionScriptInstanceSet,
    get_fallback_func:              ExtensionScriptInstanceGet,
    get_language_func:              ExtensionScriptInstanceGetLanguage,
    free_func:                      ExtensionScriptInstanceFree,
}

ExtensionInterfaceGetProcAddress :: #type proc "c" (function_name: cstring) -> rawptr

/*
 * Each GDExtension should define a C function that matches the signature of GDExtensionInitializationFunction,
 * and export it so that it can be loaded via dlopen() or equivalent for the given platform.
 *
 * For example:
 *
 *   GDExtensionBool my_extension_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization);
 *
 * This function's name must be specified as the 'entry_symbol' in the .gdextension file.
 *
 * This makes it the entry point of the GDExtension and will be called on initialization.
 *
 * The GDExtension can then modify the r_initialization structure, setting the minimum initialization level,
 * and providing pointers to functions that will be called at various stages of initialization/shutdown.
 *
 * The rest of the GDExtension's interface to Godot consists of function pointers that can be loaded
 * by calling p_get_proc_address("...") with the name of the function.
 *
 * For example:
 *
 *   GDExtensionInterfaceGetGodotVersion get_godot_version = (GDExtensionInterfaceGetGodotVersion)p_get_proc_address("get_godot_version");
 *
 * (Note that snippet may cause "cast between incompatible function types" on some compilers, you can
 * silence this by adding an intermediary `void*` cast.)
 *
 * You can then call it like a normal function:
 *
 *   GDExtensionGodotVersion godot_version;
 *   get_godot_version(&godot_version);
 *   printf("Godot v%d.%d.%d\n", godot_version.major, godot_version.minor, godot_version.patch);
 *
 * All of these interface functions are described below, together with the name that's used to load it,
 * and the function pointer typedef that shows its signature.
 */
InitializationFunction :: #type proc "c" (
    get_proc_address: ExtensionInterfaceGetProcAddress,
    library: ExtensionClassLibraryPtr,
    initialization: ^Initialization,
) -> bool

GodotVersion :: struct {
    version_major:  u32,
    version_minor:  u32,
    version_patch:  u32,
    version_string: cstring,
}

InitializationLevel :: enum c.int {
    Core,
    Servers,
    Scene,
    Editor,
    Max,
}

Initialization :: struct {
    minimum_initialization_level: InitializationLevel,
    user_data:                    rawptr,
    initialize:                   proc "c" (user_data: rawptr, level: InitializationLevel),
    deinitialize:                 proc "c" (user_data: rawptr, level: InitializationLevel),
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

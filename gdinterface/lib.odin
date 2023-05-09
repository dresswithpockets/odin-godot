package gdinterface

import "core:c"

BUILD_CONFIG :: #config(BUILD_CONFIG, "float_64")

VariantPtr :: distinct rawptr
StringNamePtr :: distinct rawptr
StringPtr :: distinct rawptr
ObjectPtr :: distinct rawptr
TypePtr :: distinct rawptr

MethodBindPtr :: distinct rawptr
RefPtr :: distinct rawptr

VariantType :: enum {
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
    StringName,
    NodePath,
    Rid,
    Object,
    Callable,
    Signal,
    Dictionary,
    Array,

    /* typed arrays */
    PackedByteArray,
    PackedInt32Array,
    PackedInt64Array,
    PackedFloat32Array,
    PackedFloat64Array,
    PackedStringArray,
    PackedVector2Array,
    PackedVector3Array,
    PackedColorArray,

    /* enum max */
    VariantMax,
}

VariantOperator :: enum {
    /* comparison */
    Equal,
    NotEqual,
    Less,
    LessEqual,
    Greater,
    GreaterEqual,

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
    ShiftLeft,
    ShiftRight,
    BitAnd,
    BitOr,
    BitXor,
    BitNegate,

    /* logic */
    And,
    Or,
    Xor,
    Not,

    /* containment */
    In,
    Max,
}

CallErrorType :: enum {
    Ok,
    InvalidMethod,
    InvalidArgument,
    TooManyArguments,
    TooFewArguments,
    InstanceIsNull,
    MethodNotConst,
}

CallError :: struct {
    error:    CallErrorType,
    argument: i32,
    expected: i32,
}

VariantFromTypeConstructorProc :: #type proc "c" (variant: VariantPtr, type: TypePtr)
TypeFromVariantConstructorProc :: #type proc "c" (type: TypePtr, variant: VariantPtr)
PtrOperatorEvaluator :: #type proc "c" (left: TypePtr, right: TypePtr, result: TypePtr)
PtrBuiltInMethod :: #type proc "c" (base: TypePtr, args: ^TypePtr, returns: TypePtr, arg_count: int)
PtrConstructor :: #type proc "c" (base: TypePtr, args: ^TypePtr)
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

ExtensionClassInstancePtr :: distinct rawptr

ExtensionClassSet :: #type proc "c" (
    instance: ExtensionClassInstancePtr,
    name: StringNamePtr,
    value: VariantPtr,
) -> bool
ExtensionClassGet :: #type proc "c" (instance: ExtensionClassInstancePtr, name: StringNamePtr, ret: VariantPtr) -> bool
ExtensionClassGetRid :: #type proc "c" (instance: ExtensionClassInstancePtr) -> u64

PropertyInfo :: struct {
    type:        VariantType,
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
ExtensionClassPropertyCanRevert :: #type proc "c" (instance: ExtensionClassInstancePtr, name: StringNamePtr) -> bool
ExtensionClassPropertyGetRevert :: #type proc "c" (
    instance: ExtensionClassInstancePtr,
    name: StringNamePtr,
    ret: VariantPtr,
) -> bool
ExtensionClassNotification :: #type proc "c" (instance: ExtensionClassInstancePtr, what: i32)
ExtensionClassToString :: #type proc "c" (instance: ExtensionClassInstancePtr, is_valid: ^bool, out: StringPtr)
ExtensionClassReference :: #type proc "c" (instance: ExtensionClassInstancePtr)
ExtensionClassUnreference :: #type proc "c" (instance: ExtensionClassInstancePtr)
ExtensionClassCallVirtual :: #type proc "c" (instance: ExtensionClassInstancePtr, args: [^]TypePtr, ret: TypePtr)
ExtensionClassCreateInstance :: #type proc "c" (user_data: rawptr) -> ObjectPtr
ExtensionClassFreeInstance :: #type proc "c" (user_data: rawptr, instance: ExtensionClassInstancePtr)
ExtensionClassGetVirtual :: #type proc "c" (user_data: rawptr, name: StringNamePtr) -> ExtensionClassCallVirtual

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

ExtensionClassLibraryPtr :: distinct rawptr

// Method

ExtensionClassMethodFlags :: enum {
    Normal  = 1,
    Editor  = 2,
    Const   = 4,
    Virtual = 8,
    Vararg  = 16,
    Static  = 32,
    Default = Normal,
}

ExtensionClassMethodArgumentMetadata :: enum {
    None,
    IntIsInt8,
    IntIsInt16,
    IntIsInt32,
    IntIsInt64,
    IntIsUInt8,
    IntIsUInt16,
    IntIsUInt32,
    IntIsUInt64,
    RealIsFloat,
    RealIsDouble,
}

ExtensionClassMethodCall :: #type proc "c" (
    method_user_data: rawptr,
    instance: ExtensionClassInstancePtr,
    args: [^]VariantPtr,
    argument_count: i64,
    ret: VariantPtr,
    error: CallError,
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
    method_flags:           u32,

    // If `has_return_value` is false, `return_value_info` and `return_value_metadata` are ignored.
    has_return_value:       bool,
    return_value_info:      ^PropertyInfo,
    return_value_metadata:  ExtensionClassMethodArgumentMetadata,

    /* Arguments: `arguments_info` and `arguments_metadata` are array of size `argument_count`.
     * Name and hint information for the argument can be omitted in release builds. Class name should always be present if it applies.
     */
    argument_count:         u32,
    arguments_info:         [^]PropertyInfo,
    arguments_metadata:     [^]ExtensionClassMethodArgumentMetadata,

    // Default arguments: `default_arguments` is an array of size `default_argument_count`.
    default_argument_count: u32,
    default_arguments:      [^]VariantPtr,
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
ExtensionScriptInstanceFreePropertyList :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    list: ^PropertyInfo,
)
ExtensionScriptInstanceGetPropertyType :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    name: StringNamePtr,
    is_valid: ^bool,
) -> VariantType
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
ExtensionScriptInstanceFreeMethodList :: #type proc "c" (instance: ExtensionScriptInstanceDataPtr, list: ^MethodInfo)

ExtensionScriptInstanceHasMethod :: #type proc "c" (
    instance: ExtensionScriptInstanceDataPtr,
    name: StringNamePtr,
) -> bool

ExtensionScriptInstanceCall :: #type proc "c" (
    self: ExtensionScriptInstanceDataPtr,
    method: StringNamePtr,
    args: [^]VariantPtr,
    argument_count: i64,
    ret: VariantPtr,
    error: ^CallError,
)
ExtensionScriptInstanceNotification :: #type proc "c" (instance: ExtensionScriptInstanceDataPtr, what: i32)
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

Interface :: struct {
    version_major:                                      u32,
    version_minor:                                      u32,
    version_patch:                                      u32,
    version_string:                                     cstring,

    // GODOT CORE
    mem_alloc:                                          proc "c" (bytes: c.size_t) -> rawptr,
    mem_realloc:                                        proc "c" (ptr: rawptr, bytes: c.size_t) -> rawptr,
    mem_free:                                           proc "c" (ptr: rawptr),
    print_error:                                        proc "c" (
        description: cstring,
        function: cstring,
        file: cstring,
        line: i32,
        editor_notify: bool,
    ),
    print_error_with_message:                           proc "c" (
        description: cstring,
        message: cstring,
        function: cstring,
        file: cstring,
        line: i32,
        editor_notify: bool,
    ),
    print_warning:                                      proc "c" (
        description: cstring,
        function: cstring,
        file: cstring,
        line: i32,
        editor_notify: bool,
    ),
    print_warning_with_message:                         proc "c" (
        description: cstring,
        message: cstring,
        function: cstring,
        file: cstring,
        line: i32,
        editor_notify: bool,
    ),
    print_script_error:                                 proc "c" (
        description: cstring,
        function: cstring,
        file: cstring,
        line: i32,
        editor_notify: bool,
    ),
    print_script_error_with_message:                    proc "c" (
        description: cstring,
        message: cstring,
        function: cstring,
        file: cstring,
        line: i32,
        editor_notify: bool,
    ),
    get_native_struct_size:                             proc "c" (name: StringNamePtr) -> u64,

    // GODOT VARIANT

    // variant general
    variant_new_copy:                                   proc "c" (dest: VariantPtr, src: VariantPtr),
    variant_new_nil:                                    proc "c" (dest: VariantPtr),
    variant_destroy:                                    proc "c" (self: VariantPtr),

    // variant type
    variant_call:                                       proc "c" (
        self: VariantPtr,
        method: StringNamePtr,
        args: [^]VariantPtr,
        argument_count: i64,
        ret: VariantPtr,
        error: ^CallError,
    ),
    variant_call_static:                                proc "c" (
        type: VariantType,
        method: StringNamePtr,
        args: [^]VariantPtr,
        argument_count: i64,
        ret: VariantPtr,
        error: ^CallError,
    ),
    variant_evaluate:                                   proc "c" (
        op: VariantOperator,
        a: VariantPtr,
        b: VariantPtr,
        ret: VariantPtr,
        valid: ^bool,
    ),
    variant_set:                                        proc "c" (
        self: VariantPtr,
        key: VariantPtr,
        value: VariantPtr,
        valid: ^bool,
    ),
    variant_set_named:                                  proc "c" (
        self: VariantPtr,
        key: StringNamePtr,
        value: VariantPtr,
        valid: ^bool,
    ),
    variant_set_keyed:                                  proc "c" (
        self: VariantPtr,
        key: VariantPtr,
        value: VariantPtr,
        valid: ^bool,
    ),
    variant_set_indexed:                                proc "c" (
        self: VariantPtr,
        key: VariantPtr,
        value: VariantPtr,
        valid: ^bool,
    ),
    variant_get:                                        proc "c" (
        self: VariantPtr,
        key: VariantPtr,
        ret: VariantPtr,
        valid: ^bool,
    ),
    variant_get_named:                                  proc "c" (
        self: VariantPtr,
        key: StringNamePtr,
        ret: VariantPtr,
        valid: ^bool,
    ),
    variant_get_keyed:                                  proc "c" (
        self: VariantPtr,
        key: VariantPtr,
        ret: VariantPtr,
        valid: ^bool,
    ),
    variant_get_indexed:                                proc "c" (
        self: VariantPtr,
        index: i64,
        ret: VariantPtr,
        valid: ^bool,
        oob: ^bool,
    ),
    variant_iter_init:                                  proc "c" (
        self: VariantPtr,
        iter: VariantPtr,
        valid: ^bool,
    ) -> bool,
    variant_iter_next:                                  proc "c" (
        self: VariantPtr,
        iter: VariantPtr,
        valid: ^bool,
    ) -> bool,
    variant_iter_get:                                   proc "c" (
        self: VariantPtr,
        iter: VariantPtr,
        ret: VariantPtr,
        valid: ^bool,
    ),
    variant_hash:                                       proc "c" (self: VariantPtr) -> i64,
    variant_recursive_hash:                             proc "c" (self: VariantPtr, recursion_count: i64) -> i64,
    variant_hash_compare:                               proc "c" (self: VariantPtr, other: VariantPtr) -> bool,
    variant_booleanize:                                 proc "c" (self: VariantPtr) -> bool,
    variant_duplicate:                                  proc "c" (self: VariantPtr, ret: VariantPtr, deep: bool),
    variant_stringify:                                  proc "c" (self: VariantPtr, ret: StringPtr),
    variant_get_type:                                   proc "c" (self: VariantPtr) -> VariantType,
    variant_has_method:                                 proc "c" (self: VariantPtr, method: StringNamePtr) -> bool,
    variant_has_member:                                 proc "c" (type: VariantType, method: StringNamePtr) -> bool,
    variant_has_key:                                    proc "c" (
        self: VariantPtr,
        key: VariantPtr,
        valid: ^bool,
    ) -> bool,
    variant_get_type_name:                              proc "c" (type: VariantType, name: StringPtr),
    variant_can_convert:                                proc "c" (from: VariantType, to: VariantType) -> bool,
    variant_can_convert_strict:                         proc "c" (from: VariantType, to: VariantType) -> bool,

    // ptrcalls
    get_variant_from_type_constructor:                  proc "c" (type: VariantType) -> VariantFromTypeConstructorProc,
    get_variant_to_type_constructor:                    proc "c" (type: VariantType) -> TypeFromVariantConstructorProc,
    variant_get_ptr_operator_evaluator:                 proc "c" (
        operator: VariantOperator,
        type_a: VariantType,
        type_b: VariantType,
    ) -> PtrOperatorEvaluator,
    variant_get_ptr_builtin_method:                     proc "c" (
        type: VariantType,
        method: StringNamePtr,
        hash: i64,
    ) -> PtrBuiltInMethod,
    variant_get_ptr_constructor:                        proc "c" (
        type: VariantType,
        constructor: i32,
    ) -> PtrConstructor,
    variant_get_ptr_destructor:                         proc "c" (type: VariantType) -> PtrDestructor,
    variant_construct:                                  proc "c" (
        type: VariantType,
        base: VariantPtr,
        args: [^]VariantPtr,
        argument_count: i32,
        error: ^CallError,
    ),
    variant_get_ptr_setter:                             proc "c" (
        type: VariantType,
        member: StringNamePtr,
    ) -> PtrSetter,
    variant_get_ptr_getter:                             proc "c" (
        type: VariantType,
        member: StringNamePtr,
    ) -> PtrGetter,
    variant_get_ptr_indexed_setter:                     proc "c" (type: VariantType) -> PtrIndexedSetter,
    variant_get_ptr_indexed_getter:                     proc "c" (type: VariantType) -> PtrIndexedGetter,
    variant_get_ptr_keyed_setter:                       proc "c" (type: VariantType) -> PtrKeyedSetter,
    variant_get_ptr_keyed_getter:                       proc "c" (type: VariantType) -> PtrKeyedGetter,
    variant_get_ptr_keyed_checker:                      proc "c" (type: VariantType) -> PtrKeyedChecker,
    variant_get_constant_value:                         proc "c" (
        type: VariantType,
        constant: StringNamePtr,
        ret: VariantPtr,
    ),
    variant_get_ptr_utility_function:                   proc "c" (
        function: StringNamePtr,
        hash: i64,
    ) -> PtrUtilityFunction,

    // extra utilities
    string_new_with_latin1_chars:                       proc "c" (dest: StringPtr, contents: cstring),
    string_new_with_utf8_chars:                         proc "c" (dest: StringPtr, contents: cstring),
    string_new_with_utf16_chars:                        proc "c" (dest: StringPtr, contents: ^u16),
    string_new_with_utf32_chars:                        proc "c" (dest: StringPtr, contents: ^u32),
    string_new_with_wide_chars:                         proc "c" (dest: StringPtr, contents: ^c.wchar_t),
    string_new_with_latin1_chars_and_len:               proc "c" (dest: StringPtr, contents: cstring, size: i64),
    string_new_with_utf8_chars_and_len:                 proc "c" (dest: StringPtr, contents: cstring, size: i64),
    string_new_with_utf16_chars_and_len:                proc "c" (dest: StringPtr, contents: ^u16, size: i64),
    string_new_with_utf32_chars_and_len:                proc "c" (dest: StringPtr, contents: ^u32, size: i64),
    string_new_with_wide_chars_and_len:                 proc "c" (dest: StringPtr, contents: ^c.wchar_t, size: i64),
    /* Information about the following functions:
     * - The return value is the resulting encoded string length.
     * - The length returned is in characters, not in bytes. It also does not include a trailing zero.
     * - These functions also do not write trailing zero, If you need it, write it yourself at the position indicated by the length (and make sure to allocate it).
     * - Passing NULL in r_text means only the length is computed (again, without including trailing zero).
     * - p_max_write_length argument is in characters, not bytes. It will be ignored if r_text is NULL.
     * - p_max_write_length argument does not affect the return value, it's only to cap write length.
     */
    string_to_latin1_chars:                             proc "c" (
        self: StringPtr,
        text: cstring,
        max_write_len: i64,
    ) -> i64,
    string_to_utf8_chars:                               proc "c" (
        self: StringPtr,
        text: cstring,
        max_write_len: i64,
    ) -> i64,
    string_to_utf16_chars:                              proc "c" (
        self: StringPtr,
        text: ^u16,
        max_write_len: i64,
    ) -> i64,
    string_to_utf32_chars:                              proc "c" (
        self: StringPtr,
        text: ^u32,
        max_write_len: i64,
    ) -> i64,
    string_to_wide_chars:                               proc "c" (
        self: StringPtr,
        text: ^c.wchar_t,
        max_write_len: i64,
    ) -> i64,
    string_operator_index:                              proc "c" (self: StringPtr, index: i64) -> ^u32,
    string_operator_index_const:                        proc "c" (self: StringPtr, index: i64) -> ^u32,
    string_operator_plus_eq_string:                     proc "c" (self: StringPtr, b: StringPtr),
    string_operator_plus_eq_char:                       proc "c" (self: StringPtr, b: u32),
    string_operator_plus_eq_cstr:                       proc "c" (self: StringPtr, b: cstring),
    string_operator_plus_eq_wcstr:                      proc "c" (self: StringPtr, b: [^]c.wchar_t),
    string_operator_plus_eq_c32str:                     proc "c" (self: StringPtr, b: [^]u32),

    // XMLParser extra utilities
    xml_parser_open_buffer:                             proc "c" (instance: ObjectPtr, buffer: [^]u8, size: c.size_t),

    // FileAccess extra utilities
    file_access_store_buffer:                           proc "c" (instance: ObjectPtr, src: [^]u8, length: u64),
    file_access_get_buffer:                             proc "c" (instance: ObjectPtr, dst: [^]u8, length: u64),

    // WorkerThreadPool extra utilities
    worker_thread_pool_add_native_group_task:           proc "c" (
        instance: ObjectPtr,
        func: proc "c" (_: rawptr, _: u32),
        user_data: rawptr,
        elements: i32,
        tasks: i32,
        high_priority: bool,
        description: StringPtr,
    ) -> i64,
    worker_thread_pool_add_native_task:                 proc "c" (
        instance: ObjectPtr,
        func: proc "c" (_: rawptr),
        user_data: rawptr,
        high_priority: bool,
        description: StringPtr,
    ) -> i64,

    // Packed array functions

    // self should be a PackedByteArray
    packed_byte_array_operator_index:                   proc "c" (self: TypePtr, index: i64) -> ^byte,
    // self should be a PackedByteArray
    packed_byte_array_operator_index_const:             proc "c" (self: TypePtr, index: i64) -> ^byte,

    // self should be a PackedColorArray, returns Color ptr
    packed_color_array_operator_index:                  proc "c" (self: TypePtr, index: i64) -> TypePtr,
    // self should be a PackedColorArray, returns Color ptr
    packed_color_array_operator_index_const:            proc "c" (self: TypePtr, index: i64) -> TypePtr,

    // self should be a PackedFloat32Array
    packed_float32_array_operator_index:                proc "c" (self: TypePtr, index: i64) -> ^f32,
    // self should be a PackedFloat32Array
    packed_float32_array_operator_index_const:          proc "c" (self: TypePtr, index: i64) -> ^f32,

    // self should be a PackedFloat64Array
    packed_float64_array_operator_index:                proc "c" (self: TypePtr, index: i64) -> ^f64,
    // self should be a PackedFloat64Array
    packed_float64_array_operator_index_const:          proc "c" (self: TypePtr, index: i64) -> ^f64,

    // self should be a PackedInt32Array
    packed_int32_array_operator_index:                  proc "c" (self: TypePtr, index: i64) -> ^i32,
    // self should be a PackedInt32Array
    packed_int32_array_operator_index_const:            proc "c" (self: TypePtr, index: i64) -> ^i32,

    // self should be a PackedInt64Array
    packed_int64_array_operator_index:                  proc "c" (self: TypePtr, index: i64) -> ^i64,
    // self should be a PackedInt64Array
    packed_int64_array_operator_index_const:            proc "c" (self: TypePtr, index: i64) -> ^i64,

    // self should be a PackedStringArray
    packed_string_array_operator_index:                 proc "c" (self: TypePtr, index: i64) -> StringPtr,
    // self should be a PackedStringArray
    packed_string_array_operator_index_const:           proc "c" (self: TypePtr, index: i64) -> StringPtr,

    // self should be a PackedVector2Array, returns Vector2 ptr
    packed_vector2_array_operator_index:                proc "c" (self: TypePtr, index: i64) -> TypePtr,
    // self should be a PackedVector2Array, returns Vector2 ptr
    packed_vector2_array_operator_index_const:          proc "c" (self: TypePtr, index: i64) -> TypePtr,

    // self should be a PackedVector3Array, returns Vector3 ptr
    packed_vector3_array_operator_index:                proc "c" (self: TypePtr, index: i64) -> TypePtr,
    // self should be a PackedVector3Array, returns Vector3 ptr
    packed_vector3_array_operator_index_const:          proc "c" (self: TypePtr, index: i64) -> TypePtr,

    // self should be an Array ptr
    array_operator_index:                               proc "c" (self: TypePtr, index: i64) -> VariantPtr,
    // self should be an Array ptr
    array_operator_index_const:                         proc "c" (self: TypePtr, index: i64) -> VariantPtr,
    // self should be an Array ptr
    array_ref:                                          proc "c" (self: TypePtr, from: TypePtr),
    // self should be an Array ptr
    array_set_typed:                                    proc "c" (
        self: TypePtr,
        type: VariantType,
        class_name: StringNamePtr,
        script: VariantPtr,
    ),

    // dictionary functions

    // self should be an Dictionary ptr
    dictionary_operator_index:                          proc "c" (self: TypePtr, key: VariantPtr) -> VariantPtr,
    // self should be an Dictionary ptr
    dictionary_operator_index_const:                    proc "c" (self: TypePtr, key: VariantPtr) -> VariantPtr,

    // OBJECT
    object_method_bind_call:                            proc "c" (
        method_bind: MethodBindPtr,
        instance: ObjectPtr,
        args: [^]VariantPtr,
        arg_count: i64,
        ret: VariantPtr,
        error: ^CallError,
    ),
    object_method_bind_ptrcall:                         proc "c" (
        method_bind: MethodBindPtr,
        instance: ObjectPtr,
        args: [^]VariantPtr,
        ret: VariantPtr,
    ),
    object_destroy:                                     proc "c" (o: ObjectPtr),
    global_get_singleton:                               proc "c" (name: StringNamePtr) -> ObjectPtr,
    object_get_instance_binding:                        proc "c" (
        o: ObjectPtr,
        token: rawptr,
        callbacks: [^]InstanceBindingCallbacks,
    ) -> rawptr,
    object_set_instance_binding:                        proc "c" (
        o: ObjectPtr,
        token: rawptr,
        binding: rawptr,
        callbacks: [^]InstanceBindingCallbacks,
    ),

    // class_name should be a registered extension class and should extend the o object's class.
    object_set_instance:                                proc "c" (
        o: ObjectPtr,
        class_name: StringNamePtr,
        instance: ExtensionClassInstancePtr,
    ),
    object_cast_to:                                     proc "c" (object: ObjectPtr, class_tag: rawptr) -> ObjectPtr,
    object_get_instance_from_id:                        proc "c" (instance_id: u64) -> ObjectPtr,
    object_get_instance_id:                             proc "c" (object: ObjectPtr) -> u64,

    // REFERENCE
    ref_get_object:                                     proc "c" (ref: RefPtr) -> ObjectPtr,
    ref_set_object:                                     proc "c" (ref: RefPtr, object: ObjectPtr),

    // SCRIPT INSTANCE
    script_instance_create:                             proc "c" (
        info: ^ExtensionScriptInstanceInfo,
        instance_data: ExtensionScriptInstanceDataPtr,
    ) -> ScriptInstancePtr,

    // CLASSDB EXTENSION

    // The passed class must be a built-in godot class, or an already-registered extension class. In both case, object_set_instance should be called to fully initialize the object.
    classdb_construct_object:                           proc "c" (class_name: StringNamePtr) -> ObjectPtr,
    classdb_get_method_bind:                            proc "c" (
        class_name: StringNamePtr,
        method_name: StringNamePtr,
        hash: i64,
    ) -> MethodBindPtr,
    classdb_get_class_tag:                              proc "c" (class_name: StringNamePtr) -> rawptr,

    // CLASSDB EXTENSION

    // Provided parameters for `classdb_register_extension_*` can be safely freed once the function returns.
    classdb_register_extension_class:                   proc "c" (
        library: ExtensionClassLibraryPtr,
        class_name: StringNamePtr,
        parent_class_name: StringNamePtr,
        extension_funcs: ^ExtensionClassCreationInfo,
    ),
    classdb_register_extension_class_method:            proc "c" (
        library: ExtensionClassLibraryPtr,
        class_name: StringNamePtr,
        method_info: ^ExtensionClassMethodInfo,
    ),
    classdb_register_extension_class_integer_constant:  proc "c" (
        library: ExtensionClassLibraryPtr,
        class_name: StringNamePtr,
        enum_name: StringNamePtr,
        constant_name: StringNamePtr,
        constant_value: i64,
        is_bitfield: bool,
    ),
    classdb_register_extension_class_property:          proc "c" (
        library: ExtensionClassLibraryPtr,
        class_name: StringNamePtr,
        info: ^PropertyInfo,
        setter: StringNamePtr,
        getter: StringNamePtr,
    ),
    classdb_register_extension_class_property_group:    proc "c" (
        library: ExtensionClassLibraryPtr,
        class_name: StringNamePtr,
        group_name: StringPtr,
        prefix: StringPtr,
    ),
    classdb_register_extension_class_property_subgroup: proc "c" (
        library: ExtensionClassLibraryPtr,
        class_name: StringNamePtr,
        subgroup_name: StringPtr,
        prefix: StringPtr,
    ),
    classdb_register_extension_class_signal:            proc "c" (
        library: ExtensionClassLibraryPtr,
        class_name: StringNamePtr,
        signal_name: StringNamePtr,
        argument_info: [^]PropertyInfo,
        argument_count: i64,
    ),
    // Unregistering a parent class before a class that inherits it will result in failure. Inheritors must be unregistered first.
    classdb_unregister_extension_class:                 proc "c" (
        library: ExtensionClassLibraryPtr,
        class_name: StringNamePtr,
    ),
    get_library_path:                                   proc "c" (library: ExtensionClassLibraryPtr, path: StringPtr),
}

InitializationLevel :: enum {
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

/* Define a function prototype that implements the function below and expose it to dlopen() (or similar).
 * This is the entry point of the GDExtension library and will be called on initialization.
 * It can be used to set up different init levels, which are called during various stages of initialization/shutdown.
 * The function name must be a unique one specified in the .gdextension config file.
 */
InitializationFunction :: #type proc "c" (
    interface: ^Interface,
    library: ExtensionClassLibraryPtr,
    initialization: ^Initialization,
) -> bool

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

package gdextension

import "core:c"

/**
 * @name mem_alloc
 * @since 4.1
 *
 * Allocates memory.
 *
 * @param p_bytes The amount of memory to allocate in bytes.
 *
 * @return A pointer to the allocated memory, or NULL if unsuccessful.
 */
ExtensionInterfaceMemAlloc :: #type proc "c" (p_bytes: c.size_t) -> rawptr

/**
 * @name mem_realloc
 * @since 4.1
 *
 * Reallocates memory.
 *
 * @param p_ptr A pointer to the previously allocated memory.
 * @param p_bytes The number of bytes to resize the memory block to.
 *
 * @return A pointer to the allocated memory, or NULL if unsuccessful.
 */
ExtensionInterfaceMemRealloc :: #type proc "c" (p_ptr: rawptr, p_bytes: c.size_t) -> rawptr

/**
 * @name mem_free
 * @since 4.1
 *
 * Frees memory.
 *
 * @param p_ptr A pointer to the previously allocated memory.
 */
ExtensionInterfaceMemFree :: #type proc "c" (p_ptr: rawptr)

/**
 * @name print_error
 * @since 4.1
 *
 * Logs an error to Godot's built-in debugger and to the OS terminal.
 *
 * @param p_description The code trigging the error.
 * @param p_function The function name where the error occurred.
 * @param p_file The file where the error occurred.
 * @param p_line The line where the error occurred.
 * @param p_editor_notify Whether or not to notify the editor.
 */
ExtensionInterfacePrintError :: #type proc "c" (
    p_description: cstring,
    p_function: cstring,
    p_file: cstring,
    p_line: i32,
    p_editor_notify: bool,
)

/**
 * @name print_error_with_message
 * @since 4.1
 *
 * Logs an error with a message to Godot's built-in debugger and to the OS terminal.
 *
 * @param p_description The code trigging the error.
 * @param p_message The message to show along with the error.
 * @param p_function The function name where the error occurred.
 * @param p_file The file where the error occurred.
 * @param p_line The line where the error occurred.
 * @param p_editor_notify Whether or not to notify the editor.
 */
ExtensionInterfacePrintErrorWithMessage :: #type proc "c" (
    p_description: cstring,
    p_message: cstring,
    p_function: cstring,
    p_file: cstring,
    p_line: i32,
    p_editor_notify: bool,
)

/**
 * @name print_warning
 * @since 4.1
 *
 * Logs a warning to Godot's built-in debugger and to the OS terminal.
 *
 * @param p_description The code trigging the warning.
 * @param p_function The function name where the warning occurred.
 * @param p_file The file where the warning occurred.
 * @param p_line The line where the warning occurred.
 * @param p_editor_notify Whether or not to notify the editor.
 */
ExtensionInterfacePrintWarning :: #type proc "c" (
    p_description: cstring,
    p_function: cstring,
    p_file: cstring,
    p_line: i32,
    p_editor_notify: bool,
)

/**
 * @name print_warning_with_message
 * @since 4.1
 *
 * Logs a warning with a message to Godot's built-in debugger and to the OS terminal.
 *
 * @param p_description The code trigging the warning.
 * @param p_message The message to show along with the warning.
 * @param p_function The function name where the warning occurred.
 * @param p_file The file where the warning occurred.
 * @param p_line The line where the warning occurred.
 * @param p_editor_notify Whether or not to notify the editor.
 */
ExtensionInterfacePrintWarningWithMessage :: #type proc "c" (
    p_description: cstring,
    p_message: cstring,
    p_function: cstring,
    p_file: cstring,
    p_line: i32,
    p_editor_notify: bool,
)

/**
 * @name print_script_error
 * @since 4.1
 *
 * Logs a script error to Godot's built-in debugger and to the OS terminal.
 *
 * @param p_description The code trigging the error.
 * @param p_function The function name where the error occurred.
 * @param p_file The file where the error occurred.
 * @param p_line The line where the error occurred.
 * @param p_editor_notify Whether or not to notify the editor.
 */
ExtensionInterfacePrintScriptError :: #type proc "c" (
    p_description: cstring,
    p_function: cstring,
    p_file: cstring,
    p_line: i32,
    p_editor_notify: bool,
)

/**
 * @name print_script_error_with_message
 * @since 4.1
 *
 * Logs a script error with a message to Godot's built-in debugger and to the OS terminal.
 *
 * @param p_description The code trigging the error.
 * @param p_message The message to show along with the error.
 * @param p_function The function name where the error occurred.
 * @param p_file The file where the error occurred.
 * @param p_line The line where the error occurred.
 * @param p_editor_notify Whether or not to notify the editor.
 */
ExtensionInterfacePrintScriptErrorWithMessage :: #type proc "c" (
    p_description: cstring,
    p_message: cstring,
    p_function: cstring,
    p_file: cstring,
    p_line: i32,
    p_editor_notify: bool,
)

/**
 * @name get_native_struct_size
 * @since 4.1
 *
 * Gets the size of a native struct (ex. ObjectID) in bytes.
 *
 * @param p_name A pointer to a StringName identifying the struct name.
 *
 * @return The size in bytes.
 */
ExtensionInterfaceGetNativeStructSize :: #type proc "c" (p_name: StringNamePtr) -> u64

/**
 * @name variant_new_copy
 * @since 4.1
 *
 * Copies one Variant into a another.
 *
 * @param r_dest A pointer to the destination Variant.
 * @param p_src A pointer to the source Variant.
 */
ExtensionInterfaceVariantNewCopy :: #type proc "c" (r_dest: VariantPtr, p_src: VariantPtr)

/**
 * @name variant_new_nil
 * @since 4.1
 *
 * Creates a new Variant containing nil.
 *
 * @param r_dest A pointer to the destination Variant.
 */
ExtensionInterfaceVariantNewNil :: #type proc "c" (r_dest: VariantPtr)

/**
 * @name variant_destroy
 * @since 4.1
 *
 * Destroys a Variant.
 *
 * @param p_self A pointer to the Variant to destroy.
 */
ExtensionInterfaceVariantDestroy :: #type proc "c" (p_self: VariantPtr)

/**
 * @name variant_call
 * @since 4.1
 *
 * Calls a method on a Variant.
 *
 * @param p_self A pointer to the Variant.
 * @param p_method A pointer to a StringName identifying the method.
 * @param p_args A pointer to a C array of Variant.
 * @param p_argument_count The number of arguments.
 * @param r_return A pointer a Variant which will be assigned the return value.
 * @param r_error A pointer the structure which will hold error information.
 *
 * @see Variant::callp()
 */
ExtensionInterfaceVariantCall :: #type proc "c" (
    p_self: VariantPtr,
    p_method: StringNamePtr,
    p_args: ^VariantPtr,
    p_argument_count: i64,
    r_return: VariantPtr,
    r_error: ^CallError,
)

/**
 * @name variant_call_static
 * @since 4.1
 *
 * Calls a static method on a Variant.
 *
 * @param p_self A pointer to the Variant.
 * @param p_method A pointer to a StringName identifying the method.
 * @param p_args A pointer to a C array of Variant.
 * @param p_argument_count The number of arguments.
 * @param r_return A pointer a Variant which will be assigned the return value.
 * @param r_error A pointer the structure which will be updated with error information.
 *
 * @see Variant::call_static()
 */
ExtensionInterfaceVariantCallStatic :: #type proc "c" (
    p_type: VariantType,
    p_method: StringNamePtr,
    p_args: ^VariantPtr,
    p_argument_count: i64,
    r_return: VariantPtr,
    r_error: ^CallError,
)

/**
 * @name variant_evaluate
 * @since 4.1
 *
 * Evaluate an operator on two Variants.
 *
 * @param p_op The operator to evaluate.
 * @param p_a The first Variant.
 * @param p_b The second Variant.
 * @param r_return A pointer a Variant which will be assigned the return value.
 * @param r_valid A pointer to a boolean which will be set to false if the operation is invalid.
 *
 * @see Variant::evaluate()
 */
ExtensionInterfaceVariantEvaluate :: #type proc "c" (
    p_op: VariantOperator,
    p_a: VariantPtr,
    p_b: VariantPtr,
    r_return: VariantPtr,
    r_valid: ^bool,
)

/**
 * @name variant_set
 * @since 4.1
 *
 * Sets a key on a Variant to a value.
 *
 * @param p_self A pointer to the Variant.
 * @param p_key A pointer to a Variant representing the key.
 * @param p_value A pointer to a Variant representing the value.
 * @param r_valid A pointer to a boolean which will be set to false if the operation is invalid.
 *
 * @see Variant::set()
 */
ExtensionInterfaceVariantSet :: #type proc "c" (
    p_self: VariantPtr,
    p_key: VariantPtr,
    p_value: VariantPtr,
    r_valid: ^bool,
)

/**
 * @name variant_set_named
 * @since 4.1
 *
 * Sets a named key on a Variant to a value.
 *
 * @param p_self A pointer to the Variant.
 * @param p_key A pointer to a StringName representing the key.
 * @param p_value A pointer to a Variant representing the value.
 * @param r_valid A pointer to a boolean which will be set to false if the operation is invalid.
 *
 * @see Variant::set_named()
 */
ExtensionInterfaceVariantSetNamed :: #type proc "c" (
    p_self: VariantPtr,
    p_key: StringNamePtr,
    p_value: VariantPtr,
    r_valid: ^bool,
)

/**
 * @name variant_set_keyed
 * @since 4.1
 *
 * Sets a keyed property on a Variant to a value.
 *
 * @param p_self A pointer to the Variant.
 * @param p_key A pointer to a Variant representing the key.
 * @param p_value A pointer to a Variant representing the value.
 * @param r_valid A pointer to a boolean which will be set to false if the operation is invalid.
 *
 * @see Variant::set_keyed()
 */
ExtensionInterfaceVariantSetKeyed :: #type proc "c" (
    p_self: VariantPtr,
    p_key: VariantPtr,
    p_value: VariantPtr,
    r_valid: ^bool,
)

/**
 * @name variant_set_indexed
 * @since 4.1
 *
 * Sets an index on a Variant to a value.
 *
 * @param p_self A pointer to the Variant.
 * @param p_index The index.
 * @param p_value A pointer to a Variant representing the value.
 * @param r_valid A pointer to a boolean which will be set to false if the operation is invalid.
 * @param r_oob A pointer to a boolean which will be set to true if the index is out of bounds.
 */
ExtensionInterfaceVariantSetIndexed :: #type proc "c" (
    p_self: VariantPtr,
    p_index: i64,
    p_value: VariantPtr,
    r_valid: ^bool,
    r_oob: ^bool,
)

/**
 * @name variant_get
 * @since 4.1
 *
 * Gets the value of a key from a Variant.
 *
 * @param p_self A pointer to the Variant.
 * @param p_key A pointer to a Variant representing the key.
 * @param r_ret A pointer to a Variant which will be assigned the value.
 * @param r_valid A pointer to a boolean which will be set to false if the operation is invalid.
 */
ExtensionInterfaceVariantGet :: #type proc "c" (
    p_self: VariantPtr,
    p_key: VariantPtr,
    r_ret: VariantPtr,
    r_valid: ^bool,
)

/**
 * @name variant_get_named
 * @since 4.1
 *
 * Gets the value of a named key from a Variant.
 *
 * @param p_self A pointer to the Variant.
 * @param p_key A pointer to a StringName representing the key.
 * @param r_ret A pointer to a Variant which will be assigned the value.
 * @param r_valid A pointer to a boolean which will be set to false if the operation is invalid.
 */
ExtensionInterfaceVariantGetNamed :: #type proc "c" (
    p_self: VariantPtr,
    p_key: StringNamePtr,
    r_ret: VariantPtr,
    r_valid: ^bool,
)

/**
 * @name variant_get_keyed
 * @since 4.1
 *
 * Gets the value of a keyed property from a Variant.
 *
 * @param p_self A pointer to the Variant.
 * @param p_key A pointer to a Variant representing the key.
 * @param r_ret A pointer to a Variant which will be assigned the value.
 * @param r_valid A pointer to a boolean which will be set to false if the operation is invalid.
 */
ExtensionInterfaceVariantGetKeyed :: #type proc "c" (
    p_self: VariantPtr,
    p_key: VariantPtr,
    r_ret: VariantPtr,
    r_valid: ^bool,
)

/**
 * @name variant_get_indexed
 * @since 4.1
 *
 * Gets the value of an index from a Variant.
 *
 * @param p_self A pointer to the Variant.
 * @param p_index The index.
 * @param r_ret A pointer to a Variant which will be assigned the value.
 * @param r_valid A pointer to a boolean which will be set to false if the operation is invalid.
 * @param r_oob A pointer to a boolean which will be set to true if the index is out of bounds.
 */
ExtensionInterfaceVariantGetIndexed :: #type proc "c" (
    p_self: VariantPtr,
    p_index: i64,
    r_ret: VariantPtr,
    r_valid: ^bool,
    r_oob: ^bool,
)

/**
 * @name variant_iter_init
 * @since 4.1
 *
 * Initializes an iterator over a Variant.
 *
 * @param p_self A pointer to the Variant.
 * @param r_iter A pointer to a Variant which will be assigned the iterator.
 * @param r_valid A pointer to a boolean which will be set to false if the operation is invalid.
 *
 * @return true if the operation is valid; otherwise false.
 *
 * @see Variant::iter_init()
 */
ExtensionInterfaceVariantIterInit :: #type proc "c" (p_self: VariantPtr, r_iter: VariantPtr, r_valid: ^bool) -> bool

/**
 * @name variant_iter_next
 * @since 4.1
 *
 * Gets the next value for an iterator over a Variant.
 *
 * @param p_self A pointer to the Variant.
 * @param r_iter A pointer to a Variant which will be assigned the iterator.
 * @param r_valid A pointer to a boolean which will be set to false if the operation is invalid.
 *
 * @return true if the operation is valid; otherwise false.
 *
 * @see Variant::iter_next()
 */
ExtensionInterfaceVariantIterNext :: #type proc "c" (p_self: VariantPtr, r_iter: VariantPtr, r_valid: ^bool) -> bool

/**
 * @name variant_iter_get
 * @since 4.1
 *
 * Gets the next value for an iterator over a Variant.
 *
 * @param p_self A pointer to the Variant.
 * @param r_iter A pointer to a Variant which will be assigned the iterator.
 * @param r_ret A pointer to a Variant which will be assigned false if the operation is invalid.
 * @param r_valid A pointer to a boolean which will be set to false if the operation is invalid.
 *
 * @see Variant::iter_get()
 */
ExtensionInterfaceVariantIterGet :: #type proc "c" (
    p_self: VariantPtr,
    r_iter: VariantPtr,
    r_ret: VariantPtr,
    r_valid: ^bool,
)

/**
 * @name variant_hash
 * @since 4.1
 *
 * Gets the hash of a Variant.
 *
 * @param p_self A pointer to the Variant.
 *
 * @return The hash value.
 *
 * @see Variant::hash()
 */
ExtensionInterfaceVariantHash :: #type proc "c" (p_self: VariantPtr) -> i64

/**
 * @name variant_recursive_hash
 * @since 4.1
 *
 * Gets the recursive hash of a Variant.
 *
 * @param p_self A pointer to the Variant.
 * @param p_recursion_count The number of recursive loops so far.
 *
 * @return The hash value.
 *
 * @see Variant::recursive_hash()
 */
ExtensionInterfaceVariantRecursiveHash :: #type proc "c" (p_self: VariantPtr, p_recursion_count: i64) -> i64

/**
 * @name variant_hash_compare
 * @since 4.1
 *
 * Compares two Variants by their hash.
 *
 * @param p_self A pointer to the Variant.
 * @param p_other A pointer to the other Variant to compare it to.
 *
 * @return The hash value.
 *
 * @see Variant::hash_compare()
 */
ExtensionInterfaceVariantHashCompare :: #type proc "c" (p_self: VariantPtr, p_other: VariantPtr) -> bool

/**
 * @name variant_booleanize
 * @since 4.1
 *
 * Converts a Variant to a boolean.
 *
 * @param p_self A pointer to the Variant.
 *
 * @return The boolean value of the Variant.
 */
ExtensionInterfaceVariantBooleanize :: #type proc "c" (p_self: VariantPtr) -> bool

/**
 * @name variant_duplicate
 * @since 4.1
 *
 * Duplicates a Variant.
 *
 * @param p_self A pointer to the Variant.
 * @param r_ret A pointer to a Variant to store the duplicated value.
 * @param p_deep Whether or not to duplicate deeply (when supported by the Variant type).
 */
ExtensionInterfaceVariantDuplicate :: #type proc "c" (p_self: VariantPtr, r_ret: VariantPtr, p_deep: bool)

/**
 * @name variant_stringify
 * @since 4.1
 *
 * Converts a Variant to a string.
 *
 * @param p_self A pointer to the Variant.
 * @param r_ret A pointer to a String to store the resulting value.
 */
ExtensionInterfaceVariantStringify :: #type proc "c" (p_self: VariantPtr, r_ret: StringPtr)

/**
 * @name variant_get_type
 * @since 4.1
 *
 * Gets the type of a Variant.
 *
 * @param p_self A pointer to the Variant.
 *
 * @return The variant type.
 */
ExtensionInterfaceVariantGetType :: #type proc "c" (p_self: VariantPtr) -> VariantType

/**
 * @name variant_has_method
 * @since 4.1
 *
 * Checks if a Variant has the given method.
 *
 * @param p_self A pointer to the Variant.
 * @param p_method A pointer to a StringName with the method name.
 *
 * @return
 */
ExtensionInterfaceVariantHasMethod :: #type proc "c" (p_self: VariantPtr, p_method: StringNamePtr) -> bool

/**
 * @name variant_has_member
 * @since 4.1
 *
 * Checks if a type of Variant has the given member.
 *
 * @param p_type The Variant type.
 * @param p_member A pointer to a StringName with the member name.
 *
 * @return
 */
ExtensionInterfaceVariantHasMember :: #type proc "c" (p_type: VariantType, p_member: StringNamePtr) -> bool

/**
 * @name variant_has_key
 * @since 4.1
 *
 * Checks if a Variant has a key.
 *
 * @param p_self A pointer to the Variant.
 * @param p_key A pointer to a Variant representing the key.
 * @param r_valid A pointer to a boolean which will be set to false if the key doesn't exist.
 *
 * @return true if the key exists; otherwise false.
 */
ExtensionInterfaceVariantHasKey :: #type proc "c" (p_self: VariantPtr, p_key: VariantPtr, r_valid: ^bool) -> bool

/**
 * @name variant_get_type_name
 * @since 4.1
 *
 * Gets the name of a Variant type.
 *
 * @param p_type The Variant type.
 * @param r_name A pointer to a String to store the Variant type name.
 */
ExtensionInterfaceVariantGetTypeName :: #type proc "c" (p_type: VariantType, r_name: StringPtr)

/**
 * @name variant_can_convert
 * @since 4.1
 *
 * Checks if Variants can be converted from one type to another.
 *
 * @param p_from The Variant type to convert from.
 * @param p_to The Variant type to convert to.
 *
 * @return true if the conversion is possible; otherwise false.
 */
ExtensionInterfaceVariantCanConvert :: #type proc "c" (p_from: VariantType, p_to: VariantType) -> bool

/**
 * @name variant_can_convert_strict
 * @since 4.1
 *
 * Checks if Variant can be converted from one type to another using stricter rules.
 *
 * @param p_from The Variant type to convert from.
 * @param p_to The Variant type to convert to.
 *
 * @return true if the conversion is possible; otherwise false.
 */
ExtensionInterfaceVariantCanConvertStrict :: #type proc "c" (p_from: VariantType, p_to: VariantType) -> bool

/**
 * @name get_variant_from_type_constructor
 * @since 4.1
 *
 * Gets a pointer to a function that can create a Variant of the given type from a raw value.
 *
 * @param p_type The Variant type.
 *
 * @return A pointer to a function that can create a Variant of the given type from a raw value.
 */
ExtensionInterfaceGetVariantFromTypeConstructor :: #type proc "c" (
    p_type: VariantType,
) -> VariantFromTypeConstructorProc

/**
 * @name get_variant_to_type_constructor
 * @since 4.1
 *
 * Gets a pointer to a function that can get the raw value from a Variant of the given type.
 *
 * @param p_type The Variant type.
 *
 * @return A pointer to a function that can get the raw value from a Variant of the given type.
 */
ExtensionInterfaceGetVariantToTypeConstructor :: #type proc "c" (p_type: VariantType) -> TypeFromVariantConstructorProc

/**
 * @name variant_get_ptr_operator_evaluator
 * @since 4.1
 *
 * Gets a pointer to a function that can evaluate the given Variant operator on the given Variant types.
 *
 * @param p_operator The variant operator.
 * @param p_type_a The type of the first Variant.
 * @param p_type_b The type of the second Variant.
 *
 * @return A pointer to a function that can evaluate the given Variant operator on the given Variant types.
 */
ExtensionInterfaceVariantGetPtrOperatorEvaluator :: #type proc "c" (
    p_operator: VariantOperator,
    p_type_a: VariantType,
    p_type_b: VariantType,
) -> PtrOperatorEvaluator

/**
 * @name variant_get_ptr_builtin_method
 * @since 4.1
 *
 * Gets a pointer to a function that can call a builtin method on a type of Variant.
 *
 * @param p_type The Variant type.
 * @param p_method A pointer to a StringName with the method name.
 * @param p_hash A hash representing the method signature.
 *
 * @return A pointer to a function that can call a builtin method on a type of Variant.
 */
ExtensionInterfaceVariantGetPtrBuiltinMethod :: #type proc "c" (
    p_type: VariantType,
    p_method: StringNamePtr,
    p_hash: i64,
) -> PtrBuiltInMethod

/**
 * @name variant_get_ptr_constructor
 * @since 4.1
 *
 * Gets a pointer to a function that can call one of the constructors for a type of Variant.
 *
 * @param p_type The Variant type.
 * @param p_constructor The index of the constructor.
 *
 * @return A pointer to a function that can call one of the constructors for a type of Variant.
 */
ExtensionInterfaceVariantGetPtrConstructor :: #type proc "c" (
    p_type: VariantType,
    p_constructor: i32,
) -> PtrConstructor

/**
 * @name variant_get_ptr_destructor
 * @since 4.1
 *
 * Gets a pointer to a function than can call the destructor for a type of Variant.
 *
 * @param p_type The Variant type.
 *
 * @return A pointer to a function than can call the destructor for a type of Variant.
 */
ExtensionInterfaceVariantGetPtrDestructor :: #type proc "c" (p_type: VariantType) -> PtrDestructor

/**
 * @name variant_construct
 * @since 4.1
 *
 * Constructs a Variant of the given type, using the first constructor that matches the given arguments.
 *
 * @param p_type The Variant type.
 * @param p_base A pointer to a Variant to store the constructed value.
 * @param p_args A pointer to a C array of Variant pointers representing the arguments for the constructor.
 * @param p_argument_count The number of arguments to pass to the constructor.
 * @param r_error A pointer the structure which will be updated with error information.
 */
ExtensionInterfaceVariantConstruct :: #type proc "c" (
    p_type: VariantType,
    r_base: VariantPtr,
    p_args: ^VariantPtr,
    p_argument_count: i32,
    r_error: ^CallError,
)

/**
 * @name variant_get_ptr_setter
 * @since 4.1
 *
 * Gets a pointer to a function that can call a member's setter on the given Variant type.
 *
 * @param p_type The Variant type.
 * @param p_member A pointer to a StringName with the member name.
 *
 * @return A pointer to a function that can call a member's setter on the given Variant type.
 */
ExtensionInterfaceVariantGetPtrSetter :: #type proc "c" (p_type: VariantType, p_member: StringNamePtr) -> PtrSetter

/**
 * @name variant_get_ptr_getter
 * @since 4.1
 *
 * Gets a pointer to a function that can call a member's getter on the given Variant type.
 *
 * @param p_type The Variant type.
 * @param p_member A pointer to a StringName with the member name.
 *
 * @return A pointer to a function that can call a member's getter on the given Variant type.
 */
ExtensionInterfaceVariantGetPtrGetter :: #type proc "c" (p_type: VariantType, p_member: StringNamePtr) -> PtrGetter

/**
 * @name variant_get_ptr_indexed_setter
 * @since 4.1
 *
 * Gets a pointer to a function that can set an index on the given Variant type.
 *
 * @param p_type The Variant type.
 *
 * @return A pointer to a function that can set an index on the given Variant type.
 */
ExtensionInterfaceVariantGetPtrIndexedSetter :: #type proc "c" (p_type: VariantType) -> PtrIndexedSetter

/**
 * @name variant_get_ptr_indexed_getter
 * @since 4.1
 *
 * Gets a pointer to a function that can get an index on the given Variant type.
 *
 * @param p_type The Variant type.
 *
 * @return A pointer to a function that can get an index on the given Variant type.
 */
ExtensionInterfaceVariantGetPtrIndexedGetter :: #type proc "c" (p_type: VariantType) -> PtrIndexedGetter

/**
 * @name variant_get_ptr_keyed_setter
 * @since 4.1
 *
 * Gets a pointer to a function that can set a key on the given Variant type.
 *
 * @param p_type The Variant type.
 *
 * @return A pointer to a function that can set a key on the given Variant type.
 */
ExtensionInterfaceVariantGetPtrKeyedSetter :: #type proc "c" (p_type: VariantType) -> PtrKeyedSetter

/**
 * @name variant_get_ptr_keyed_getter
 * @since 4.1
 *
 * Gets a pointer to a function that can get a key on the given Variant type.
 *
 * @param p_type The Variant type.
 *
 * @return A pointer to a function that can get a key on the given Variant type.
 */
ExtensionInterfaceVariantGetPtrKeyedGetter :: #type proc "c" (p_type: VariantType) -> PtrKeyedGetter

/**
 * @name variant_get_ptr_keyed_checker
 * @since 4.1
 *
 * Gets a pointer to a function that can check a key on the given Variant type.
 *
 * @param p_type The Variant type.
 *
 * @return A pointer to a function that can check a key on the given Variant type.
 */
ExtensionInterfaceVariantGetPtrKeyedChecker :: #type proc "c" (p_type: VariantType) -> PtrKeyedGetter

/**
 * @name variant_get_constant_value
 * @since 4.1
 *
 * Gets the value of a constant from the given Variant type.
 *
 * @param p_type The Variant type.
 * @param p_constant A pointer to a StringName with the constant name.
 * @param r_ret A pointer to a Variant to store the value.
 */
ExtensionInterfaceVariantGetConstantValue :: #type proc "c" (
    p_type: VariantType,
    p_constant: StringNamePtr,
    r_ret: VariantPtr,
)

/**
 * @name variant_get_ptr_utility_function
 * @since 4.1
 *
 * Gets a pointer to a function that can call a Variant utility function.
 *
 * @param p_function A pointer to a StringName with the function name.
 * @param p_hash A hash representing the function signature.
 *
 * @return A pointer to a function that can call a Variant utility function.
 */
ExtensionInterfaceVariantGetPtrUtilityFunction :: #type proc "c" (
    p_function: StringNamePtr,
    p_hash: i64,
) -> PtrUtilityFunction

/**
 * @name string_new_with_latin1_chars
 * @since 4.1
 *
 * Creates a String from a Latin-1 encoded C string.
 *
 * @param r_dest A pointer to a Variant to hold the newly created String.
 * @param p_contents A pointer to a Latin-1 encoded C string (null terminated).
 */
ExtensionInterfaceStringNewWithLatin1Chars :: #type proc "c" (r_dest: StringPtr, p_contents: cstring)

/**
 * @name string_new_with_utf8_chars
 * @since 4.1
 *
 * Creates a String from a UTF-8 encoded C string.
 *
 * @param r_dest A pointer to a Variant to hold the newly created String.
 * @param p_contents A pointer to a UTF-8 encoded C string (null terminated).
 */
ExtensionInterfaceStringNewWithUtf8Chars :: #type proc "c" (r_dest: StringPtr, p_contents: cstring)

/**
 * @name string_new_with_utf16_chars
 * @since 4.1
 *
 * Creates a String from a UTF-16 encoded C string.
 *
 * @param r_dest A pointer to a Variant to hold the newly created String.
 * @param p_contents A pointer to a UTF-16 encoded C string (null terminated).
 */
ExtensionInterfaceStringNewWithUtf16Chars :: #type proc "c" (r_dest: StringPtr, p_contents: ^u16)

/**
 * @name string_new_with_utf32_chars
 * @since 4.1
 *
 * Creates a String from a UTF-32 encoded C string.
 *
 * @param r_dest A pointer to a Variant to hold the newly created String.
 * @param p_contents A pointer to a UTF-32 encoded C string (null terminated).
 */
ExtensionInterfaceStringNewWithUtf32Chars :: #type proc "c" (r_dest: StringPtr, p_contents: ^u32)

/**
 * @name string_new_with_wide_chars
 * @since 4.1
 *
 * Creates a String from a wide C string.
 *
 * @param r_dest A pointer to a Variant to hold the newly created String.
 * @param p_contents A pointer to a wide C string (null terminated).
 */
ExtensionInterfaceStringNewWithWideChars :: #type proc "c" (r_dest: StringPtr, p_contents: ^c.wchar_t)

/**
 * @name string_new_with_latin1_chars_and_len
 * @since 4.1
 *
 * Creates a String from a Latin-1 encoded C string with the given length.
 *
 * @param r_dest A pointer to a Variant to hold the newly created String.
 * @param p_contents A pointer to a Latin-1 encoded C string.
 * @param p_size The number of characters (= number of bytes).
 */
ExtensionInterfaceStringNewWithLatin1CharsAndLen :: #type proc "c" (
    r_dest: StringPtr,
    p_contents: cstring,
    p_size: i64,
)

/**
 * @name string_new_with_utf8_chars_and_len
 * @since 4.1
 * @deprecated in Godot 4.3. Use `string_new_with_utf8_chars_and_len2` instead.
 *
 * Creates a String from a UTF-8 encoded C string with the given length.
 *
 * @param r_dest A pointer to a Variant to hold the newly created String.
 * @param p_contents A pointer to a UTF-8 encoded C string.
 * @param p_size The number of bytes (not code units).
 */
ExtensionInterfaceStringNewWithUtf8CharsAndLen :: #type proc "c" (r_dest: StringPtr, p_contents: cstring, p_size: i64)

/**
 * @name string_new_with_utf8_chars_and_len2
 * @since 4.3
 *
 * Creates a String from a UTF-8 encoded C string with the given length.
 *
 * @param r_dest A pointer to a Variant to hold the newly created String.
 * @param p_contents A pointer to a UTF-8 encoded C string.
 * @param p_size The number of bytes (not code units).
 *
 * @return Error code signifying if the operation successful.
 */
ExtensionInterfaceStringNewWithUtf8CharsAndLen2 :: #type proc "c" (
    r_dest: StringPtr,
    p_contents: cstring,
    p_size: i64,
) -> i64

/**
 * @name string_new_with_utf16_chars_and_len
 * @since 4.1
 * @deprecated in Godot 4.3. Use `string_new_with_utf16_chars_and_len2` instead.
 *
 * Creates a String from a UTF-16 encoded C string with the given length.
 *
 * @param r_dest A pointer to a Variant to hold the newly created String.
 * @param p_contents A pointer to a UTF-16 encoded C string.
 * @param p_size The number of characters (not bytes).
 */
ExtensionInterfaceStringNewWithUtf16CharsAndLen :: #type proc "c" (
    r_dest: StringPtr,
    p_contents: ^u16,
    p_char_count: i64,
)

/**
 * @name string_new_with_utf16_chars_and_len2
 * @since 4.3
 *
 * Creates a String from a UTF-16 encoded C string with the given length.
 *
 * @param r_dest A pointer to a Variant to hold the newly created String.
 * @param p_contents A pointer to a UTF-16 encoded C string.
 * @param p_size The number of characters (not bytes).
 * @param p_default_little_endian If true, UTF-16 use little endian.
 *
 * @return Error code signifying if the operation successful.
 */
ExtensionInterfaceStringNewWithUtf16CharsAndLen2 :: #type proc "c" (
    r_dest: StringPtr,
    p_contents: ^u16,
    p_char_count: i64,
    p_default_little_endian: bool,
) -> i64

/**
 * @name string_new_with_utf32_chars_and_len
 * @since 4.1
 *
 * Creates a String from a UTF-32 encoded C string with the given length.
 *
 * @param r_dest A pointer to a Variant to hold the newly created String.
 * @param p_contents A pointer to a UTF-32 encoded C string.
 * @param p_size The number of characters (not bytes).
 */
ExtensionInterfaceStringNewWithUtf32CharsAndLen :: #type proc "c" (
    r_dest: StringPtr,
    p_contents: ^u32,
    p_char_count: i64,
)

/**
 * @name string_new_with_wide_chars_and_len
 * @since 4.1
 *
 * Creates a String from a wide C string with the given length.
 *
 * @param r_dest A pointer to a Variant to hold the newly created String.
 * @param p_contents A pointer to a wide C string.
 * @param p_size The number of characters (not bytes).
 */
ExtensionInterfaceStringNewWithWideCharsAndLen :: #type proc "c" (
    r_dest: StringPtr,
    p_contents: ^c.wchar_t,
    p_char_count: i64,
)

/**
 * @name string_to_latin1_chars
 * @since 4.1
 *
 * Converts a String to a Latin-1 encoded C string.
 *
 * It doesn't write a null terminator.
 *
 * @param p_self A pointer to the String.
 * @param r_text A pointer to the buffer to hold the resulting data. If NULL is passed in, only the length will be computed.
 * @param p_max_write_length The maximum number of characters that can be written to r_text. It has no affect on the return value.
 *
 * @return The resulting encoded string length in characters (not bytes), not including a null terminator.
 */
ExtensionInterfaceStringToLatin1Chars :: #type proc "c" (
    p_self: StringPtr,
    r_text: cstring,
    p_max_write_length: i64,
) -> i64

/**
 * @name string_to_utf8_chars
 * @since 4.1
 *
 * Converts a String to a UTF-8 encoded C string.
 *
 * It doesn't write a null terminator.
 *
 * @param p_self A pointer to the String.
 * @param r_text A pointer to the buffer to hold the resulting data. If NULL is passed in, only the length will be computed.
 * @param p_max_write_length The maximum number of characters that can be written to r_text. It has no affect on the return value.
 *
 * @return The resulting encoded string length in characters (not bytes), not including a null terminator.
 */
ExtensionInterfaceStringToUtf8Chars :: #type proc "c" (
    p_self: StringPtr,
    r_text: cstring,
    p_max_write_length: i64,
) -> i64

/**
 * @name string_to_utf16_chars
 * @since 4.1
 *
 * Converts a String to a UTF-16 encoded C string.
 *
 * It doesn't write a null terminator.
 *
 * @param p_self A pointer to the String.
 * @param r_text A pointer to the buffer to hold the resulting data. If NULL is passed in, only the length will be computed.
 * @param p_max_write_length The maximum number of characters that can be written to r_text. It has no affect on the return value.
 *
 * @return The resulting encoded string length in characters (not bytes), not including a null terminator.
 */
ExtensionInterfaceStringToUtf16Chars :: #type proc "c" (
    p_self: StringPtr,
    r_text: ^u16,
    p_max_write_length: i64,
) -> i64

/**
 * @name string_to_utf32_chars
 * @since 4.1
 *
 * Converts a String to a UTF-32 encoded C string.
 *
 * It doesn't write a null terminator.
 *
 * @param p_self A pointer to the String.
 * @param r_text A pointer to the buffer to hold the resulting data. If NULL is passed in, only the length will be computed.
 * @param p_max_write_length The maximum number of characters that can be written to r_text. It has no affect on the return value.
 *
 * @return The resulting encoded string length in characters (not bytes), not including a null terminator.
 */
ExtensionInterfaceStringToUtf32Chars :: #type proc "c" (
    p_self: StringPtr,
    r_text: ^u32,
    p_max_write_length: i64,
) -> i64

/**
 * @name string_to_wide_chars
 * @since 4.1
 *
 * Converts a String to a wide C string.
 *
 * It doesn't write a null terminator.
 *
 * @param p_self A pointer to the String.
 * @param r_text A pointer to the buffer to hold the resulting data. If NULL is passed in, only the length will be computed.
 * @param p_max_write_length The maximum number of characters that can be written to r_text. It has no affect on the return value.
 *
 * @return The resulting encoded string length in characters (not bytes), not including a null terminator.
 */
ExtensionInterfaceStringToWideChars :: #type proc "c" (
    p_self: StringPtr,
    r_text: ^c.wchar_t,
    p_max_write_length: i64,
) -> i64

/**
 * @name string_operator_index
 * @since 4.1
 *
 * Gets a pointer to the character at the given index from a String.
 *
 * @param p_self A pointer to the String.
 * @param p_index The index.
 *
 * @return A pointer to the requested character.
 */
ExtensionInterfaceStringOperatorIndex :: #type proc "c" (p_self: StringPtr, p_index: i64) -> ^u32

/**
 * @name string_operator_index_const
 * @since 4.1
 *
 * Gets a const pointer to the character at the given index from a String.
 *
 * @param p_self A pointer to the String.
 * @param p_index The index.
 *
 * @return A const pointer to the requested character.
 */
ExtensionInterfaceStringOperatorIndexConst :: #type proc "c" (p_self: StringPtr, p_index: i64) -> ^u32

/**
 * @name string_operator_plus_eq_string
 * @since 4.1
 *
 * Appends another String to a String.
 *
 * @param p_self A pointer to the String.
 * @param p_b A pointer to the other String to append.
 */
ExtensionInterfaceStringOperatorPlusEqString :: #type proc "c" (p_self: StringPtr, p_b: StringPtr)

/**
 * @name string_operator_plus_eq_char
 * @since 4.1
 *
 * Appends a character to a String.
 *
 * @param p_self A pointer to the String.
 * @param p_b A pointer to the character to append.
 */
ExtensionInterfaceStringOperatorPlusEqChar :: #type proc "c" (p_self: StringPtr, p_b: u32)

/**
 * @name string_operator_plus_eq_cstr
 * @since 4.1
 *
 * Appends a Latin-1 encoded C string to a String.
 *
 * @param p_self A pointer to the String.
 * @param p_b A pointer to a Latin-1 encoded C string (null terminated).
 */
ExtensionInterfaceStringOperatorPlusEqCstr :: #type proc "c" (p_self: StringPtr, p_b: cstring)

/**
 * @name string_operator_plus_eq_wcstr
 * @since 4.1
 *
 * Appends a wide C string to a String.
 *
 * @param p_self A pointer to the String.
 * @param p_b A pointer to a wide C string (null terminated).
 */
ExtensionInterfaceStringOperatorPlusEqWcstr :: #type proc "c" (p_self: StringPtr, p_b: ^c.wchar_t)

/**
 * @name string_operator_plus_eq_c32str
 * @since 4.1
 *
 * Appends a UTF-32 encoded C string to a String.
 *
 * @param p_self A pointer to the String.
 * @param p_b A pointer to a UTF-32 encoded C string (null terminated).
 */
ExtensionInterfaceStringOperatorPlusEqC32str :: #type proc "c" (p_self: StringPtr, p_b: ^u32)

/**
 * @name string_resize
 * @since 4.2
 *
 * Resizes the underlying string data to the given number of characters.
 *
 * Space needs to be allocated for the null terminating character ('\0') which
 * also must be added manually, in order for all string functions to work correctly.
 *
 * Warning: This is an error-prone operation - only use it if there's no other
 * efficient way to accomplish your goal.
 *
 * @param p_self A pointer to the String.
 * @param p_resize The new length for the String.
 *
 * @return Error code signifying if the operation successful.
 */
ExtensionInterfaceStringResize :: #type proc "c" (p_self: StringPtr, p_resize: i64) -> i64

/**
 * @name string_name_new_with_latin1_chars
 * @since 4.2
 *
 * Creates a StringName from a Latin-1 encoded C string.
 *
 * If `p_is_static` is true, then:
 * - The StringName will reuse the `p_contents` buffer instead of copying it.
 *   You must guarantee that the buffer remains valid for the duration of the application (e.g. string literal).
 * - You must not call a destructor for this StringName. Incrementing the initial reference once should achieve this.
 *
 * `p_is_static` is purely an optimization and can easily introduce undefined behavior if used wrong. In case of doubt, set it to false.
 *
 * @param r_dest A pointer to uninitialized storage, into which the newly created StringName is constructed.
 * @param p_contents A pointer to a C string (null terminated and Latin-1 or ASCII encoded).
 * @param p_is_static Whether the StringName reuses the buffer directly (see above).
 */
ExtensionInterfaceStringNameNewWithLatin1Chars :: #type proc "c" (
    r_dest: StringNamePtr,
    p_contents: cstring,
    p_is_static: bool,
)

/**
 * @name string_name_new_with_utf8_chars
 * @since 4.2
 *
 * Creates a StringName from a UTF-8 encoded C string.
 *
 * @param r_dest A pointer to uninitialized storage, into which the newly created StringName is constructed.
 * @param p_contents A pointer to a C string (null terminated and UTF-8 encoded).
 */
ExtensionInterfaceStringNameNewWithUtf8Chars :: #type proc "c" (r_dest: StringNamePtr, p_contents: cstring)

/**
 * @name string_name_new_with_utf8_chars_and_len
 * @since 4.2
 *
 * Creates a StringName from a UTF-8 encoded string with a given number of characters.
 *
 * @param r_dest A pointer to uninitialized storage, into which the newly created StringName is constructed.
 * @param p_contents A pointer to a C string (null terminated and UTF-8 encoded).
 * @param p_size The number of bytes (not UTF-8 code points).
 */
ExtensionInterfaceStringNameNewWithUtf8CharsAndLen :: #type proc "c" (
    r_dest: StringNamePtr,
    p_contents: cstring,
    p_size: i64,
)

/**
 * @name xml_parser_open_buffer
 * @since 4.1
 *
 * Opens a raw XML buffer on an XMLParser instance.
 *
 * @param p_instance A pointer to an XMLParser object.
 * @param p_buffer A pointer to the buffer.
 * @param p_size The size of the buffer.
 *
 * @return A Godot error code (ex. OK, ERR_INVALID_DATA, etc).
 *
 * @see XMLParser::open_buffer()
 */
ExtensionInterfaceXmlParserOpenBuffer :: #type proc "c" (p_instance: ObjectPtr, p_buffer: ^u8, p_size: c.size_t) -> i64

/**
 * @name file_access_store_buffer
 * @since 4.1
 *
 * Stores the given buffer using an instance of FileAccess.
 *
 * @param p_instance A pointer to a FileAccess object.
 * @param p_src A pointer to the buffer.
 * @param p_length The size of the buffer.
 *
 * @see FileAccess::store_buffer()
 */
ExtensionInterfaceFileAccessStoreBuffer :: #type proc "c" (p_instance: ObjectPtr, p_src: ^u8, p_length: u64)

/**
 * @name file_access_get_buffer
 * @since 4.1
 *
 * Reads the next p_length bytes into the given buffer using an instance of FileAccess.
 *
 * @param p_instance A pointer to a FileAccess object.
 * @param p_dst A pointer to the buffer to store the data.
 * @param p_length The requested number of bytes to read.
 *
 * @return The actual number of bytes read (may be less than requested).
 */
ExtensionInterfaceFileAccessGetBuffer :: #type proc "c" (p_instance: ObjectPtr, p_dst: ^u8, p_length: u64) -> u64

/**
 * @name image_ptrw
 * @since 4.3
 *
 * Returns writable pointer to internal Image buffer.
 *
 * @param p_instance A pointer to a Image object.
 *
 * @return Pointer to internal Image buffer.
 *
 * @see Image::ptrw()
 */
ExtensionInterfaceImagePtrw :: #type proc "c" (p_instance: ObjectPtr) -> ^u8

/**
 * @name image_ptr
 * @since 4.3
 *
 * Returns read only pointer to internal Image buffer.
 *
 * @param p_instance A pointer to a Image object.
 *
 * @return Pointer to internal Image buffer.
 *
 * @see Image::ptr()
 */
ExtensionInterfaceImagePtr :: #type proc "c" (p_instance: ObjectPtr) -> ^u8

/**
 * @name worker_thread_pool_add_native_group_task
 * @since 4.1
 *
 * Adds a group task to an instance of WorkerThreadPool.
 *
 * @param p_instance A pointer to a WorkerThreadPool object.
 * @param p_func A pointer to a function to run in the thread pool.
 * @param p_userdata A pointer to arbitrary data which will be passed to p_func.
 * @param p_tasks The number of tasks needed in the group.
 * @param p_high_priority Whether or not this is a high priority task.
 * @param p_description A pointer to a String with the task description.
 *
 * @return The task group ID.
 *
 * @see WorkerThreadPool::add_group_task()
 */
ExtensionInterfaceWorkerThreadPoolAddNativeGroupTask :: #type proc "c" (
    p_instance: ObjectPtr,
    p_func: proc "c" (_: rawptr, _: c.uint32_t),
    p_userdata: rawptr,
    p_elements: int,
    p_tasks: int,
    p_high_priority: bool,
    p_description: StringPtr,
) -> i64

/**
 * @name worker_thread_pool_add_native_task
 * @since 4.1
 *
 * Adds a task to an instance of WorkerThreadPool.
 *
 * @param p_instance A pointer to a WorkerThreadPool object.
 * @param p_func A pointer to a function to run in the thread pool.
 * @param p_userdata A pointer to arbitrary data which will be passed to p_func.
 * @param p_high_priority Whether or not this is a high priority task.
 * @param p_description A pointer to a String with the task description.
 *
 * @return The task ID.
 */
ExtensionInterfaceWorkerThreadPoolAddNativeTask :: #type proc "c" (
    p_instance: ObjectPtr,
    p_func: proc "c" (_: rawptr),
    p_userdata: rawptr,
    p_high_priority: bool,
    p_description: StringPtr,
) -> i64

/**
 * @name packed_byte_array_operator_index
 * @since 4.1
 *
 * Gets a pointer to a byte in a PackedByteArray.
 *
 * @param p_self A pointer to a PackedByteArray object.
 * @param p_index The index of the byte to get.
 *
 * @return A pointer to the requested byte.
 */
ExtensionInterfacePackedByteArrayOperatorIndex :: #type proc "c" (p_self: TypePtr, p_index: i64) -> ^u8

/**
 * @name packed_byte_array_operator_index_const
 * @since 4.1
 *
 * Gets a const pointer to a byte in a PackedByteArray.
 *
 * @param p_self A const pointer to a PackedByteArray object.
 * @param p_index The index of the byte to get.
 *
 * @return A const pointer to the requested byte.
 */
ExtensionInterfacePackedByteArrayOperatorIndexConst :: #type proc "c" (p_self: TypePtr, p_index: i64) -> ^u8

/**
 * @name packed_float32_array_operator_index
 * @since 4.1
 *
 * Gets a pointer to a 32-bit float in a PackedFloat32Array.
 *
 * @param p_self A pointer to a PackedFloat32Array object.
 * @param p_index The index of the float to get.
 *
 * @return A pointer to the requested 32-bit float.
 */
ExtensionInterfacePackedFloat32ArrayOperatorIndex :: #type proc "c" (p_self: TypePtr, p_index: i64) -> ^float

/**
 * @name packed_float32_array_operator_index_const
 * @since 4.1
 *
 * Gets a const pointer to a 32-bit float in a PackedFloat32Array.
 *
 * @param p_self A const pointer to a PackedFloat32Array object.
 * @param p_index The index of the float to get.
 *
 * @return A const pointer to the requested 32-bit float.
 */
ExtensionInterfacePackedFloat32ArrayOperatorIndexConst :: #type proc "c" (p_self: TypePtr, p_index: i64) -> ^float

/**
 * @name packed_float64_array_operator_index
 * @since 4.1
 *
 * Gets a pointer to a 64-bit float in a PackedFloat64Array.
 *
 * @param p_self A pointer to a PackedFloat64Array object.
 * @param p_index The index of the float to get.
 *
 * @return A pointer to the requested 64-bit float.
 */
ExtensionInterfacePackedFloat64ArrayOperatorIndex :: #type proc "c" (p_self: TypePtr, p_index: i64) -> ^f64

/**
 * @name packed_float64_array_operator_index_const
 * @since 4.1
 *
 * Gets a const pointer to a 64-bit float in a PackedFloat64Array.
 *
 * @param p_self A const pointer to a PackedFloat64Array object.
 * @param p_index The index of the float to get.
 *
 * @return A const pointer to the requested 64-bit float.
 */
ExtensionInterfacePackedFloat64ArrayOperatorIndexConst :: #type proc "c" (p_self: TypePtr, p_index: i64) -> ^f64

/**
 * @name packed_int32_array_operator_index
 * @since 4.1
 *
 * Gets a pointer to a 32-bit integer in a PackedInt32Array.
 *
 * @param p_self A pointer to a PackedInt32Array object.
 * @param p_index The index of the integer to get.
 *
 * @return A pointer to the requested 32-bit integer.
 */
ExtensionInterfacePackedInt32ArrayOperatorIndex :: #type proc "c" (p_self: TypePtr, p_index: i64) -> ^i32

/**
 * @name packed_int32_array_operator_index_const
 * @since 4.1
 *
 * Gets a const pointer to a 32-bit integer in a PackedInt32Array.
 *
 * @param p_self A const pointer to a PackedInt32Array object.
 * @param p_index The index of the integer to get.
 *
 * @return A const pointer to the requested 32-bit integer.
 */
ExtensionInterfacePackedInt32ArrayOperatorIndexConst :: #type proc "c" (p_self: TypePtr, p_index: i64) -> ^i32

/**
 * @name packed_int64_array_operator_index
 * @since 4.1
 *
 * Gets a pointer to a 64-bit integer in a PackedInt64Array.
 *
 * @param p_self A pointer to a PackedInt64Array object.
 * @param p_index The index of the integer to get.
 *
 * @return A pointer to the requested 64-bit integer.
 */
ExtensionInterfacePackedInt64ArrayOperatorIndex :: #type proc "c" (p_self: TypePtr, p_index: i64) -> ^i64

/**
 * @name packed_int64_array_operator_index_const
 * @since 4.1
 *
 * Gets a const pointer to a 64-bit integer in a PackedInt64Array.
 *
 * @param p_self A const pointer to a PackedInt64Array object.
 * @param p_index The index of the integer to get.
 *
 * @return A const pointer to the requested 64-bit integer.
 */
ExtensionInterfacePackedInt64ArrayOperatorIndexConst :: #type proc "c" (p_self: TypePtr, p_index: i64) -> ^i64

/**
 * @name packed_string_array_operator_index
 * @since 4.1
 *
 * Gets a pointer to a string in a PackedStringArray.
 *
 * @param p_self A pointer to a PackedStringArray object.
 * @param p_index The index of the String to get.
 *
 * @return A pointer to the requested String.
 */
ExtensionInterfacePackedStringArrayOperatorIndex :: #type proc "c" (p_self: TypePtr, p_index: i64) -> StringPtr

/**
 * @name packed_string_array_operator_index_const
 * @since 4.1
 *
 * Gets a const pointer to a string in a PackedStringArray.
 *
 * @param p_self A const pointer to a PackedStringArray object.
 * @param p_index The index of the String to get.
 *
 * @return A const pointer to the requested String.
 */
ExtensionInterfacePackedStringArrayOperatorIndexConst :: #type proc "c" (p_self: TypePtr, p_index: i64) -> StringPtr

/**
 * @name packed_vector2_array_operator_index
 * @since 4.1
 *
 * Gets a pointer to a Vector2 in a PackedVector2Array.
 *
 * @param p_self A pointer to a PackedVector2Array object.
 * @param p_index The index of the Vector2 to get.
 *
 * @return A pointer to the requested Vector2.
 */
ExtensionInterfacePackedVector2ArrayOperatorIndex :: #type proc "c" (p_self: TypePtr, p_index: i64) -> TypePtr

/**
 * @name packed_vector2_array_operator_index_const
 * @since 4.1
 *
 * Gets a const pointer to a Vector2 in a PackedVector2Array.
 *
 * @param p_self A const pointer to a PackedVector2Array object.
 * @param p_index The index of the Vector2 to get.
 *
 * @return A const pointer to the requested Vector2.
 */
ExtensionInterfacePackedVector2ArrayOperatorIndexConst :: #type proc "c" (p_self: TypePtr, p_index: i64) -> TypePtr

/**
 * @name packed_vector3_array_operator_index
 * @since 4.1
 *
 * Gets a pointer to a Vector3 in a PackedVector3Array.
 *
 * @param p_self A pointer to a PackedVector3Array object.
 * @param p_index The index of the Vector3 to get.
 *
 * @return A pointer to the requested Vector3.
 */
ExtensionInterfacePackedVector3ArrayOperatorIndex :: #type proc "c" (p_self: TypePtr, p_index: i64) -> TypePtr

/**
 * @name packed_vector3_array_operator_index_const
 * @since 4.1
 *
 * Gets a const pointer to a Vector3 in a PackedVector3Array.
 *
 * @param p_self A const pointer to a PackedVector3Array object.
 * @param p_index The index of the Vector3 to get.
 *
 * @return A const pointer to the requested Vector3.
 */
ExtensionInterfacePackedVector3ArrayOperatorIndexConst :: #type proc "c" (p_self: TypePtr, p_index: i64) -> TypePtr

/**
 * @name packed_vector4_array_operator_index
 * @since 4.3
 *
 * Gets a pointer to a Vector4 in a PackedVector4Array.
 *
 * @param p_self A pointer to a PackedVector4Array object.
 * @param p_index The index of the Vector4 to get.
 *
 * @return A pointer to the requested Vector4.
 */
ExtensionInterfacePackedVector4ArrayOperatorIndex :: #type proc "c" (p_self: TypePtr, p_index: i64) -> TypePtr

/**
 * @name packed_vector4_array_operator_index_const
 * @since 4.3
 *
 * Gets a const pointer to a Vector4 in a PackedVector4Array.
 *
 * @param p_self A const pointer to a PackedVector4Array object.
 * @param p_index The index of the Vector4 to get.
 *
 * @return A const pointer to the requested Vector4.
 */
ExtensionInterfacePackedVector4ArrayOperatorIndexConst :: #type proc "c" (p_self: TypePtr, p_index: i64) -> TypePtr

/**
 * @name packed_color_array_operator_index
 * @since 4.1
 *
 * Gets a pointer to a color in a PackedColorArray.
 *
 * @param p_self A pointer to a PackedColorArray object.
 * @param p_index The index of the Color to get.
 *
 * @return A pointer to the requested Color.
 */
ExtensionInterfacePackedColorArrayOperatorIndex :: #type proc "c" (p_self: TypePtr, p_index: i64) -> TypePtr

/**
 * @name packed_color_array_operator_index_const
 * @since 4.1
 *
 * Gets a const pointer to a color in a PackedColorArray.
 *
 * @param p_self A const pointer to a PackedColorArray object.
 * @param p_index The index of the Color to get.
 *
 * @return A const pointer to the requested Color.
 */
ExtensionInterfacePackedColorArrayOperatorIndexConst :: #type proc "c" (p_self: TypePtr, p_index: i64) -> TypePtr

/**
 * @name array_operator_index
 * @since 4.1
 *
 * Gets a pointer to a Variant in an Array.
 *
 * @param p_self A pointer to an Array object.
 * @param p_index The index of the Variant to get.
 *
 * @return A pointer to the requested Variant.
 */
ExtensionInterfaceArrayOperatorIndex :: #type proc "c" (p_self: TypePtr, p_index: i64) -> VariantPtr

/**
 * @name array_operator_index_const
 * @since 4.1
 *
 * Gets a const pointer to a Variant in an Array.
 *
 * @param p_self A const pointer to an Array object.
 * @param p_index The index of the Variant to get.
 *
 * @return A const pointer to the requested Variant.
 */
ExtensionInterfaceArrayOperatorIndexConst :: #type proc "c" (p_self: TypePtr, p_index: i64) -> VariantPtr

/**
 * @name array_ref
 * @since 4.1
 *
 * Sets an Array to be a reference to another Array object.
 *
 * @param p_self A pointer to the Array object to update.
 * @param p_from A pointer to the Array object to reference.
 */
ExtensionInterfaceArrayRef :: #type proc "c" (p_self: TypePtr, p_from: TypePtr)

/**
 * @name array_set_typed
 * @since 4.1
 *
 * Makes an Array into a typed Array.
 *
 * @param p_self A pointer to the Array.
 * @param p_type The type of Variant the Array will store.
 * @param p_class_name A pointer to a StringName with the name of the object (if p_type is GDEXTENSION_VARIANT_TYPE_OBJECT).
 * @param p_script A pointer to a Script object (if p_type is GDEXTENSION_VARIANT_TYPE_OBJECT and the base class is extended by a script).
 */
ExtensionInterfaceArraySetTyped :: #type proc "c" (
    p_self: TypePtr,
    p_type: VariantType,
    p_class_name: StringNamePtr,
    p_script: VariantPtr,
)

/**
 * @name dictionary_operator_index
 * @since 4.1
 *
 * Gets a pointer to a Variant in a Dictionary with the given key.
 *
 * @param p_self A pointer to a Dictionary object.
 * @param p_key A pointer to a Variant representing the key.
 *
 * @return A pointer to a Variant representing the value at the given key.
 */
ExtensionInterfaceDictionaryOperatorIndex :: #type proc "c" (p_self: TypePtr, p_key: VariantPtr) -> VariantPtr

/**
 * @name dictionary_operator_index_const
 * @since 4.1
 *
 * Gets a const pointer to a Variant in a Dictionary with the given key.
 *
 * @param p_self A const pointer to a Dictionary object.
 * @param p_key A pointer to a Variant representing the key.
 *
 * @return A const pointer to a Variant representing the value at the given key.
 */
ExtensionInterfaceDictionaryOperatorIndexConst :: #type proc "c" (p_self: TypePtr, p_key: VariantPtr) -> VariantPtr

/**
 * @name object_method_bind_call
 * @since 4.1
 *
 * Calls a method on an Object.
 *
 * @param p_method_bind A pointer to the MethodBind representing the method on the Object's class.
 * @param p_instance A pointer to the Object.
 * @param p_args A pointer to a C array of Variants representing the arguments.
 * @param p_arg_count The number of arguments.
 * @param r_ret A pointer to Variant which will receive the return value.
 * @param r_error A pointer to a GDExtensionCallError struct that will receive error information.
 */
ExtensionInterfaceObjectMethodBindCall :: #type proc "c" (
    p_method_bind: MethodBindPtr,
    p_instance: ObjectPtr,
    p_args: [^]VariantPtr,
    p_arg_count: i64,
    r_ret: VariantPtr,
    r_error: ^CallError,
)

/**
 * @name object_method_bind_ptrcall
 * @since 4.1
 *
 * Calls a method on an Object (using a "ptrcall").
 *
 * @param p_method_bind A pointer to the MethodBind representing the method on the Object's class.
 * @param p_instance A pointer to the Object.
 * @param p_args A pointer to a C array representing the arguments.
 * @param r_ret A pointer to the Object that will receive the return value.
 */
ExtensionInterfaceObjectMethodBindPtrcall :: #type proc "c" (
    p_method_bind: MethodBindPtr,
    p_instance: ObjectPtr,
    p_args: ^TypePtr,
    r_ret: TypePtr,
)

/**
 * @name object_destroy
 * @since 4.1
 *
 * Destroys an Object.
 *
 * @param p_o A pointer to the Object.
 */
ExtensionInterfaceObjectDestroy :: #type proc "c" (p_o: ObjectPtr)

/**
 * @name global_get_singleton
 * @since 4.1
 *
 * Gets a global singleton by name.
 *
 * @param p_name A pointer to a StringName with the singleton name.
 *
 * @return A pointer to the singleton Object.
 */
ExtensionInterfaceGlobalGetSingleton :: #type proc "c" (p_name: StringNamePtr) -> ObjectPtr

/**
 * @name object_get_instance_binding
 * @since 4.1
 *
 * Gets a pointer representing an Object's instance binding.
 *
 * @param p_o A pointer to the Object.
 * @param p_library A token the library received by the GDExtension's entry point function.
 * @param p_callbacks A pointer to a InstanceBindingCallbacks struct.
 *
 * @return
 */
ExtensionInterfaceObjectGetInstanceBinding :: #type proc "c" (
    p_o: ObjectPtr,
    p_token: rawptr,
    p_callbacks: ^InstanceBindingCallbacks,
) -> rawptr

/**
 * @name object_set_instance_binding
 * @since 4.1
 *
 * Sets an Object's instance binding.
 *
 * @param p_o A pointer to the Object.
 * @param p_library A token the library received by the GDExtension's entry point function.
 * @param p_binding A pointer to the instance binding.
 * @param p_callbacks A pointer to a InstanceBindingCallbacks struct.
 */
ExtensionInterfaceObjectSetInstanceBinding :: #type proc "c" (
    p_o: ObjectPtr,
    p_token: rawptr,
    p_binding: rawptr,
    p_callbacks: ^InstanceBindingCallbacks,
)

/**
 * @name object_free_instance_binding
 * @since 4.2
 *
 * Free an Object's instance binding.
 *
 * @param p_o A pointer to the Object.
 * @param p_library A token the library received by the GDExtension's entry point function.
 */
ExtensionInterfaceObjectFreeInstanceBinding :: #type proc "c" (p_o: ObjectPtr, p_token: rawptr)

/**
 * @name object_set_instance
 * @since 4.1
 *
 * Sets an extension class instance on a Object.
 *
 * @param p_o A pointer to the Object.
 * @param p_classname A pointer to a StringName with the registered extension class's name.
 * @param p_instance A pointer to the extension class instance.
 */
ExtensionInterfaceObjectSetInstance :: #type proc "c" (
    p_o: ObjectPtr,
    p_classname: StringNamePtr,
    p_instance: ExtensionClassInstancePtr,
)

/**
 * @name object_get_class_name
 * @since 4.1
 *
 * Gets the class name of an Object.
 *
 * If the GDExtension wraps the Godot object in an abstraction specific to its class, this is the
 * function that should be used to determine which wrapper to use.
 *
 * @param p_object A pointer to the Object.
 * @param p_library A pointer the library received by the GDExtension's entry point function.
 * @param r_class_name A pointer to a String to receive the class name.
 *
 * @return true if successful in getting the class name; otherwise false.
 */
ExtensionInterfaceObjectGetClassName :: #type proc "c" (
    p_object: ObjectPtr,
    p_library: ExtensionClassLibraryPtr,
    r_class_name: StringNamePtr,
) -> bool

/**
 * @name object_cast_to
 * @since 4.1
 *
 * Casts an Object to a different type.
 *
 * @param p_object A pointer to the Object.
 * @param p_class_tag A pointer uniquely identifying a built-in class in the ClassDB.
 *
 * @return Returns a pointer to the Object, or NULL if it can't be cast to the requested type.
 */
ExtensionInterfaceObjectCastTo :: #type proc "c" (p_object: ObjectPtr, p_class_tag: rawptr) -> ObjectPtr

/**
 * @name object_get_instance_from_id
 * @since 4.1
 *
 * Gets an Object by its instance ID.
 *
 * @param p_instance_id The instance ID.
 *
 * @return A pointer to the Object.
 */
ExtensionInterfaceObjectGetInstanceFromId :: #type proc "c" (p_instance_id: ObjectInstanceId) -> ObjectPtr

/**
 * @name object_get_instance_id
 * @since 4.1
 *
 * Gets the instance ID from an Object.
 *
 * @param p_object A pointer to the Object.
 *
 * @return The instance ID.
 */
ExtensionInterfaceObjectGetInstanceId :: #type proc "c" (p_object: ObjectPtr) -> ObjectInstanceId

/**
 * @name object_has_script_method
 * @since 4.3
 *
 * Checks if this object has a script with the given method.
 *
 * @param p_object A pointer to the Object.
 * @param p_method A pointer to a StringName identifying the method.
 *
 * @returns true if the object has a script and that script has a method with the given name. Returns false if the object has no script.
 */
ExtensionInterfaceObjectHasScriptMethod :: #type proc "c" (p_object: ObjectPtr, p_method: StringNamePtr) -> bool

/**
 * @name object_call_script_method
 * @since 4.3
 *
 * Call the given script method on this object.
 *
 * @param p_object A pointer to the Object.
 * @param p_method A pointer to a StringName identifying the method.
 * @param p_args A pointer to a C array of Variant.
 * @param p_argument_count The number of arguments.
 * @param r_return A pointer a Variant which will be assigned the return value.
 * @param r_error A pointer the structure which will hold error information.
 */
ExtensionInterfaceObjectCallScriptMethod :: #type proc "c" (
    p_object: ObjectPtr,
    p_method: StringNamePtr,
    p_args: ^VariantPtr,
    p_argument_count: i64,
    r_return: VariantPtr,
    r_error: ^CallError,
)

/**
 * @name ref_get_object
 * @since 4.1
 *
 * Gets the Object from a reference.
 *
 * @param p_ref A pointer to the reference.
 *
 * @return A pointer to the Object from the reference or NULL.
 */
ExtensionInterfaceRefGetObject :: #type proc "c" (p_ref: RefPtr) -> ObjectPtr

/**
 * @name ref_set_object
 * @since 4.1
 *
 * Sets the Object referred to by a reference.
 *
 * @param p_ref A pointer to the reference.
 * @param p_object A pointer to the Object to refer to.
 */
ExtensionInterfaceRefSetObject :: #type proc "c" (p_ref: RefPtr, p_object: ObjectPtr)

/**
 * @name script_instance_create
 * @since 4.1
 * @deprecated in Godot 4.2. Use `script_instance_create3` instead.
 *
 * Creates a script instance that contains the given info and instance data.
 *
 * @param p_info A pointer to a GDExtensionScriptInstanceInfo struct.
 * @param p_instance_data A pointer to a data representing the script instance in the GDExtension. This will be passed to all the function pointers on p_info.
 *
 * @return A pointer to a ScriptInstanceExtension object.
 */
ExtensionInterfaceScriptInstanceCreate :: #type proc "c" (
    p_info: ^ExtensionScriptInstanceInfo,
    p_instance_data: ExtensionScriptInstanceDataPtr,
) -> ScriptInstancePtr

/**
 * @name script_instance_create2
 * @since 4.2
 * @deprecated in Godot 4.3. Use `script_instance_create3` instead.
 *
 * Creates a script instance that contains the given info and instance data.
 *
 * @param p_info A pointer to a GDExtensionScriptInstanceInfo2 struct.
 * @param p_instance_data A pointer to a data representing the script instance in the GDExtension. This will be passed to all the function pointers on p_info.
 *
 * @return A pointer to a ScriptInstanceExtension object.
 */
ExtensionInterfaceScriptInstanceCreate2 :: #type proc "c" (
    p_info: ^ExtensionScriptInstanceInfo2,
    p_instance_data: ExtensionScriptInstanceDataPtr,
) -> ScriptInstancePtr

/**
 * @name script_instance_create3
 * @since 4.3
 *
 * Creates a script instance that contains the given info and instance data.
 *
 * @param p_info A pointer to a GDExtensionScriptInstanceInfo3 struct.
 * @param p_instance_data A pointer to a data representing the script instance in the GDExtension. This will be passed to all the function pointers on p_info.
 *
 * @return A pointer to a ScriptInstanceExtension object.
 */
ExtensionInterfaceScriptInstanceCreate3 :: #type proc "c" (
    p_info: ^ExtensionScriptInstanceInfo3,
    p_instance_data: ExtensionScriptInstanceDataPtr,
) -> ScriptInstancePtr

/**
 * @name placeholder_script_instance_create
 * @since 4.2
 *
 * Creates a placeholder script instance for a given script and instance.
 *
 * This interface is optional as a custom placeholder could also be created with script_instance_create().
 *
 * @param p_language A pointer to a ScriptLanguage.
 * @param p_script A pointer to a Script.
 * @param p_owner A pointer to an Object.
 *
 * @return A pointer to a PlaceHolderScriptInstance object.
 */
ExtensionInterfacePlaceHolderScriptInstanceCreate :: #type proc "c" (
    p_language: ObjectPtr,
    p_script: ObjectPtr,
    p_owner: ObjectPtr,
) -> ScriptInstancePtr

/**
 * @name placeholder_script_instance_update
 * @since 4.2
 *
 * Updates a placeholder script instance with the given properties and values.
 *
 * The passed in placeholder must be an instance of PlaceHolderScriptInstance
 * such as the one returned by placeholder_script_instance_create().
 *
 * @param p_placeholder A pointer to a PlaceHolderScriptInstance.
 * @param p_properties A pointer to an Array of Dictionary representing PropertyInfo.
 * @param p_values A pointer to a Dictionary mapping StringName to Variant values.
 */
ExtensionInterfacePlaceHolderScriptInstanceUpdate :: #type proc "c" (
    p_placeholder: ScriptInstancePtr,
    p_properties: TypePtr,
    p_values: TypePtr,
)

/**
 * @name object_get_script_instance
 * @since 4.2
 *
 * Get the script instance data attached to this object.
 *
 * @param p_object A pointer to the Object.
 * @param p_language A pointer to the language expected for this script instance.
 *
 * @return A GDExtensionScriptInstanceDataPtr that was attached to this object as part of script_instance_create.
 */
ExtensionInterfaceObjectGetScriptInstance :: #type proc "c" (
    p_object: ObjectPtr,
    p_language: ObjectPtr,
) -> ExtensionScriptInstanceDataPtr

/**
 * @name callable_custom_create
 * @since 4.2
 * @deprecated in Godot 4.3. Use `callable_custom_create2` instead.
 *
 * Creates a custom Callable object from a function pointer.
 *
 * Provided struct can be safely freed once the function returns.
 *
 * @param r_callable A pointer that will receive the new Callable.
 * @param p_callable_custom_info The info required to construct a Callable.
 */
ExtensionInterfaceCallableCustomCreate :: #type proc "c" (
    r_callable: TypePtr,
    p_callable_custom_info: ^ExtensionCallableCustomInfo,
)

/**
 * @name callable_custom_create2
 * @since 4.3
 *
 * Creates a custom Callable object from a function pointer.
 *
 * Provided struct can be safely freed once the function returns.
 *
 * @param r_callable A pointer that will receive the new Callable.
 * @param p_callable_custom_info The info required to construct a Callable.
 */
ExtensionInterfaceCallableCustomCreate2 :: #type proc "c" (
    r_callable: TypePtr,
    p_callable_custom_info: ^ExtensionCallableCustomInfo2,
)

/**
 * @name callable_custom_get_userdata
 * @since 4.2
 *
 * Retrieves the userdata pointer from a custom Callable.
 *
 * If the Callable is not a custom Callable or the token does not match the one provided to callable_custom_create() via GDExtensionCallableCustomInfo then NULL will be returned.
 *
 * @param p_callable A pointer to a Callable.
 * @param p_token A pointer to an address that uniquely identifies the GDExtension.
 */
ExtensionInterfaceCallableCustomGetUserData :: #type proc "c" (p_callable: TypePtr, p_token: rawptr) -> rawptr

/**
 * @name classdb_construct_object
 * @since 4.1
 *
 * Constructs an Object of the requested class.
 *
 * The passed class must be a built-in godot class, or an already-registered extension class. In both cases, object_set_instance() should be called to fully initialize the object.
 *
 * @param p_classname A pointer to a StringName with the class name.
 *
 * @return A pointer to the newly created Object.
 */
ExtensionInterfaceClassdbConstructObject :: #type proc "c" (p_classname: StringNamePtr) -> ObjectPtr

/**
 * @name classdb_get_method_bind
 * @since 4.1
 *
 * Gets a pointer to the MethodBind in ClassDB for the given class, method and hash.
 *
 * @param p_classname A pointer to a StringName with the class name.
 * @param p_methodname A pointer to a StringName with the method name.
 * @param p_hash A hash representing the function signature.
 *
 * @return A pointer to the MethodBind from ClassDB.
 */
ExtensionInterfaceClassdbGetMethodBind :: #type proc "c" (
    p_classname: StringNamePtr,
    p_methodname: StringNamePtr,
    p_hash: i64,
) -> MethodBindPtr

/**
 * @name classdb_get_class_tag
 * @since 4.1
 *
 * Gets a pointer uniquely identifying the given built-in class in the ClassDB.
 *
 * @param p_classname A pointer to a StringName with the class name.
 *
 * @return A pointer uniquely identifying the built-in class in the ClassDB.
 */
ExtensionInterfaceClassdbGetClassTag :: #type proc "c" (p_classname: StringNamePtr) -> rawptr

/**
 * @name classdb_register_extension_class
 * @since 4.1
 * @deprecated in Godot 4.2. Use `classdb_register_extension_class3` instead.
 *
 * Registers an extension class in the ClassDB.
 *
 * Provided struct can be safely freed once the function returns.
 *
 * @param p_library A pointer the library received by the GDExtension's entry point function.
 * @param p_class_name A pointer to a StringName with the class name.
 * @param p_parent_class_name A pointer to a StringName with the parent class name.
 * @param p_extension_funcs A pointer to a GDExtensionClassCreationInfo struct.
 */
ExtensionInterfaceClassdbRegisterExtensionClass :: #type proc "c" (
    p_library: ExtensionClassLibraryPtr,
    p_class_name: StringNamePtr,
    p_parent_class_name: StringNamePtr,
    p_extension_funcs: ^ExtensionClassCreationInfo,
)

/**
 * @name classdb_register_extension_class2
 * @since 4.2
 * @deprecated in Godot 4.3. Use `classdb_register_extension_class3` instead.
 *
 * Registers an extension class in the ClassDB.
 *
 * Provided struct can be safely freed once the function returns.
 *
 * @param p_library A pointer the library received by the GDExtension's entry point function.
 * @param p_class_name A pointer to a StringName with the class name.
 * @param p_parent_class_name A pointer to a StringName with the parent class name.
 * @param p_extension_funcs A pointer to a GDExtensionClassCreationInfo2 struct.
 */
ExtensionInterfaceClassdbRegisterExtensionClass2 :: #type proc "c" (
    p_library: ExtensionClassLibraryPtr,
    p_class_name: StringNamePtr,
    p_parent_class_name: StringNamePtr,
    p_extension_funcs: ^ExtensionClassCreationInfo2,
)

/**
 * @name classdb_register_extension_class3
 * @since 4.3
 *
 * Registers an extension class in the ClassDB.
 *
 * Provided struct can be safely freed once the function returns.
 *
 * @param p_library A pointer the library received by the GDExtension's entry point function.
 * @param p_class_name A pointer to a StringName with the class name.
 * @param p_parent_class_name A pointer to a StringName with the parent class name.
 * @param p_extension_funcs A pointer to a GDExtensionClassCreationInfo2 struct.
 */
ExtensionInterfaceClassdbRegisterExtensionClass3 :: #type proc "c" (
    p_library: ExtensionClassLibraryPtr,
    p_class_name: StringNamePtr,
    p_parent_class_name: StringNamePtr,
    p_extension_funcs: ^ExtensionClassCreationInfo3,
)

/**
 * @name classdb_register_extension_class_method
 * @since 4.1
 *
 * Registers a method on an extension class in the ClassDB.
 *
 * Provided struct can be safely freed once the function returns.
 *
 * @param p_library A pointer the library received by the GDExtension's entry point function.
 * @param p_class_name A pointer to a StringName with the class name.
 * @param p_method_info A pointer to a GDExtensionClassMethodInfo struct.
 */
ExtensionInterfaceClassdbRegisterExtensionClassMethod :: #type proc "c" (
    p_library: ExtensionClassLibraryPtr,
    p_class_name: StringNamePtr,
    p_method_info: ^ExtensionClassMethodInfo,
)

/**
 * @name classdb_register_extension_class_virtual_method
 * @since 4.3
 *
 * Registers a virtual method on an extension class in ClassDB, that can be implemented by scripts or other extensions.
 *
 * Provided struct can be safely freed once the function returns.
 *
 * @param p_library A pointer the library received by the GDExtension's entry point function.
 * @param p_class_name A pointer to a StringName with the class name.
 * @param p_method_info A pointer to a GDExtensionClassMethodInfo struct.
 */
ExtensionInterfaceClassdbRegisterExtensionClassVirtualMethod :: #type proc "c" (
    p_library: ExtensionClassLibraryPtr,
    p_class_name: StringNamePtr,
    p_method_info: ^ExtensionClassVirtualMethodInfo,
)

/**
 * @name classdb_register_extension_class_integer_constant
 * @since 4.1
 *
 * Registers an integer constant on an extension class in the ClassDB.
 *
 * Note about registering bitfield values (if p_is_bitfield is true): even though p_constant_value is signed, language bindings are
 * advised to treat bitfields as uint64_t, since this is generally clearer and can prevent mistakes like using -1 for setting all bits.
 * Language APIs should thus provide an abstraction that registers bitfields (uint64_t) separately from regular constants (int64_t).
 *
 * @param p_library A pointer the library received by the GDExtension's entry point function.
 * @param p_class_name A pointer to a StringName with the class name.
 * @param p_enum_name A pointer to a StringName with the enum name.
 * @param p_constant_name A pointer to a StringName with the constant name.
 * @param p_constant_value The constant value.
 * @param p_is_bitfield Whether or not this constant is part of a bitfield.
 */
ExtensionInterfaceClassdbRegisterExtensionClassIntegerConstant :: #type proc "c" (
    p_library: ExtensionClassLibraryPtr,
    p_class_name: StringNamePtr,
    p_enum_name: StringNamePtr,
    p_constant_name: StringNamePtr,
    p_constant_value: i64,
    p_is_bitfield: bool,
)

/**
 * @name classdb_register_extension_class_property
 * @since 4.1
 *
 * Registers a property on an extension class in the ClassDB.
 *
 * Provided struct can be safely freed once the function returns.
 *
 * @param p_library A pointer the library received by the GDExtension's entry point function.
 * @param p_class_name A pointer to a StringName with the class name.
 * @param p_info A pointer to a GDExtensionPropertyInfo struct.
 * @param p_setter A pointer to a StringName with the name of the setter method.
 * @param p_getter A pointer to a StringName with the name of the getter method.
 */
ExtensionInterfaceClassdbRegisterExtensionClassProperty :: #type proc "c" (
    p_library: ExtensionClassLibraryPtr,
    p_class_name: StringNamePtr,
    p_info: ^PropertyInfo,
    p_setter: StringNamePtr,
    p_getter: StringNamePtr,
)

/**
 * @name classdb_register_extension_class_property_indexed
 * @since 4.2
 *
 * Registers an indexed property on an extension class in the ClassDB.
 *
 * Provided struct can be safely freed once the function returns.
 *
 * @param p_library A pointer the library received by the GDExtension's entry point function.
 * @param p_class_name A pointer to a StringName with the class name.
 * @param p_info A pointer to a GDExtensionPropertyInfo struct.
 * @param p_setter A pointer to a StringName with the name of the setter method.
 * @param p_getter A pointer to a StringName with the name of the getter method.
 * @param p_index The index to pass as the first argument to the getter and setter methods.
 */
ExtensionInterfaceClassdbRegisterExtensionClassPropertyIndexed :: #type proc "c" (
    p_library: ExtensionClassLibraryPtr,
    p_class_name: StringNamePtr,
    p_info: ^PropertyInfo,
    p_setter: StringNamePtr,
    p_getter: StringNamePtr,
    p_index: i64,
)

/**
 * @name classdb_register_extension_class_property_group
 * @since 4.1
 *
 * Registers a property group on an extension class in the ClassDB.
 *
 * @param p_library A pointer the library received by the GDExtension's entry point function.
 * @param p_class_name A pointer to a StringName with the class name.
 * @param p_group_name A pointer to a String with the group name.
 * @param p_prefix A pointer to a String with the prefix used by properties in this group.
 */
ExtensionInterfaceClassdbRegisterExtensionClassPropertyGroup :: #type proc "c" (
    p_library: ExtensionClassLibraryPtr,
    p_class_name: StringNamePtr,
    p_group_name: StringPtr,
    p_prefix: StringPtr,
)

/**
 * @name classdb_register_extension_class_property_subgroup
 * @since 4.1
 *
 * Registers a property subgroup on an extension class in the ClassDB.
 *
 * @param p_library A pointer the library received by the GDExtension's entry point function.
 * @param p_class_name A pointer to a StringName with the class name.
 * @param p_subgroup_name A pointer to a String with the subgroup name.
 * @param p_prefix A pointer to a String with the prefix used by properties in this subgroup.
 */
ExtensionInterfaceClassdbRegisterExtensionClassPropertySubgroup :: #type proc "c" (
    p_library: ExtensionClassLibraryPtr,
    p_class_name: StringNamePtr,
    p_subgroup_name: StringPtr,
    p_prefix: StringPtr,
)

/**
 * @name classdb_register_extension_class_signal
 * @since 4.1
 *
 * Registers a signal on an extension class in the ClassDB.
 *
 * Provided structs can be safely freed once the function returns.
 *
 * @param p_library A pointer the library received by the GDExtension's entry point function.
 * @param p_class_name A pointer to a StringName with the class name.
 * @param p_signal_name A pointer to a StringName with the signal name.
 * @param p_argument_info A pointer to a GDExtensionPropertyInfo struct.
 * @param p_argument_count The number of arguments the signal receives.
 */
ExtensionInterfaceClassdbRegisterExtensionClassSignal :: #type proc "c" (
    p_library: ExtensionClassLibraryPtr,
    p_class_name: StringNamePtr,
    p_signal_name: StringNamePtr,
    p_argument_info: ^PropertyInfo,
    p_argument_count: i64,
)

/**
 * @name classdb_unregister_extension_class
 * @since 4.1
 *
 * Unregisters an extension class in the ClassDB.
 *
 * @param p_library A pointer the library received by the GDExtension's entry point function.
 * @param p_class_name A pointer to a StringName with the class name.
 */
ExtensionInterfaceClassdbUnregisterExtensionClass :: #type proc "c" (
    p_library: ExtensionClassLibraryPtr,
    p_class_name: StringNamePtr,
)

/**
 * @name get_library_path
 * @since 4.1
 *
 * Gets the path to the current GDExtension library.
 *
 * @param p_library A pointer the library received by the GDExtension's entry point function.
 * @param r_path A pointer to a String which will receive the path.
 */
ExtensionInterfaceGetLibraryPath :: #type proc "c" (p_library: ExtensionClassLibraryPtr, r_path: StringPtr)

/**
 * @name editor_add_plugin
 * @since 4.1
 *
 * Adds an editor plugin.
 *
 * It's safe to call during initialization.
 *
 * @param p_class_name A pointer to a StringName with the name of a class (descending from EditorPlugin) which is already registered with ClassDB.
 */
ExtensionInterfaceEditorAddPlugin :: #type proc "c" (p_class_name: StringNamePtr)

/**
 * @name editor_remove_plugin
 * @since 4.1
 *
 * Removes an editor plugin.
 *
 * @param p_class_name A pointer to a StringName with the name of a class that was previously added as an editor plugin.
 */
ExtensionInterfaceEditorRemovePlugin :: #type proc "c" (p_class_name: StringNamePtr)

/**
 * @name editor_help_load_xml_from_utf8_chars
 * @since 4.3
 *
 * Loads new XML-formatted documentation data in the editor.
 *
 * The provided pointer can be immediately freed once the function returns.
 *
 * @param p_data A pointer to a UTF-8 encoded C string (null terminated).
 */
ExtensionsInterfaceEditorHelpLoadXmlFromUtf8Chars :: #type proc "c" (p_data: cstring)

/**
 * @name editor_help_load_xml_from_utf8_chars_and_len
 * @since 4.3
 *
 * Loads new XML-formatted documentation data in the editor.
 *
 * The provided pointer can be immediately freed once the function returns.
 *
 * @param p_data A pointer to a UTF-8 encoded C string.
 * @param p_size The number of bytes (not code units).
 */
ExtensionsInterfaceEditorHelpLoadXmlFromUtf8CharsAndLen :: #type proc "c" (p_data: cstring, p_size: i64)

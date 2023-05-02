package gdinterface

when BUILD_CONFIG == "float_32" {
    float :: f32
} else when BUILD_CONFIG == "float_64" {
    float :: f64
} else when BUILD_CONFIG == "double_32" {
    float :: f32
} else when BUILD_CONFIG == "double_64" {
    float :: f64
}

call_builtin_constructor :: proc(constructor: PtrConstructor, base: TypePtr, args: ..TypePtr) {
    constructor(base, raw_data(args))
}

call_builtin_operator_ptr :: proc(op: PtrOperatorEvaluator, a, b: TypePtr, $T: typeid) -> T {
    ret: T
    op(a, b, cast(TypePtr)&ret)
    return ret
}

call_builtin_method_ptr_ret :: proc(method: PtrBuiltInMethod, base: TypePtr, $T: typeid, args: ..TypePtr) -> T {
    ret: T
    method(base, raw_data(args), cast(TypePtr)&ret, len(args))
    return ret
}

call_builtin_method_ptr_no_ret :: proc(method: PtrBuiltInMethod, base: TypePtr, args: ..TypePtr) {
    method(base, raw_data(args), cast(TypePtr)nil, len(args))
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

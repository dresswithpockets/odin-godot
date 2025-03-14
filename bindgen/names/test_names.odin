package names

import "core:testing"

@(test)
test_godot_to_const :: proc(t: ^testing.T) {
    Test_Pair :: struct {
        input:  Godot_Name,
        expect: Const_Name,
    }

    test_pairs := [?]Test_Pair {
        {input = "Generic6DOFJoint3D", expect = "GENERIC6DOF_JOINT3D"},
        {input = "Transform3D", expect = "TRANSFORM3D"},
        {input = "Vector3", expect = "VECTOR3"},
        {input = "AudioStreamMP3", expect = "AUDIO_STREAM_MP3"},
    }

    for pair in test_pairs {
        result := godot_to_const(pair.input)
        defer delete(cast(string)result)

        testing.expect_value(t, result, pair.expect)
    }
}

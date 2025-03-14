package names

import "core:testing"

Test_Pair :: struct($I: typeid, $E: typeid) {
    input: I,
    expect: E,
}

@(test)
test_godot_to_odin :: proc(t: ^testing.T) {
    test_pairs := [?]Test_Pair(Godot_Name, Odin_Name) {
        {input = "Generic6DOFJoint3D", expect = "Generic6dof_Joint3d"},
        {input = "Transform3D", expect = "Transform3d"},
        {input = "Vector3", expect = "Vector3"},
        {input = "AudioStreamMP3", expect = "Audio_Stream_Mp3"},
    }

    for pair in test_pairs {
        result := godot_to_odin(pair.input)
        defer delete(cast(string)result)

        testing.expect_value(t, result, pair.expect)
    }
}

@(test)
test_const_to_odin :: proc(t: ^testing.T) {
    test_pairs := [?]Test_Pair(Const_Name, Odin_Name) {
        {input = "GENERIC6DOF_JOINT3D", expect = "Generic6dof_Joint3d"},
        {input = "TRANSFORM3D", expect = "Transform3d"},
        {input = "VECTOR3", expect = "Vector3"},
        {input = "AUDIO_STREAM_MP3", expect = "Audio_Stream_Mp3"},
    }

    for pair in test_pairs {
        result := const_to_odin(pair.input)
        defer delete(cast(string)result)

        testing.expect_value(t, result, pair.expect)
    }
}

@(test)
test_snake_to_odin :: proc(t: ^testing.T) {
    test_pairs := [?]Test_Pair(Snake_Name, Odin_Name) {
        {input = "generic6dof_joint3d", expect = "Generic6dof_Joint3d"},
        {input = "transform3d", expect = "Transform3d"},
        {input = "vector3", expect = "Vector3"},
        {input = "audio_stream_mp3", expect = "Audio_Stream_Mp3"},
    }

    for pair in test_pairs {
        result := snake_to_odin(pair.input)
        defer delete(cast(string)result)

        testing.expect_value(t, result, pair.expect)
    }
}

@(test)
test_odin_to_snake :: proc(t: ^testing.T) {
    test_pairs := [?]Test_Pair(Odin_Name, Snake_Name) {
        {input = "Generic6dof_Joint3d", expect = "generic6dof_joint3d"},
        {input = "Transform3d", expect = "transform3d"},
        {input = "Vector3", expect = "vector3"},
        {input = "Audio_Stream_Mp3", expect = "audio_stream_mp3"},
    }

    for pair in test_pairs {
        result := odin_to_snake(pair.input)
        defer delete(cast(string)result)

        testing.expect_value(t, result, pair.expect)
    }
}

@(test)
test_godot_to_snake :: proc(t: ^testing.T) {
    test_pairs := [?]Test_Pair(Godot_Name, Snake_Name) {
        {input = "Generic6DOFJoint3D", expect = "generic6dof_joint3d"},
        {input = "Transform3D", expect = "transform3d"},
        {input = "Vector3", expect = "vector3"},
        {input = "AudioStreamMP3", expect = "audio_stream_mp3"},
    }

    for pair in test_pairs {
        result := godot_to_snake(pair.input)
        defer delete(cast(string)result)

        testing.expect_value(t, result, pair.expect)
    }
}

@(test)
test_godot_to_const :: proc(t: ^testing.T) {
    test_pairs := [?]Test_Pair(Godot_Name, Const_Name) {
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

@(test)
test_odin_to_const :: proc(t: ^testing.T) {
    test_pairs := [?]Test_Pair(Odin_Name, Const_Name) {
        {input = "Generic6dof_Joint3D", expect = "GENERIC6DOF_JOINT3D"},
        {input = "Transform3d", expect = "TRANSFORM3D"},
        {input = "Vector3", expect = "VECTOR3"},
        {input = "Audio_Stream_Mp3", expect = "AUDIO_STREAM_MP3"},
    }

    for pair in test_pairs {
        result := odin_to_const(pair.input)
        defer delete(cast(string)result)

        testing.expect_value(t, result, pair.expect)
    }
}
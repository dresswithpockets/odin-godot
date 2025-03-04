package game

import core "../../../core"
import gd "../../../gdextension"
import var "../../../variant"

PhysicsMotion :: struct {
    params:    core.PhysicsTestMotionParameters3d,
    result:    core.PhysicsTestMotionResult3d,
    last_hit:  bool,
    rid:       var.Rid,
    remainder: var.Vector3,
    travel:    var.Vector3,
    distance:  var.Vector3,
    normal:    var.Vector3,
}

new_physics_motion :: proc(rid: var.Rid, margin: gd.float) -> PhysicsMotion {
    mt := PhysicsMotion {
        params   = core.new_physics_test_motion_parameters3d(),
        result   = core.new_physics_test_motion_result3d(),
        last_hit = false,
        rid      = rid,
    }

    core.physics_test_motion_parameters3d_set_margin(mt.params, margin)
}

physics_motion_test :: proc(motion: ^PhysicsMotion, from: var.Transform3d, move: var.Vector3) -> bool {
    core.physics_test_motion_parameters3d_set_from(mt.params, from)
    core.physics_test_motion_parameters3d_set_motion(mt.params, move)
    motion.last_hit = core.physics_server3d_body_test_motion(
        core.singleton_physics_server3d(),
        motion.rid,
        motion.params,
        motion.result,
    )

    if motion.last_hit {
        motion.remainder = core.physics_test_motion_result3d_get_remainder(motion.result)
        motion.travel = core.physics_test_motion_result3d_get_travel(motion.result)
        motion.distance = var.vector3_length(motion.travel)
        motion.normal = core.physics_test_motion_result3d_get_collision_normal(motion.result, 0)
    }

    return motion.last_hit
}

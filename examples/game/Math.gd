class_name Math

const GodotToTb: float = 32.0
const TbToGodot := 1.0 / GodotToTb

static func exp_decay(a, b, decay: float, delta: float):
    return b + (a - b) * exp(-decay * delta)

static func exp_decay_f(a: float, b: float, decay: float, delta: float) -> float:
    return b + (a - b) * exp(-decay * delta)

static func exp_decay_v2(a: Vector2, b: Vector2, decay: float, delta: float) -> Vector2:
    return b + (a - b) * exp(-decay * delta)

static func exp_decay_v3(a: Vector3, b: Vector3, decay: float, delta: float) -> Vector3:
    return b + (a - b) * exp(-decay * delta)

extends Node

func _ready():
    var test = Test.new()

    var src = Vector2(7, 13)
    var value1 = Vector2(7, 13)
    var value2 = Vector2(1, 2)

    test.set_vector(src)
    assert(test.vector.x == src.x)
    assert(test.vector.y == src.y)
    assert(test.vector == src)
    assert(test.vector_eq(value1) == (src == value1))
    assert(test.vector_eq(value2) == (src == value2))
    assert(test.vector_neq(value1) == (src != value1))
    assert(test.vector_neq(value2) == (src != value2))
    var result := test.vector_add(value1)
    assert(result == (src + value1), "expected: %v, result: %v" % [(src + value1), result])
    assert(test.vector_add(value2) == (src + value2))
    assert(test.vector_sub(value1) == (src - value1))
    assert(test.vector_sub(value2) == (src - value2))

    test.free()

    get_tree().quit(0)

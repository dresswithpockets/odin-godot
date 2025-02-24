extends Node

var examples: Array[ExampleClass] = []

func _init():
    for i in range(100):
        examples.append(ExampleClass.new())

func _exit_tree():
    for e in examples:
        e.free()

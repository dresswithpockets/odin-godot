extends Node2D

var thing: ExampleClass

func _ready():
    thing = ExampleClass.new()
    print("speed: ", thing.get_speed())
    thing.set_speed(2.0)
    print("speed: ", thing.speed)
    thing.speed = 3.0
    print("speed: ", thing.speed)
    
    print("amplitude: ", thing.get_amplitude())
    thing.set_amplitude(2.0)
    print("amplitude: ", thing.amplitude)
    thing.amplitude = 3.0
    print("amplitude: ", thing.amplitude)
    
    thing.time_passed.connect(on_time_passed)

func on_time_passed(time_passed: float):
    print(time_passed)
    thing.queue_free()
    thing = null

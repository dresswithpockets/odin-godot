extends Node2D

@onready var thing: ExampleClass = $ExampleClass

func _ready():
    print("speed: ", thing.get_speed())
    thing.set_speed(2.0)
    print("speed: ", thing.get_speed())
    
    print("amplitude: ", thing.get_amplitude())
    thing.set_amplitude(2.0)
    print("amplitude: ", thing.get_amplitude())

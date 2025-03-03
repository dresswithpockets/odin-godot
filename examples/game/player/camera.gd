extends Camera3D

func _on_player_stepped_up(distance: float) -> void:
    position.y -= distance

func _on_player_stepped_down(distance: float) -> void:
    position.y += distance

func _process(delta: float) -> void:
    position.y = Math.exp_decay_f(position.y, 0, 20, delta)

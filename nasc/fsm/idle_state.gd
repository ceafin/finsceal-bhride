extends NascState
class_name NascIdleState

func _ready() -> void:
	await super._ready()

func enter() -> void:
	nasc.velocity = Vector2.ZERO
	nasc.animated_sprite_2d.pause()

func physics_update(_delta: float) -> void:
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector != Vector2.ZERO:
		finished.emit(self, "walking")

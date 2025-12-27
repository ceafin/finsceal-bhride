extends Node
class_name Game

signal pause_toggled( is_paused: bool )

@onready var world: Node2D = $World

func _input( event: InputEvent ) -> void:
	if event.is_action_type() and not event.is_echo():
		if event.is_action_pressed("start"):
			get_tree().paused = not get_tree().paused
			pause_toggled.emit( get_tree().paused )

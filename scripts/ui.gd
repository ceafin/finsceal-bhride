extends Control
class_name UI

const HEART_FULL = preload( "res://assets/heart_full.png" )
const HEART_PART = preload( "res://assets/heart_part.png" )
const HEART_EMPTY = preload( "res://assets/heart_empty.png" )


# Resolution: 400x224
const CLOSED_POSITION : Vector2 = Vector2( 0, -224 )
const OPENED_POSITION : Vector2 = Vector2( 0, 0 )

var _hearts : float = 3.0
var hearts : float :
	get:
		return _hearts
	set( value ):
		for i in heart_grid.get_child_count():
			if value > i * 2 + 1:
				heart_grid.get_child( i ).texture = HEART_FULL
			elif value > i * 2:
				heart_grid.get_child( i ).texture = HEART_PART
			else:
				heart_grid.get_child( i ).texture = HEART_EMPTY
		_hearts = value


@onready var heart_grid : GridContainer = $AdventureMenu/OverlapHUD/OverlapHBox/LifeMeter/HeartGrid

func _input( event: InputEvent ) -> void:
	if event.is_action_type() and not event.is_echo():
		if event.is_action_pressed("start"):
			if get_tree().paused:
				exit_pause_menu()
			elif !get_tree().paused:
				enter_pause_menu()
			get_viewport().set_input_as_handled()
	

# Escaped Inputs Printed
# func _unhandled_input(event: InputEvent) -> void:
# 	print( "Unhandled: ", event.as_text() )

func enter_pause_menu() -> void:
	print( "Pulling down the pause menu!" )
	get_tree().paused = not get_tree().paused
	var pull_down_tween = create_tween()
	pull_down_tween.tween_property( self, "global_position", OPENED_POSITION, 0.6 ).set_trans( Tween.TRANS_QUART ).set_ease( Tween.EASE_IN_OUT )

func exit_pause_menu() -> void:
	print( "Rolling up the pause menu!" )
	var roll_up_tween = create_tween()
	roll_up_tween.tween_property( self, "global_position", CLOSED_POSITION, 0.3 ).set_trans( Tween.TRANS_EXPO ).set_ease( Tween.EASE_OUT )
	await roll_up_tween.finished
	get_tree().paused = not get_tree().paused

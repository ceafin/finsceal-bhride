extends Control
class_name UI

const CLOSED_POSITION : Vector2 = Vector2( 0, -156 )
const OPENED_POSITION : Vector2 = Vector2( 0, 0 )

func _ready() -> void:
	get_tree().current_scene.connect( "pause_toggled", Callable( self, "_pause_toggled" ) )

func _pause_toggled( is_paused: bool ) -> void:
	if is_paused:
		enter_pause_menu()
	if !is_paused:
		exit_pause_menu()
	
func enter_pause_menu() -> void:
	print( "Pulling down the pause menu!" )
	var pull_down_tween = create_tween()
	pull_down_tween.tween_property( self, "global_position", OPENED_POSITION, 0.5 ).set_trans( Tween.TRANS_QUART ).set_ease( Tween.EASE_IN )

func exit_pause_menu() -> void:
	print( "Rolling up the pause menu!" )
	var roll_up_tween = create_tween()
	roll_up_tween.tween_property( self, "global_position", CLOSED_POSITION, 0.5 ).set_trans( Tween.TRANS_QUART ).set_ease( Tween.EASE_OUT )

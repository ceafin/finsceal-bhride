extends Control
class_name UIInventorySelector

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player : AnimationPlayer = $AnimationPlayer

const MOVE_DURATION : float = 0.1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Ensure it processes even when paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	# Create temporary visual if no sprite frames set
	if not animated_sprite.sprite_frames or animated_sprite.sprite_frames.get_frame_texture( "default", 0 ) == null:
		_create_debug_rect()


func _create_debug_rect() -> void:
	var rect = ColorRect.new()
	rect.name = "DebugRect"
	rect.color = Color( 1, 0.9, 0.3, 0.7 )
	rect.size = Vector2( 32, 32 )
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child( rect )
	move_child( rect, 0 )


func move_to( target_position: Vector2, target_size: Vector2 = Vector2( 32, 32 ) ) -> void:
	var tween = create_tween()
	tween.set_parallel( true )
	tween.tween_property( self, "global_position", target_position, MOVE_DURATION ).set_trans( Tween.TRANS_QUAD ).set_ease( Tween.EASE_OUT )
	tween.tween_property( self, "size", target_size, MOVE_DURATION ).set_trans( Tween.TRANS_QUAD ).set_ease( Tween.EASE_OUT )


func snap_to( target_position: Vector2, target_size: Vector2 = Vector2( 32, 32 ) ) -> void:
	global_position = target_position
	size = target_size


func set_sprite_frames( frames: SpriteFrames ) -> void:
	if animated_sprite:
		animated_sprite.sprite_frames = frames


func set_visible_cursor( is_it_visible: bool ) -> void:
	visible = is_it_visible
	if animation_player:
		if visible:
			animation_player.play("pulse")
		else:
			animation_player.stop()

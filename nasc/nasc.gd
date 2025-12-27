extends CharacterBody2D
class_name Nasc

@onready var animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area : Area2D = $InteractionArea

# Speeds that look pretty: 42.5, 85.0, 170.0
# speed = d * 2^.5 * physics_fps
var movement_speed : float = 60.0
var facing : Vector2 = Vector2.DOWN

func _process( _delta: float ) -> void:
	set_facing_direction()
	set_animation()
	pass

func set_animation() -> void:
	if facing.x > 0:
		animated_sprite_2d.flip_h = false
	if facing.x < 0:
		animated_sprite_2d.flip_h = true
	
	if velocity != Vector2.ZERO:
		match facing:
			Vector2.UP:
				animated_sprite_2d.play("walk_up")
			Vector2.DOWN:
				animated_sprite_2d.play("walk_down")
			_:
				animated_sprite_2d.play("walk_side")
	else:
		animated_sprite_2d.pause()

func set_facing_direction() -> void:
	var direction : Vector2 = Vector2(
		Input.get_axis( "move_left", "move_right" ),
		Input.get_axis( "move_up", "move_down" )
	)

	if is_equal_approx( direction.length_squared(), 1.0 ):
		facing = direction
	
	if interaction_area:
		interaction_area.position = facing * 8

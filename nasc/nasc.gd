extends CharacterBody2D
class_name Nasc

enum { SHIELD_0, SHIELD_1, SHIELD_2 }

var is_carrying : bool = false
var has_shield : int = SHIELD_0

@onready var animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area : Area2D = $InteractionArea
@onready var interaction_ray: RayCast2D = $InteractionRay

# Speeds that look pretty: 42.5, 85.0, 170.0
# speed = d * 2^.5 * physics_fps
var movement_speed : float = 60.0
var dirs : Dictionary = {
	Vector2.DOWN: "down",
	Vector2.UP: "up",
	Vector2.LEFT: "left",
	Vector2.RIGHT: "right"
}
var facing : String = dirs[ Vector2.DOWN ]

func _physics_process( _delta: float ) -> void:
	set_facing_direction()
	

func set_facing_direction() -> void:
	var input_dir : Vector2 = Vector2(
		Input.get_axis( "move_left", "move_right" ),
		Input.get_axis( "move_up", "move_down" )
	)
	if input_dir != Vector2.ZERO:
		if is_equal_approx( input_dir.length_squared(), 1.0 ):
			facing = dirs[ input_dir ]
		
			if interaction_ray:
				interaction_ray.target_position = input_dir * 12

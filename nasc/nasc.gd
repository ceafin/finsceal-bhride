extends CharacterBody2D
class_name Nasc

enum { SHIELD_0, SHIELD_1, SHIELD_2 }

var is_carrying : bool = false
var has_shield : int = SHIELD_0
var jump_momentum : Vector2 = Vector2.ZERO

# Set at the Game Node Scene Root
var equipment_manager : EquipmentManager:
	set( value ):
		equipment_manager = value
		if input_handler:
			input_handler.equipment_manager = equipment_manager

@onready var fsm : NascFSM = $FSM
@onready var input_handler : InputHandler = $InputHandler
@onready var animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_ray : RayCast2D = $InteractionRay

# Speeds that look pretty: 42.5, 85.0, 170.0
# speed = d * 2^.5 * physics_fps
var movement_speed : float = 60.0
var facing : String = "down"

func is_busy() -> bool:
	return fsm != null and fsm.current_state != null and fsm.current_state.blocks_actions()

func set_facing_direction() -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir == Vector2.ZERO:
		return
	var has_x := not is_zero_approx(input_dir.x)
	var has_y := not is_zero_approx(input_dir.y)
	# Diagonal input preserves current facing; only pure cardinal presses change it
	if has_x and not has_y:
		facing = "right" if input_dir.x > 0 else "left"
	elif has_y and not has_x:
		facing = "down" if input_dir.y > 0 else "up"
	if interaction_ray:
		match facing:
			"right": interaction_ray.target_position = Vector2(12, 0)
			"left":  interaction_ray.target_position = Vector2(-12, 0)
			"down":  interaction_ray.target_position = Vector2(0, 12)
			"up":    interaction_ray.target_position = Vector2(0, -12)

func get_walk_animation_name() -> String:
	if is_carrying:
		return "carry_" + facing
	match has_shield:
		SHIELD_1: return "walk_s1_" + facing
		SHIELD_2: return "walk_s2_" + facing
	return "walk_" + facing

func is_grounded() -> bool:
	return true

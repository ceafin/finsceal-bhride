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
	var cardinal : Vector2
	if abs(input_dir.x) >= abs(input_dir.y):
		facing = "right" if input_dir.x > 0 else "left"
		cardinal = Vector2(sign(input_dir.x), 0)
	else:
		facing = "down" if input_dir.y > 0 else "up"
		cardinal = Vector2(0, sign(input_dir.y))
	if interaction_ray:
		interaction_ray.target_position = cardinal * 12

func get_walk_animation_name() -> String:
	if is_carrying:
		return "carry_" + facing
	match has_shield:
		SHIELD_1: return "walk_s1_" + facing
		SHIELD_2: return "walk_s2_" + facing
	return "walk_" + facing

func is_grounded() -> bool:
	return true

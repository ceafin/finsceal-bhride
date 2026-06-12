extends CharacterBody2D
class_name Nasc

signal animation_finished

enum { SHIELD_0, SHIELD_1, SHIELD_2 }

var is_carrying : bool = false
var has_shield : int = SHIELD_0
var jump_momentum : Vector2 = Vector2.ZERO
var movement_speed : float = 60.0
var facing : String = "down"

var equipment_manager : EquipmentManager:
	set( value ):
		equipment_manager = value
		if _input_handler:
			_input_handler.equipment_manager = equipment_manager

@onready var fsm : NascFSM = $FSM
@onready var _input_handler : InputHandler = $InputHandler
@onready var _sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var _interaction_ray : RayCast2D = $InteractionRay

func _ready() -> void:
	_sprite.animation_finished.connect(animation_finished.emit)

# --- State queries ---

func is_busy() -> bool:
	return fsm != null and fsm.current_state != null and fsm.current_state.blocks_actions()

func is_grounded() -> bool:
	return true

# --- Facing ---

func update_facing(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	var has_x := not is_zero_approx(direction.x)
	var has_y := not is_zero_approx(direction.y)
	if has_x and not has_y:
		facing = "right" if direction.x > 0 else "left"
	elif has_y and not has_x:
		facing = "down" if direction.y > 0 else "up"
	match facing:
		"right": _interaction_ray.target_position = Vector2(12, 0)
		"left":  _interaction_ray.target_position = Vector2(-12, 0)
		"down":  _interaction_ray.target_position = Vector2(0, 12)
		"up":    _interaction_ray.target_position = Vector2(0, -12)

# --- Animation API ---

func play_animation(anim_name: String) -> void:
	_sprite.play(anim_name)

func pause_animation() -> void:
	_sprite.pause()

func is_animation_playing() -> bool:
	return _sprite.is_playing()

func get_current_animation() -> String:
	return _sprite.animation

func get_walk_animation_name() -> String:
	if is_carrying:
		return "carry_" + facing
	match has_shield:
		SHIELD_1: return "walk_s1_" + facing
		SHIELD_2: return "walk_s2_" + facing
	return "walk_" + facing

## Nasc — the player character. She's a [CharacterBody2D] so Godot handles the
## collision resolution for us via [method move_and_slide].
## This class is intentionally kept as a "dumb container" — she holds state and
## exposes a clean API, but doesn't make decisions. All that logic lives in the FSM
## and states. States only talk to this public API, never to her internal child nodes
## directly, which keeps the architecture clean and makes refactoring way easier.
extends CharacterBody2D
class_name Nasc


## Forwarded from the [AnimatedSprite2D] — emitted when the current animation
## clip finishes playing. States connect to this to know when a locked animation is done.
signal animation_finished


## Shield tier constants. SHIELD_0 = no shield, SHIELD_1/2 = progressively better shields.
## These affect which walk animation variant gets played via [method get_walk_animation_name].
enum { SHIELD_0, SHIELD_1, SHIELD_2 }


## Whether Nasc is currently carrying something (pot, boulder, etc.).
## When true, [method get_walk_animation_name] switches to the carry animation variants.
var is_carrying : bool = false

## Current shield level — affects which walk animation variant plays.
## Set to SHIELD_0 (no shield) by default.
var has_shield : int = SHIELD_0

## The velocity vector that gets carried into a jump. Written by [JumpCommand.execute]
## right before the FSM transitions into [NascJumpingState]. Cleared in jumping_state.exit().
var jump_momentum : Vector2 = Vector2.ZERO

## How fast Nasc moves in pixels per second. [MoveCommand.execute] multiplies the
## input direction by this — change it here to affect all movement globally.
var movement_speed : float = 60.0

## Which cardinal direction Nasc is currently facing as a string: "up", "down", "left", "right".
## Used to build animation names and set the interaction ray direction.
var facing : String = "down"

## The [EquipmentManager] that handles item slots and inventory.
## Uses a setter so assigning it automatically propagates the reference down to
## [InputHandler] — the FSM loop needs input_handler to have a valid equipment_manager
## before it can start dispatching item commands.
var equipment_manager : EquipmentManager:
	set( value ):
		equipment_manager = value                             # store the reference
		if _input_handler:
			_input_handler.equipment_manager = equipment_manager  # forward it straight to input handler so it can look up equipped items


## Reference to the FSM that drives all of Nasc's behavior.
## Public so external systems (e.g. cutscenes, UI) can check current state via is_busy().
@onready var fsm : NascFSM = $FSM

## The input translation layer — converts raw Input polls into Command objects each frame.
@onready var _input_handler : InputHandler = $InputHandler

## The sprite that plays all animations. Private — nothing outside Nasc should touch it directly.
@onready var _sprite : AnimatedSprite2D = $AnimatedSprite2D

## The raycast that detects interactable objects in front of Nasc.
## Its target_position gets updated in [method update_facing] to always point the right way.
@onready var _interaction_ray : RayCast2D = $InteractionRay


## Forward the sprite's animation_finished signal to Nasc's own signal so states
## can connect to nasc.animation_finished without knowing _sprite exists.
## This is the encapsulation — states talk to Nasc's API, not to her children.
func _ready() -> void:
	_sprite.animation_finished.connect(animation_finished.emit)  # forward sprite signal → nasc signal so states don't reach into _sprite directly


# ---- State queries ----

## Returns true if Nasc is currently in a state that blocks normal action input
## (slashing, jumping, digging). Use this to gate UI interactions or cutscene triggers.
## [return] true if the active FSM state returns blocks_actions() == true
func is_busy() -> bool:
	return fsm != null and fsm.current_state != null and fsm.current_state.blocks_actions()  # check all the way down the chain


## Returns true if Nasc is currently on the ground and can jump.
## Always true right now — hook here for when platformer sections get added.
## [return] whether Nasc is grounded
func is_grounded() -> bool:
	return true  # placeholder — will use floor detection when there are height changes


# ---- Facing ----

## Updates which cardinal direction Nasc is facing and repositions the interaction ray.
## Only updates on pure cardinal input — diagonal input (both axes non-zero) intentionally
## preserves the current facing so zigzag movement doesn't snap the look direction around.
## [param direction] the raw movement vector from input — may have both axes set on diagonals
func update_facing(direction: Vector2) -> void:
	if direction == Vector2.ZERO:   # zero direction means "idle" — don't change facing
		return
	var has_x : bool = not is_zero_approx(direction.x)   # is there horizontal component?
	var has_y : bool = not is_zero_approx(direction.y)   # is there vertical component?
	if has_x and not has_y:
		facing = "right" if direction.x > 0 else "left"  # pure horizontal — update facing left or right
	elif has_y and not has_x:
		facing = "down" if direction.y > 0 else "up"     # pure vertical — update facing up or down
	# if both axes are non-zero (diagonal), neither branch fires — facing is preserved intentionally
	match facing:
		"right": _interaction_ray.target_position = Vector2(12, 0)   # ray points right
		"left":  _interaction_ray.target_position = Vector2(-12, 0)  # ray points left
		"down":  _interaction_ray.target_position = Vector2(0, 12)   # ray points down
		"up":    _interaction_ray.target_position = Vector2(0, -12)  # ray points up


# ---- Animation API ----

## Plays the named animation clip on the sprite.
## States call this instead of touching _sprite directly — keeps the internals private.
## [param anim_name] the name of the animation as set up in the AnimatedSprite2D's SpriteFrames
func play_animation(anim_name: String) -> void:
	_sprite.play(anim_name)  # delegate to sprite — states never touch _sprite directly


## Pauses the current animation on its current frame — used in idle state to freeze
## on the standing frame without needing a separate idle animation.
func pause_animation() -> void:
	_sprite.pause()  # freeze on current frame — used by idle state for the standing pose


## Returns true if the sprite is currently actively playing (not paused, not done).
## States use this to know when a locked animation has finished.
## [return] whether the sprite animation is currently running
func is_animation_playing() -> bool:
	return _sprite.is_playing()  # forward the sprite's playing state


## Returns the name of whichever animation is currently playing on the sprite.
## Used by _sync_animation in walking state to check if the animation needs to change.
## [return] the current animation name string
func get_current_animation() -> String:
	return _sprite.animation  # the sprite's animation property holds the current clip name


## Builds the correct walk animation name based on current carry/shield state and facing.
## This is the single source of truth for walk animation naming — idle and walking states
## both call this so they never get out of sync with each other.
## [return] the animation name string, e.g. "walk_right", "carry_down", "walk_s1_left"
func get_walk_animation_name() -> String:
	if is_carrying:                            # carrying something overrides shield variants entirely
		return "carry_" + facing
	match has_shield:
		SHIELD_1: return "walk_s1_" + facing   # small shield variant
		SHIELD_2: return "walk_s2_" + facing   # large shield variant
	return "walk_" + facing                    # default — no shield, no carry

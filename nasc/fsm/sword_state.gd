extends NascState
class_name NascSwordState

const SPIN_THRESHOLD : float = 1.0

var hold_duration : float = 0.0
var _button_held : bool = true

func _ready() -> void:
	await super._ready()

func blocks_actions() -> bool:
	return true

func enter() -> void:
	hold_duration = 0.0
	_button_held = true
	nasc.velocity = Vector2.ZERO
	nasc.animated_sprite_2d.play("slash_" + nasc.facing)
	nasc.animated_sprite_2d.animation_finished.connect(_on_slash_finished)

func physics_update(delta: float) -> void:
	hold_duration += delta
	# When animation finishes and still holding past threshold — spin attack
	if _button_held and not nasc.animated_sprite_2d.is_playing() and hold_duration >= SPIN_THRESHOLD:
		_end_sword_action()  # Expand here: swap to spin animation, different hitbox, etc.

func handle_command(command: Command) -> void:
	if command is SwordCommand:
		_button_held = true
		return
	# Any non-sword command means the button was released
	_button_held = false
	if not nasc.animated_sprite_2d.is_playing():
		# Animation already finished while holding — resolve now
		if command is MoveCommand:
			command.execute(nasc)
		_end_sword_action()
	# If animation still playing, wait for _on_slash_finished

func _on_slash_finished() -> void:
	if not _button_held:
		_end_sword_action()
	# else: still holding — freeze on last frame until spin threshold or release

func _end_sword_action() -> void:
	if nasc.velocity.length_squared() > 0.1:
		finished.emit(self, "walking")
	else:
		finished.emit(self, "idle")

func exit() -> void:
	hold_duration = 0.0
	_button_held = false
	if nasc.animated_sprite_2d.animation_finished.is_connected(_on_slash_finished):
		nasc.animated_sprite_2d.animation_finished.disconnect(_on_slash_finished)

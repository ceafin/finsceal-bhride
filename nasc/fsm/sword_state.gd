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
	nasc.play_animation("slash_" + nasc.facing)
	nasc.animation_finished.connect(_on_slash_finished)

func physics_update(delta: float) -> void:
	hold_duration += delta
	if _button_held and not nasc.is_animation_playing() and hold_duration >= SPIN_THRESHOLD:
		_end_sword_action()

func handle_command(command: Command) -> void:
	if command is SwordCommand:
		_button_held = true
		return
	_button_held = false
	if not nasc.is_animation_playing():
		if command is MoveCommand:
			command.execute(nasc)
		_end_sword_action()

func _on_slash_finished() -> void:
	if not _button_held:
		_end_sword_action()

func _end_sword_action() -> void:
	if nasc.velocity.length_squared() > 0.1:
		finished.emit(self, "walking")
	else:
		finished.emit(self, "idle")

func exit() -> void:
	hold_duration = 0.0
	_button_held = false
	if nasc.animation_finished.is_connected(_on_slash_finished):
		nasc.animation_finished.disconnect(_on_slash_finished)

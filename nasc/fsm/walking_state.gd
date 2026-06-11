extends NascState
class_name NascWalkingState

func _ready() -> void:
	await super._ready()

func enter() -> void:
	nasc.set_facing_direction()
	_sync_animation()

func physics_update(_delta: float) -> void:
	nasc.set_facing_direction()
	_sync_animation()

func handle_command( command: Command ) -> void:
	if not command.can_execute( nasc ):
		return
	command.execute( nasc )

	if command is IdleCommand:
		finished.emit( self, "idle" )
	elif command is JumpCommand:
		finished.emit( self, "jumping" )
	elif command is DigCommand:
		finished.emit( self, "digging" )
	elif command is SwordCommand:
		finished.emit( self, "sword" )

func _sync_animation() -> void:
	var anim := nasc.get_walk_animation_name()
	if nasc.animated_sprite_2d.animation != anim:
		nasc.animated_sprite_2d.play(anim)

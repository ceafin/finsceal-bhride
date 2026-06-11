extends NascState
class_name NascWalkingState

func _ready() -> void:
	await super._ready()

func enter() -> void:
	_sync_animation()

func physics_update(_delta: float) -> void:
	_sync_animation()

func handle_command( command: Command ) -> void:
	super.handle_command( command )

	if command is IdleCommand:
		finished.emit( self, "idle" )
	elif command is JumpCommand:
		finished.emit( self, "jumping" )
	elif command is DigCommand:
		finished.emit( self, "digging" )

func _sync_animation() -> void:
	var anim : String
	if nasc.is_carrying:
		anim = "carry_" + nasc.facing
	elif nasc.has_shield == Nasc.SHIELD_1:
		anim = "walk_s1_" + nasc.facing
	elif nasc.has_shield == Nasc.SHIELD_2:
		anim = "walk_s2_" + nasc.facing
	else:
		anim = "walk_" + nasc.facing

	if nasc.animated_sprite_2d.animation != anim:
		nasc.animated_sprite_2d.play( anim )

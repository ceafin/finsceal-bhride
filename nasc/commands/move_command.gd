## Command for moving Nasc around. Carries the raw directional vector from input
## so the FSM and states can both read it — facing updates happen in the state when
## it sees a MoveCommand, and the actual velocity write happens in execute().
extends Command
class_name MoveCommand


## The direction (and implicitly the magnitude) of the requested movement.
## This is the raw [method Input.get_vector] result so diagonals will have values
## on both axes simultaneously — states handle the cardinal-only facing logic themselves.
var direction: Vector2


## Locks in the direction at construction time.
## [param dir] the movement vector straight from Input.get_vector
func _init( dir: Vector2 ) -> void:
	direction = dir  # bake in the input vector so the state can inspect it


## Actually moves Nasc by writing velocity = direction * movement_speed.
## movement_speed lives on Nasc so it can be tweaked without touching this command.
## [param nasc] the player character to apply velocity to
func execute( nasc: Nasc ) -> void:
	nasc.velocity = direction * nasc.movement_speed  # speed is Nasc's property so we don't hardcode it here

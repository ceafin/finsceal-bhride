## Command that just... stops Nasc. Zero velocity, nothing happening.
## This gets returned by [InputHandler] whenever no directional or action input
## is detected — so the FSM always has something to chew on even when the player
## isn't pressing anything. States use [code]if command is IdleCommand[/code] to
## decide it's time to go back to the idle state.
extends Command
class_name IdleCommand


## Zeros out Nasc's velocity so she actually stops moving.
## [param nasc] the player character to stop
func execute(nasc: Nasc) -> void:
	nasc.velocity = Vector2.ZERO  # no drift, no momentum — full stop

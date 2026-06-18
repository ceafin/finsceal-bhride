## Marker command for the digging / shovel action.
## There's no payload here and no custom execute — the whole point is just to give
## the FSM something typed to match against ([code]if command is DigCommand[/code])
## so it knows to transition into [NascDiggingState]. The actual digging animation
## and behavior all live over there in the state itself.
extends Command
class_name DigCommand

## Marker command for the sword action — same deal as [DigCommand].
## No payload, no custom execute. The FSM just needs something typed to match on
## ([code]if command is SwordCommand[/code]) so it can kick off the transition
## into [NascSwordState]. All the actual slash / spin / duration logic lives there.
## It's also continuous ([member SwordItem.is_continuous] is true) so [InputHandler]
## will keep generating these every frame the button is held, which is exactly how
## [NascSwordState] detects whether the player is still holding the button.
extends Command
class_name SwordCommand

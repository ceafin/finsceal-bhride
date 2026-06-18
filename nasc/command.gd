## Abstract base class for every command in the game — this is the Command Pattern
## from Robert Nystrom's Game Programming Patterns, chapter 2.
## The idea is that instead of having input code directly poke at Nasc's internals,
## all player intentions get wrapped up in little command objects that know how to
## execute themselves against a Nasc. That way input handling, AI, replays, and
## whatever else can all speak the same language without caring where the command came from.
## Subclass this and override [method execute] (and optionally [method can_execute]).
extends RefCounted
class_name Command


## The thing that actually DOES the command. Override this in every subclass.
## Default does nothing, which is fine for marker commands like [SwordCommand].
## [param _nasc] the player character this command acts on
func execute(_nasc: Nasc) -> void:
	pass  # base does nothing — real logic lives in subclasses


## Lets the command check whether it's even allowed to run right now.
## Return [code]false[/code] here to silently block execution — e.g. JumpCommand
## uses this to prevent jumping while airborne.
## Default is always true so most commands don't have to think about it.
## [param _nasc] the player character we're checking prerequisites against
## [return] whether it's cool to run this command right now
func can_execute(_nasc: Nasc) -> bool:
	return true  # most commands are unconditional — override when you need a gate

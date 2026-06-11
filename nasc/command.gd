extends RefCounted
class_name Command

var is_discrete: bool = false  # true for one-time actions, false for continuous

func execute(_nasc: Nasc) -> void:
	pass

func can_execute(_nasc: Nasc) -> bool:
	return true

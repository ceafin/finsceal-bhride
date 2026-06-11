extends Command
class_name DigCommand

func _init() -> void:
	is_discrete = true

func execute(nasc: Nasc) -> void:
	nasc.is_performing_discrete_action = true

func can_execute(nasc: Nasc) -> bool:
	return not nasc.is_performing_discrete_action

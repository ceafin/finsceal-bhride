extends Command
class_name SwordCommand

var hold_duration : float = 0.0

func _init() -> void:
	is_discrete = false  # Hold to charge up "continuous"

func execute( nasc: Nasc ) -> void:
	# Track how long sword button is held
	hold_duration += nasc.get_physics_process_delta_time()
	
	if hold_duration >= 1.0:
		nasc.is_performing_discrete_action = true  # Do spin attack, which is now discrete
		# Spin attack logic here
	else:
		# Normal sword slash
		pass

func can_execute( nasc: Nasc ) -> bool:
	return not nasc.is_performing_discrete_action

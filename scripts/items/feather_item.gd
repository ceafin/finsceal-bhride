extends Item
class_name FeatherItem

func _init() -> void:
	item_name = "Roc's Feather"
	item_type = ItemType.TOOL
	is_continuous = false

func create_command( nasc: Nasc ) -> Command:
	return JumpCommand.new( nasc.velocity )

func can_use( nasc: Nasc ) -> bool:
	return nasc.is_grounded()

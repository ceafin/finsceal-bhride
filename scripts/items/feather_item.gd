extends Item
class_name FeatherItem

func _init() -> void:
	item_name = "Roc's Feather"
	item_type = ItemType.TOOL
	is_continuous = false

func create_command( nasc: Nasc ) -> Command:
	return JumpCommand.new( nasc.velocity )

func can_use( nasc: Nasc ) -> bool:
	print( "Checking if Feather can be used...")
	return super.can_use( nasc ) and nasc.is_grounded()  # Check discrete action status AND if grounded

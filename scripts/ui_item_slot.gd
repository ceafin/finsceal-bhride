extends TextureRect
class_name UIItemSlot

var item : Item:
	set(value):
		item = value
		texture = value.icon if value else null

func _ready() -> void:
	custom_minimum_size = Vector2(32, 32)
	expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture = item.icon if item else null

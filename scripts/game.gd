extends Node
class_name Game

@onready var equipment_manager: EquipmentManager = $EquipmentManager
@onready var player: Nasc = $World/Player
@onready var ui: UI = $CanvasLayer/UI

func _ready() -> void:
	# Wait for all children to be ready
	await get_tree().process_frame

	# Connect the equipment manager to both player and UI
	if player and equipment_manager:
		player.equipment_manager = equipment_manager
		print("Connected equipment_manager to player")

	if ui and equipment_manager:
		ui.equipment_manager = equipment_manager
		print("Connected equipment_manager to UI")

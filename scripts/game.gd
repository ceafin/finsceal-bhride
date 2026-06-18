## Root game scene coordinator. The whole job of this node is to wire up the three
## top-level systems — [EquipmentManager], [Nasc] (the player), and [UI] — by handing
## each of them a reference to the equipment manager so they can all talk through it.
## None of these systems know about each other directly — they only know about EquipmentManager,
## and EquipmentManager talks back via signals. This keeps coupling minimal.
extends Node
class_name Game


## The equipment manager — the source of truth for what's equipped and what's in inventory.
@onready var equipment_manager : EquipmentManager = $EquipmentManager

## The player character. Needs an equipment_manager reference so her InputHandler
## can look up what item is in each slot each frame.
@onready var player : Nasc = $World/Player

## The UI / pause menu system. Needs an equipment_manager reference so it can
## display slot contents and listen for slot_changed / inventory_changed signals.
@onready var ui : UI = $CanvasLayer/UI


## Wire everything up after all children are ready.
## We wait one process frame because @onready vars on children might not have
## finished their own _ready calls when Game._ready fires.
func _ready() -> void:
	# Wait one full process frame so all @onready children have finished their own _ready()
	await get_tree().process_frame

	# Give Nasc her equipment manager — this also propagates it to InputHandler via Nasc's setter
	if player and equipment_manager:
		player.equipment_manager = equipment_manager

	# Give UI her equipment manager — this triggers signal connections and refreshes all displays
	if ui and equipment_manager:
		ui.equipment_manager = equipment_manager

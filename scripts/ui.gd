extends Control
class_name UI

const HEART_FULL  : Texture2D   = preload("res://assets/heart_full.png")
const HEART_PART  : Texture2D   = preload("res://assets/heart_part.png")
const HEART_EMPTY : Texture2D   = preload("res://assets/heart_empty.png")

const LA_PAUSE_MENU_OPEN  : AudioStream = preload("res://assets/sfx/LA_PauseMenu_Open.wav")
const LA_PAUSE_MENU_CLOSE : AudioStream = preload("res://assets/sfx/LA_PauseMenu_Close.wav")

const CLOSED_POSITION : Vector2 = Vector2(0, -224)
const OPENED_POSITION : Vector2 = Vector2(0, 0)
const GRID_COLS       : int     = 7

var _hearts : float = 3.0
var hearts : float:
	get:
		return _hearts
	set(value):
		_hearts = value
		if not is_node_ready():
			return
		for i: int in heart_grid.get_child_count():
			if value > i * 2 + 1:
				heart_grid.get_child(i).texture = HEART_FULL
			elif value > i * 2:
				heart_grid.get_child(i).texture = HEART_PART
			else:
				heart_grid.get_child(i).texture = HEART_EMPTY

var equipment_manager : EquipmentManager:
	set(value):
		equipment_manager = value
		if equipment_manager:
			equipment_manager.slot_changed.connect(_on_slot_changed)
			equipment_manager.inventory_changed.connect(_on_inventory_changed)
			_refresh_equipment_display()
			_refresh_inventory_grid()

var _cursor_index : int = 0

@onready var slot_west_display  : TextureRect = $AdventureMenu/OverlapHUD/OverlapHBox/HUDButtonAssignments/HUDButtonX/HUDItemX/TextureRect
@onready var slot_north_display : TextureRect = $AdventureMenu/OverlapHUD/OverlapHBox/HUDButtonAssignments/HUDButtonY/HUDItemY/TextureRect
@onready var slot_east_display  : TextureRect = $AdventureMenu/OverlapHUD/OverlapHBox/HUDButtonAssignments/HUDButtonA/HUDItemA/TextureRect
@onready var slot_south_display : TextureRect = $AdventureMenu/OverlapHUD/OverlapHBox/HUDButtonAssignments/HUDButtonB/HUDItemB/TextureRect

@onready var _inv_slot_west_display  : TextureRect = $AdventureMenu/InventoryMenu/MarginContainer/InvHBox/Abilities/VBoxContainer/InvBtnAsgmts/InvBtnX/InvItemX/TextureRect
@onready var _inv_slot_north_display : TextureRect = $AdventureMenu/InventoryMenu/MarginContainer/InvHBox/Abilities/VBoxContainer/InvBtnAsgmts/InvBtnY/InvItemY/TextureRect
@onready var _inv_slot_east_display  : TextureRect = $AdventureMenu/InventoryMenu/MarginContainer/InvHBox/Abilities/VBoxContainer/InvBtnAsgmts/InvBtnA/InvItemA/TextureRect
@onready var _inv_slot_south_display : TextureRect = $AdventureMenu/InventoryMenu/MarginContainer/InvHBox/Abilities/VBoxContainer/InvBtnAsgmts/InvBtnB/InvItemB/TextureRect

@onready var heart_grid          : GridContainer       = $AdventureMenu/OverlapHUD/OverlapHBox/LifeMeter/HeartGrid
@onready var _inventory_grid     : GridContainer       = $AdventureMenu/InventoryMenu/MarginContainer/InvHBox/Equipables/GridContainer
@onready var _inventory_selector : UIInventorySelector = $AdventureMenu/InventoryMenu/UIInventorySelector

func _ready() -> void:
	_inventory_selector.set_visible_cursor(false)
	_refresh_equipment_display()

func _on_slot_changed(_slot_name: String, _item: Item) -> void:
	_refresh_equipment_display()

func _on_inventory_changed(index: int, item: Item) -> void:
	var slot: UIItemSlot = _inventory_grid.get_child(index) as UIItemSlot
	if slot:
		slot.item = item

func _refresh_equipment_display() -> void:
	if not equipment_manager:
		return
	var north : Item = equipment_manager.get_equipped_item("slot_north")
	var east  : Item = equipment_manager.get_equipped_item("slot_east")
	var south : Item = equipment_manager.get_equipped_item("slot_south")
	var west  : Item = equipment_manager.get_equipped_item("slot_west")
	slot_north_display.texture = north.icon if north else null
	slot_east_display.texture  = east.icon  if east  else null
	slot_south_display.texture = south.icon if south else null
	slot_west_display.texture  = west.icon  if west  else null
	_inv_slot_north_display.texture = north.icon if north else null
	_inv_slot_east_display.texture  = east.icon  if east  else null
	_inv_slot_south_display.texture = south.icon if south else null
	_inv_slot_west_display.texture  = west.icon  if west  else null

func _refresh_inventory_grid() -> void:
	if not equipment_manager:
		return
	for child: Node in _inventory_grid.get_children():
		child.free()
	for i: int in EquipmentManager.INVENTORY_SIZE:
		var slot : UIItemSlot = UIItemSlot.new()
		slot.item = equipment_manager.inventory[i]
		_inventory_grid.add_child(slot)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("start"):
		if get_tree().paused:
			exit_pause_menu()
		else:
			enter_pause_menu()
		get_viewport().set_input_as_handled()
		return

	if not get_tree().paused:
		return

	if event.is_action_pressed("move_right"):
		_move_cursor(1, 0)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_left"):
		_move_cursor(-1, 0)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_down"):
		_move_cursor(0, 1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_up"):
		_move_cursor(0, -1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("slot_north"):
		_assign_slot("slot_north")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("slot_east"):
		_assign_slot("slot_east")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("slot_south"):
		_assign_slot("slot_south")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("slot_west"):
		_assign_slot("slot_west")
		get_viewport().set_input_as_handled()

func enter_pause_menu() -> void:
	get_tree().paused = true
	_inventory_selector.set_visible_cursor(false)
	SFX.play(LA_PAUSE_MENU_OPEN)
	var tween : Tween = create_tween()
	tween.tween_property(self, "global_position", OPENED_POSITION, 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	_update_cursor_position()
	_inventory_selector.set_visible_cursor(true)

func exit_pause_menu() -> void:
	_inventory_selector.set_visible_cursor(false)
	SFX.play(LA_PAUSE_MENU_CLOSE)
	var tween : Tween = create_tween()
	tween.tween_property(self, "global_position", CLOSED_POSITION, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await tween.finished
	get_tree().paused = false

func _move_cursor(delta_col: int, delta_row: int) -> void:
	var col     : int = _cursor_index % GRID_COLS
	var row     : int = _cursor_index / GRID_COLS
	var max_row : int = (EquipmentManager.INVENTORY_SIZE - 1) / GRID_COLS
	var new_col : int = clampi(col + delta_col, 0, GRID_COLS - 1)
	var new_row : int = clampi(row + delta_row, 0, max_row)
	var new_index : int = new_row * GRID_COLS + new_col
	if new_index == _cursor_index:
		return
	_cursor_index = new_index
	var cell : UIItemSlot = _inventory_grid.get_child(_cursor_index) as UIItemSlot
	if cell:
		_inventory_selector.move_to(cell.global_position, cell.size)

func _update_cursor_position() -> void:
	var cell : UIItemSlot = _inventory_grid.get_child(_cursor_index) as UIItemSlot
	if cell:
		_inventory_selector.snap_to(cell.global_position, cell.size)

func _assign_slot(slot_name: String) -> void:
	if not equipment_manager:
		return
	equipment_manager.swap_inventory_with_slot(_cursor_index, slot_name)

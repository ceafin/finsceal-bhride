extends Control
class_name UI

const HEART_FULL = preload( "res://assets/heart_full.png" )
const HEART_PART = preload( "res://assets/heart_part.png" )
const HEART_EMPTY = preload( "res://assets/heart_empty.png" )

const LA_PAUSE_MENU_OPEN = preload( "res://assets/sfx/LA_PauseMenu_Open.wav" )
const LA_PAUSE_MENU_CLOSE = preload( "res://assets/sfx/LA_PauseMenu_Close.wav" )

# Resolution: 400x224
const CLOSED_POSITION : Vector2 = Vector2( 0, -224 )
const OPENED_POSITION : Vector2 = Vector2( 0, 0 )

var _hearts : float = 3.0
var hearts : float :
	get:
		return _hearts
	set( value ):
		_hearts = value
		if not is_node_ready():
			return
		for i in heart_grid.get_child_count():
			if value > i * 2 + 1:
				heart_grid.get_child( i ).texture = HEART_FULL
			elif value > i * 2:
				heart_grid.get_child( i ).texture = HEART_PART
			else:
				heart_grid.get_child( i ).texture = HEART_EMPTY

# Set at the Game Node Scene Root
var equipment_manager : EquipmentManager:
	set( value ):
		equipment_manager = value
		if equipment_manager:
			equipment_manager.slot_changed.connect( _on_slot_changed )
			_refresh_equipment_display()

@onready var slot_west_display  : TextureRect = $AdventureMenu/OverlapHUD/OverlapHBox/HUDButtonAssignments/HUDButtonX/HUDItemX/TextureRect
@onready var slot_north_display : TextureRect = $AdventureMenu/OverlapHUD/OverlapHBox/HUDButtonAssignments/HUDButtonY/HUDItemY/TextureRect
@onready var slot_east_display  : TextureRect = $AdventureMenu/OverlapHUD/OverlapHBox/HUDButtonAssignments/HUDButtonA/HUDItemA/TextureRect
@onready var slot_south_display : TextureRect = $AdventureMenu/OverlapHUD/OverlapHBox/HUDButtonAssignments/HUDButtonB/HUDItemB/TextureRect

@onready var heart_grid : GridContainer = $AdventureMenu/OverlapHUD/OverlapHBox/LifeMeter/HeartGrid

func _ready() -> void:
	_refresh_equipment_display()

func _on_slot_changed( _slot_name: String, _item: Item ) -> void:
	_refresh_equipment_display()

func _refresh_equipment_display() -> void:
	if not equipment_manager:
		return

	var north = equipment_manager.get_equipped_item( "slot_north" )
	var east  = equipment_manager.get_equipped_item( "slot_east" )
	var south = equipment_manager.get_equipped_item( "slot_south" )
	var west  = equipment_manager.get_equipped_item( "slot_west" )

	slot_north_display.texture = north.icon if north else null
	slot_east_display.texture  = east.icon  if east  else null
	slot_south_display.texture = south.icon if south else null
	slot_west_display.texture  = west.icon  if west  else null


func _input( event: InputEvent ) -> void:
	if event.is_action_pressed( "start" ):
		if get_tree().paused:
			exit_pause_menu()
		else:
			enter_pause_menu()
		get_viewport().set_input_as_handled()


func enter_pause_menu() -> void:
	get_tree().paused = true
	SFX.play( LA_PAUSE_MENU_OPEN )
	var tween = create_tween()
	tween.tween_property( self, "global_position", OPENED_POSITION, 0.5 ).set_trans( Tween.TRANS_QUART ).set_ease( Tween.EASE_IN_OUT )

func exit_pause_menu() -> void:
	SFX.play( LA_PAUSE_MENU_CLOSE )
	var tween = create_tween()
	tween.tween_property( self, "global_position", CLOSED_POSITION, 0.2 ).set_trans( Tween.TRANS_EXPO ).set_ease( Tween.EASE_OUT )
	await tween.finished
	get_tree().paused = false

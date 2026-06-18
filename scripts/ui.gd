## The whole UI system — HUD, pause menu, inventory grid, cursor, all of it.
## This node stays at CLOSED_POSITION (off the top of the screen) during gameplay
## and slides down to OPENED_POSITION when the player hits start.
## The pause menu works by literally pausing the scene tree (get_tree().paused = true)
## and this node has process_mode = ALWAYS in the scene so it keeps running and can
## handle input while everything else is frozen.
## All displays update from [method _refresh_equipment_display] which fires whenever
## [EquipmentManager] signals a slot change — the HUD strip and the pause menu panel
## both get updated in the same call so they're always in sync.
extends Control
class_name UI


## Heart textures for the life meter — full, half, and empty.
const HEART_FULL  : Texture2D = preload("res://assets/heart_full.png")
const HEART_PART  : Texture2D = preload("res://assets/heart_part.png")
const HEART_EMPTY : Texture2D = preload("res://assets/heart_empty.png")

## The LA-style whoosh sounds for opening and closing the pause menu.
const LA_PAUSE_MENU_OPEN  : AudioStream = preload("res://assets/sfx/LA_PauseMenu_Open.wav")
const LA_PAUSE_MENU_CLOSE : AudioStream = preload("res://assets/sfx/LA_PauseMenu_Close.wav")

## Where the UI lives off-screen during gameplay — one full viewport height above screen.
const CLOSED_POSITION : Vector2 = Vector2(0, -224)
## Where the UI sits when the pause menu is fully open — flush with the top of the screen.
const OPENED_POSITION : Vector2 = Vector2(0, 0)
## How many columns the inventory grid has — must match the GridContainer's columns property in the scene.
const GRID_COLS       : int     = 7


## Backing field for the hearts property — stores the raw float heart count.
var _hearts : float = 3.0

## Public heart count. Setting this automatically updates every heart icon in the grid.
## Fractional values (e.g. 2.5) render a half-heart on the third container.
var hearts : float:
	get:
		return _hearts   # just return the backing field
	set(value):
		_hearts = value                               # store the new value
		if not is_node_ready():                       # guard — heart_grid doesn't exist yet if this fires before _ready
			return
		for i: int in heart_grid.get_child_count():  # walk every heart icon in the grid
			if value > i * 2 + 1:
				heart_grid.get_child(i).texture = HEART_FULL   # this heart's two halves are both filled
			elif value > i * 2:
				heart_grid.get_child(i).texture = HEART_PART   # first half filled, second empty
			else:
				heart_grid.get_child(i).texture = HEART_EMPTY  # completely empty


## The equipment manager that owns all slot and inventory data.
## Setter wires up signals and kicks off initial display refreshes so everything
## is in sync from the moment it's assigned.
var equipment_manager : EquipmentManager:
	set(value):
		equipment_manager = value                                              # store the reference
		if equipment_manager:
			equipment_manager.slot_changed.connect(_on_slot_changed)          # listen for slot changes so HUD and panel both update
			equipment_manager.inventory_changed.connect(_on_inventory_changed) # listen for grid changes so individual cells update
			_refresh_equipment_display()                                       # immediately sync all slot displays with current data
			_refresh_inventory_grid()                                          # immediately build the inventory grid from current data


## Which grid cell index the cursor is currently over. Persists between pause menu opens
## so the player comes back to wherever they left off — same as Zelda: LA.
var _cursor_index : int = 0


# ---- HUD slot display refs (always-visible overlay strip at the bottom) ----

## The icon display for whatever's in the west (X button) slot in the HUD overlay.
@onready var slot_west_display  : TextureRect = $AdventureMenu/OverlapHUD/OverlapHBox/HUDButtonAssignments/HUDButtonX/HUDItemX/TextureRect
## The icon display for whatever's in the north (Y button) slot in the HUD overlay.
@onready var slot_north_display : TextureRect = $AdventureMenu/OverlapHUD/OverlapHBox/HUDButtonAssignments/HUDButtonY/HUDItemY/TextureRect
## The icon display for whatever's in the east (A button) slot in the HUD overlay.
@onready var slot_east_display  : TextureRect = $AdventureMenu/OverlapHUD/OverlapHBox/HUDButtonAssignments/HUDButtonA/HUDItemA/TextureRect
## The icon display for whatever's in the south (B button) slot in the HUD overlay.
@onready var slot_south_display : TextureRect = $AdventureMenu/OverlapHUD/OverlapHBox/HUDButtonAssignments/HUDButtonB/HUDItemB/TextureRect

# ---- Pause menu slot display refs (InvBtnAsgmts panel on the right of the inventory grid) ----

## The icon display for the west slot inside the pause menu's InvBtnAsgmts panel.
@onready var _inv_slot_west_display  : TextureRect = $AdventureMenu/InventoryMenu/MarginContainer/InvHBox/Abilities/VBoxContainer/InvBtnAsgmts/InvBtnX/InvItemX/TextureRect
## The icon display for the north slot inside the pause menu's InvBtnAsgmts panel.
@onready var _inv_slot_north_display : TextureRect = $AdventureMenu/InventoryMenu/MarginContainer/InvHBox/Abilities/VBoxContainer/InvBtnAsgmts/InvBtnY/InvItemY/TextureRect
## The icon display for the east slot inside the pause menu's InvBtnAsgmts panel.
@onready var _inv_slot_east_display  : TextureRect = $AdventureMenu/InventoryMenu/MarginContainer/InvHBox/Abilities/VBoxContainer/InvBtnAsgmts/InvBtnA/InvItemA/TextureRect
## The icon display for the south slot inside the pause menu's InvBtnAsgmts panel.
@onready var _inv_slot_south_display : TextureRect = $AdventureMenu/InventoryMenu/MarginContainer/InvHBox/Abilities/VBoxContainer/InvBtnAsgmts/InvBtnB/InvItemB/TextureRect

## The GridContainer that holds all 35 inventory cells.
@onready var heart_grid          : GridContainer       = $AdventureMenu/OverlapHUD/OverlapHBox/LifeMeter/HeartGrid
## The GridContainer that holds all 35 inventory cells (UIItemSlot instances built at runtime).
@onready var _inventory_grid     : GridContainer       = $AdventureMenu/InventoryMenu/MarginContainer/InvHBox/Equipables/GridContainer
## The cursor that slides around the inventory grid — child of InventoryMenu (NinePatchRect),
## NOT of any Container node, so global_position isn't overridden by layout passes.
@onready var _inventory_selector : UIInventorySelector = $AdventureMenu/InventoryMenu/UIInventorySelector


## Hide the cursor on startup — it only appears after the pause menu opens.
## Also do an initial equipment display refresh in case something was set before ready.
func _ready() -> void:
	_inventory_selector.set_visible_cursor(false)   # cursor starts hidden — shown in enter_pause_menu after the slide animation
	_refresh_equipment_display()                    # sync any display that was set before the node was ready


## Fired by EquipmentManager when any slot changes. Just triggers a full display refresh
## since it's cheap and simpler than trying to update only the changed slot.
## [param _slot_name] which slot changed — unused, we refresh everything
## [param _item] the new item — unused, we re-query everything
func _on_slot_changed(_slot_name: String, _item: Item) -> void:
	_refresh_equipment_display()  # refresh all four slot displays at once — simple and always correct


## Fired by EquipmentManager when a single inventory grid cell changes.
## Does a surgical single-cell update instead of rebuilding the whole grid.
## [param index] which grid cell changed (0–34)
## [param item] the item now at that cell, or null if it's empty
func _on_inventory_changed(index: int, item: Item) -> void:
	var slot : UIItemSlot = _inventory_grid.get_child(index) as UIItemSlot  # grab the specific UIItemSlot at this index
	if slot:
		slot.item = item  # update just this one cell — the setter handles the texture update


## Refreshes all eight slot icon displays — four in the HUD overlay and four in the
## pause menu's InvBtnAsgmts panel — from the current EquipmentManager data.
## Both display groups always update together so they can't get out of sync.
func _refresh_equipment_display() -> void:
	if not equipment_manager:   # nothing to read from yet — bail silently
		return
	var north : Item = equipment_manager.get_equipped_item("slot_north")   # what's in the north/Y slot right now
	var east  : Item = equipment_manager.get_equipped_item("slot_east")    # east/A slot
	var south : Item = equipment_manager.get_equipped_item("slot_south")   # south/B slot
	var west  : Item = equipment_manager.get_equipped_item("slot_west")    # west/X slot
	# Update HUD overlay strip (always visible during gameplay)
	slot_north_display.texture = north.icon if north else null   # icon or null clears the display
	slot_east_display.texture  = east.icon  if east  else null
	slot_south_display.texture = south.icon if south else null
	slot_west_display.texture  = west.icon  if west  else null
	# Update pause menu InvBtnAsgmts panel (visible when the menu is open)
	_inv_slot_north_display.texture = north.icon if north else null  # mirror the HUD values in the pause menu panel
	_inv_slot_east_display.texture  = east.icon  if east  else null
	_inv_slot_south_display.texture = south.icon if south else null
	_inv_slot_west_display.texture  = west.icon  if west  else null


## Tears down the existing inventory grid children and rebuilds them fresh from
## the current EquipmentManager inventory array.
## Called once when the equipment manager is first assigned, and any time a full
## rebuild is needed. Surgical updates go through [method _on_inventory_changed].
func _refresh_inventory_grid() -> void:
	if not equipment_manager:   # nothing to build from — bail
		return
	for child: Node in _inventory_grid.get_children():
		child.free()           # free (not queue_free) because we're rebuilding immediately below
	for i: int in EquipmentManager.INVENTORY_SIZE:          # 35 cells, 0-indexed
		var slot : UIItemSlot = UIItemSlot.new()             # create a fresh slot node — no .tscn needed, class is self-contained
		slot.item = equipment_manager.inventory[i]           # point it at the item (or null) at this grid position
		_inventory_grid.add_child(slot)                      # add to the grid — GridContainer handles layout automatically


## Handles all input while this UI node is active.
## The "start" action is always processed (to open/close the menu).
## Everything else only fires while paused so gameplay input doesn't accidentally
## trigger cursor movement or item assignment.
## [param event] the raw input event from Godot
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("start"):
		if get_tree().paused:
			exit_pause_menu()    # menu is open — close it
		else:
			enter_pause_menu()   # menu is closed — open it
		get_viewport().set_input_as_handled()   # consume the event so nothing else reacts to start
		return

	if not get_tree().paused:   # everything below here only makes sense while the menu is open
		return

	# D-pad cursor navigation — moves the cursor around the 7×5 grid
	if event.is_action_pressed("move_right"):
		_move_cursor(1, 0)                        # one column right
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_left"):
		_move_cursor(-1, 0)                       # one column left
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_down"):
		_move_cursor(0, 1)                        # one row down
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_up"):
		_move_cursor(0, -1)                       # one row up
		get_viewport().set_input_as_handled()
	# Slot assignment buttons — pressing a slot button swaps the focused grid cell with that slot
	elif event.is_action_pressed("slot_north"):
		_assign_slot("slot_north")                # swap cursor cell with north/Y slot
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("slot_east"):
		_assign_slot("slot_east")                 # swap cursor cell with east/A slot
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("slot_south"):
		_assign_slot("slot_south")                # swap cursor cell with south/B slot
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("slot_west"):
		_assign_slot("slot_west")                 # swap cursor cell with west/X slot
		get_viewport().set_input_as_handled()


## Pauses the game, hides the cursor, plays the open sound, slides the UI down,
## then after the slide finishes: snaps the cursor to the last focused cell and shows it.
## Cursor is hidden during the slide so it doesn't appear at the wrong position while animating.
func enter_pause_menu() -> void:
	get_tree().paused = true                      # freeze everything that isn't PROCESS_MODE_ALWAYS or WHEN_PAUSED
	_inventory_selector.set_visible_cursor(false) # hide cursor during the slide — it'll be at wrong global_position until menu lands
	SFX.play(LA_PAUSE_MENU_OPEN)                  # play the LA whoosh sound
	var tween : Tween = create_tween()            # this node is PROCESS_MODE_ALWAYS so tweens work even while paused
	tween.tween_property(self, "global_position", OPENED_POSITION, 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)  # smooth slide down
	await tween.finished                           # wait for slide to complete before touching cursor
	_update_cursor_position()                      # now that the menu is at OPENED_POSITION, grid cells have correct global positions
	_inventory_selector.set_visible_cursor(true)  # show cursor at correct location


## Hides the cursor, plays the close sound, slides the UI back up off screen,
## then unpauses the game after the slide finishes.
func exit_pause_menu() -> void:
	_inventory_selector.set_visible_cursor(false) # hide cursor immediately — don't want it visible during the close slide
	SFX.play(LA_PAUSE_MENU_CLOSE)                  # play the close sound
	var tween : Tween = create_tween()
	tween.tween_property(self, "global_position", CLOSED_POSITION, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)  # faster close than open — snappier feel
	await tween.finished                            # wait for slide to finish before unpausing so gameplay doesn't resume mid-animation
	get_tree().paused = false                       # resume normal gameplay


## Moves the cursor by delta columns and delta rows within the 7×5 grid.
## Clamps at grid edges — no wrapping. So pressing right at column 6 stays at column 6.
## Uses clampi() (not clamp()) because all values are ints and clamp() returns Variant.
## [param delta_col] columns to move: -1 left, +1 right
## [param delta_row] rows to move: -1 up, +1 down
func _move_cursor(delta_col: int, delta_row: int) -> void:
	var col     : int = _cursor_index % GRID_COLS                                       # current column (0–6)
	var row     : int = _cursor_index / GRID_COLS                                       # current row (0–4)
	var max_row : int = (EquipmentManager.INVENTORY_SIZE - 1) / GRID_COLS              # last valid row index (4)
	var new_col : int = clampi(col + delta_col, 0, GRID_COLS - 1)                      # clamp column within 0–6
	var new_row : int = clampi(row + delta_row, 0, max_row)                            # clamp row within 0–4
	var new_index : int = new_row * GRID_COLS + new_col                                # convert back to flat array index
	if new_index == _cursor_index:   # already at the edge — nothing to do
		return
	_cursor_index = new_index                                                           # update the cursor position
	var cell : UIItemSlot = _inventory_grid.get_child(_cursor_index) as UIItemSlot     # get the UIItemSlot node at the new index
	if cell:
		_inventory_selector.move_to(cell.global_position, cell.size)                  # tween the cursor to the new cell


## Snaps the cursor immediately to its current index's cell position — no animation.
## Called after the pause menu open animation completes so the cursor appears
## at the right spot without sliding in from wherever it was last frame.
func _update_cursor_position() -> void:
	var cell : UIItemSlot = _inventory_grid.get_child(_cursor_index) as UIItemSlot   # get the cell at the current cursor index
	if cell:
		_inventory_selector.snap_to(cell.global_position, cell.size)                 # instant — no tween


## Tells EquipmentManager to swap the currently focused grid cell with the named slot.
## EquipmentManager handles all four cases (item↔item, item↔empty, empty↔item, noop).
## The signals it emits will trigger [method _on_slot_changed] and [method _on_inventory_changed]
## which update the displays automatically.
## [param slot_name] which slot to swap with — one of "slot_north/east/south/west"
func _assign_slot(slot_name: String) -> void:
	if not equipment_manager:   # nothing to swap with — bail silently
		return
	equipment_manager.swap_inventory_with_slot(_cursor_index, slot_name)  # do the swap — signals handle display updates

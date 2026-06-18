## The cursor that moves around the inventory grid in the pause menu.
## This node sits OUTSIDE the GridContainer (it's a child of InventoryMenu directly)
## so Containers don't fight over its position. That's important — if you drop this
## inside a MarginContainer or HBoxContainer, the container will override global_position
## on every layout pass and the cursor will snap back to origin constantly.
## Visibility and animation are controlled together via [method set_visible_cursor]
## so they always stay in sync — never set visible directly, always go through that method.
extends Control
class_name UIInventorySelector


## The sprite that plays the cursor's visual animation (e.g. a blinking highlight ring).
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

## Drives the "pulse" animation that plays while the cursor is visible.
## Stopped when the cursor is hidden so it doesn't waste cycles off-screen.
@onready var animation_player : AnimationPlayer = $AnimationPlayer


## How long in seconds the tween takes to slide the cursor from cell to cell.
## Short enough to feel snappy, long enough to be readable.
const MOVE_DURATION : float = 0.1


## Set up the cursor node defaults on ready.
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE   # cursor is visual only — never blocks mouse clicks on things behind it
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED # this node needs to keep running while the game is paused (it IS the pause menu)

	# If no real sprite frames are set up yet, slap a debug rect on so the cursor is
	# at least visible during development without needing final art
	if not animated_sprite.sprite_frames or animated_sprite.sprite_frames.get_frame_texture( "default", 0 ) == null:
		_create_debug_rect()


## Spawns a bright yellow-ish ColorRect as a stand-in cursor visual for when the
## real sprite sheet isn't set up yet. Helpful during development.
func _create_debug_rect() -> void:
	var rect : ColorRect = ColorRect.new()           # a plain colored rectangle as a placeholder
	rect.name = "DebugRect"                          # give it a name so it's easy to spot in the remote scene tree
	rect.color = Color( 1, 0.9, 0.3, 0.7 )          # bright yellow-ish, semi-transparent — hard to miss
	rect.size = Vector2( 32, 32 )                    # same size as a standard inventory cell
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # debug rect also shouldn't block clicks
	add_child( rect )                                # add it to this node so it renders
	move_child( rect, 0 )                            # push it to the back so real sprites render in front if they exist


## Smoothly tweens the cursor to a new cell position and size.
## Called every time the player moves the cursor with the d-pad.
## Both global_position and size are tweened in parallel so the cursor glides smoothly.
## [param target_position] the global screen position to move to (usually cell.global_position)
## [param target_size] the size to match — defaults to 32×32 which is a standard cell
func move_to( target_position: Vector2, target_size: Vector2 = Vector2( 32, 32 ) ) -> void:
	var tween : Tween = create_tween()                 # fresh tween each call — previous one is abandoned and GC'd
	tween.set_parallel( true )                         # position and size animate simultaneously
	tween.tween_property( self, "global_position", target_position, MOVE_DURATION ).set_trans( Tween.TRANS_QUAD ).set_ease( Tween.EASE_OUT )  # ease out feels snappier
	tween.tween_property( self, "size", target_size, MOVE_DURATION ).set_trans( Tween.TRANS_QUAD ).set_ease( Tween.EASE_OUT )


## Instantly teleports the cursor to a new position and size — no animation.
## Used when the pause menu first opens so the cursor appears at the right spot
## without tweening in from wherever it last was.
## [param target_position] the global screen position to snap to
## [param target_size] the size to match — defaults to 32×32
func snap_to( target_position: Vector2, target_size: Vector2 = Vector2( 32, 32 ) ) -> void:
	global_position = target_position   # instant — no tween
	size = target_size                  # match the cell size exactly


## Swaps in a new [SpriteFrames] resource on the animated sprite.
## Useful for loading the real cursor art after a debug rect session, or for
## swapping cursor styles later if needed.
## [param frames] the new SpriteFrames to assign
func set_sprite_frames( frames: SpriteFrames ) -> void:
	if animated_sprite:
		animated_sprite.sprite_frames = frames  # only assign if the sprite node actually exists


## Shows or hides the cursor and starts/stops the pulse animation to match.
## Always use this instead of setting [code]visible[/code] directly so the
## animation player stays in sync with visibility — a visible-but-stopped animation
## would look like a frozen cursor.
## [param is_it_visible] true to show and animate, false to hide and stop
func set_visible_cursor( is_it_visible: bool ) -> void:
	visible = is_it_visible          # show or hide the whole node
	if animation_player:
		if visible:
			animation_player.play("pulse")  # start pulsing when visible
		else:
			animation_player.stop()         # stop the animation when hidden — no wasted processing

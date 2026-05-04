extends Node3D


# EXPORTS — tweak in the Inspector
## Total number of pages in the XIC.
@export var page_count: int = 20

## Position of the book relative to the camera when held.
## Positive X = right, negative Y = down, negative Z = forward (into screen).
@export var hold_position: Vector3 = Vector3(0.25, -0.28, -0.55)

## Rotation of the book (degrees) when held.
@export var hold_rotation_deg: Vector3 = Vector3(-8.0, 12.0, -3.0)

## How fast the book lerps into the hold position.
@export var lerp_speed: float = 10.0

# SIGNALS

## Emitted whenever the page changes. Connect this to your UI/content system.
signal page_changed(page_index: int)

## Emitted when the book is picked up or put down.
signal book_picked_up()
signal book_put_down()

# INTERNAL STATE

var is_held: bool = false
var current_page: int = 0
var is_animating: bool = false

var _camera: Camera3D = null
var _original_parent: Node = null
var _original_global_transform: Transform3D

@onready var _anim: AnimationPlayer = $AnimationPlayer


# READY

func _ready() -> void:
	_original_parent = get_parent()
	_original_global_transform = global_transform
	set_process(false)          # only run _process when held
	set_process_unhandled_input(false)  # only listen for input when held



# PUBLIC API — call these from your interaction system


## Call this from your raycasting/interaction script when the player picks up the XIC.
## Pass in your Camera3D node (or the node you want the book attached to).
func pickup(player_camera: Camera3D) -> void:
	if is_held:
		return

	_camera = player_camera
	is_held = true

	# Reparent to camera so the book moves with the player's head.
	var saved_global = global_transform
	get_parent().remove_child(self)
	_camera.add_child(self)
	global_transform = saved_global   # keep world position; lerp does the rest

	# Play the open animation if you have one, otherwise skip.
	if _anim.has_animation("open"):
		_anim.play("open")

	set_process(true)
	set_process_unhandled_input(true)
	emit_signal("book_picked_up")


## Call this to drop/close the book (also called internally on "xic_close" input).
func put_down() -> void:
	if not is_held:
		return

	set_process_unhandled_input(false)

	# Play close animation and wait before reparenting.
	if _anim.has_animation("close"):
		_anim.play("close")
		await _anim.animation_finished

	is_held = false
	set_process(false)

	# Reparent back to the world.
	var saved_global = global_transform
	_camera.remove_child(self)
	_original_parent.add_child(self)
	global_transform = saved_global
	_camera = null

	emit_signal("book_put_down")


# ─────────────────────────────────────────────
# PROCESS — smooth hold positioning
# ─────────────────────────────────────────────

func _process(delta: float) -> void:
	if not is_held or _camera == null:
		return

	# Smoothly lerp the book to its resting position in front of the camera.
	position = position.lerp(hold_position, lerp_speed * delta)
	rotation_degrees = rotation_degrees.lerp(hold_rotation_deg, lerp_speed * delta)


# ─────────────────────────────────────────────
# INPUT — page flipping and closing
# ─────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if not is_held:
		return

	if event.is_action_pressed("xic_page_next"):
		_flip_page(1)
	elif event.is_action_pressed("xic_page_prev"):
		_flip_page(-1)
	elif event.is_action_pressed("xic_close"):
		put_down()

# PAGE FLIPPING

func _flip_page(direction: int) -> void:
	# Block input while an animation is playing.
	if is_animating:
		return

	var target_page: int = current_page + direction

	# Clamp to valid range.
	if target_page < 0 or target_page >= page_count:
		_play_limit_bump()   # optional: small shake to signal the boundary
		return

	current_page = target_page
	is_animating = true

	var anim_name: String = "flip_forward" if direction > 0 else "flip_backward"

	if _anim.has_animation(anim_name):
		_anim.play(anim_name)
		await _anim.animation_finished
	else:
		# Fallback if animation is missing: just wait a moment.
		await get_tree().create_timer(0.15).timeout

	is_animating = false
	emit_signal("page_changed", current_page)


## Optional small positional bump when the player tries to flip past the first/last page.
func _play_limit_bump() -> void:
	# Quick tween nudge — feels like the book resisting.
	var tween: Tween = create_tween()
	var bump_offset := Vector3(0.0, 0.0, 0.03)
	tween.tween_property(self, "position", hold_position + bump_offset, 0.06)
	tween.tween_property(self, "position", hold_position, 0.08)

# UTILITY

## Jump directly to a specific page (e.g. from a search result).
func go_to_page(index: int) -> void:
	index = clamp(index, 0, page_count - 1)
	current_page = index
	emit_signal("page_changed", current_page)

## Returns the current page index.
func get_current_page() -> int:
	return current_page

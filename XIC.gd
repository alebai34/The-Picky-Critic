extends Node3D

# EXPORTS.

@export var page_count: int = 4
@export var hold_position: Vector3 = Vector3(0.25, -0.28, -0.55)
@export var hold_rotation_deg: Vector3 = Vector3(-8.0, 12.0, -3.0)
@export var lerp_speed: float = 10.0

# SIGNALS.

signal page_changed(page_index: int)
signal book_picked_up()
signal book_put_down()

# STATES.

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
	set_process(false)
	set_process_unhandled_input(false)

func pickup(player_camera: Camera3D) -> void:
	if is_held:
		return

	_camera = player_camera
	is_held = true

	var saved_global = global_transform
	get_parent().remove_child(self)
	_camera.add_child(self)
	global_transform = saved_global

	if _anim.has_animation("open"):
		_anim.play("open")

	set_process(true)
	set_process_unhandled_input(true)
	emit_signal("book_picked_up")

func put_down() -> void:
	if not is_held:
		return

	set_process_unhandled_input(false)

	if _anim.has_animation("close"):
		_anim.play("close")
		await _anim.animation_finished

	is_held = false
	set_process(false)

	var saved_global = global_transform
	_camera.remove_child(self)
	_original_parent.add_child(self)
	global_transform = saved_global
	_camera = null

	emit_signal("book_put_down")

func _process(delta: float) -> void:
	if not is_held or _camera == null:
		return

	position = position.lerp(hold_position, lerp_speed * delta)
	rotation_degrees = rotation_degrees.lerp(hold_rotation_deg, lerp_speed * delta)

# INPUT

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

	if is_animating:
		return

	var target_page: int = current_page + direction

	
	if target_page < 0 or target_page >= page_count:
		_play_limit_bump()
		return

	current_page = target_page
	is_animating = true

	var anim_name: String = "flip_forward" if direction > 0 else "flip_backward"

	if _anim.has_animation(anim_name):
		_anim.play(anim_name)
		await _anim.animation_finished
	else:
		await get_tree().create_timer(0.15).timeout

	is_animating = false
	emit_signal("page_changed", current_page)

func _play_limit_bump() -> void:
	var tween: Tween = create_tween()
	var bump_offset := Vector3(0.0, 0.0, 0.03)
	tween.tween_property(self, "position", hold_position + bump_offset, 0.06)
	tween.tween_property(self, "position", hold_position, 0.08)

# UTILITY

func go_to_page(index: int) -> void:
	index = clamp(index, 0, page_count - 1)
	current_page = index
	emit_signal("page_changed", current_page)

func get_current_page() -> int:
	return current_page

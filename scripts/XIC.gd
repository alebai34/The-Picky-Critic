extends Node3D

@export var hold_position: Vector3 = Vector3(0.25, -0.28, -0.55)
@export var hold_rotation_deg: Vector3 = Vector3(-8.0, 12.0, -3.0)
@export var lerp_speed: float = 10.0

@onready var pages = $Pages.get_children()

var current_index = 0
var is_turning = false

func _ready():
	for page in pages:
		page.hide()
	pages[0].show()

func _process(delta):
	if is_turning:
		return

	if Input.is_action_just_pressed("ui_right") and current_index < pages.size() - 1:
		is_turning = true
		pages[current_index + 1].show()
		await turn_page(pages[current_index], 0.0, 180.0)
		current_index += 1
		refresh()
		is_turning = false

	if Input.is_action_just_pressed("ui_left") and current_index > 0:
		is_turning = true
		if current_index - 2 >= 0:
			pages[current_index - 2].show()
		await turn_page(pages[current_index - 1], 180.0, 0.0)
		current_index -= 1
		refresh()
		is_turning = false

func turn_page(page: Node, from_z: float, to_z: float):
	page.rotation_degrees.z = from_z
	var tween = create_tween()
	tween.tween_property(page, "rotation_degrees:z", to_z, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func refresh():
	for page in pages:
		page.hide()
	if current_index > 0:
		pages[current_index - 1].show()
	pages[current_index].show()

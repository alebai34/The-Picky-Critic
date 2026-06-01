extends Node3D

@onready var xic_overlay: CanvasLayer = $XICOverlay
@onready var cam = $Camera3D
@onready var ray_cast_3d: RayCast3D = $Camera3D/RayCast3D

var _held_xic: Node = null   

var sensitivity := 0.002
var can_look := true

signal health_changed(new_hp: int)

var hp := 6 :
	set(value):
		hp = clamp(value, 0, 6)
		health_changed.emit(hp)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ray_cast_3d.enabled = true
	
	FoodHandler.s_food_binned.connect(_on_food_binned)
	
func _process(delta):
	return
	
func _on_food_binned():
	print("player binned the food")
	
func _input(event):
	# ESC toggles locked mouse.
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		can_look = !can_look
		if can_look:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# interact detection.
	if event.is_action_pressed("interact") and ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()
		if collider.has_method("interact"):
			collider.interact()
			get_viewport().set_input_as_handled()
		return


	# block camera movement when disabled.
	if not can_look:
		return


	# mouse look.
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		cam.rotate_x(-event.relative.y * sensitivity)

		cam.rotation.x = clamp(
			cam.rotation.x,
			deg_to_rad(-80),
			deg_to_rad(80)
		)

# XIC/Interactions. 

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if _held_xic != null:
			_held_xic.put_down()
			_held_xic = null
		else:
			_try_interact()
 
 
func _try_interact() -> void:
	if not ray_cast_3d.is_colliding():
		return
	var target = ray_cast_3d.get_collider()
	var xic: Node = _find_xic_in_parents(target)
	if xic != null:
		xic.pickup(cam)
		_held_xic = xic
		xic_overlay.show_for_xic(xic.page_count)
		if not xic.page_changed.is_connected(_on_xic_page_changed):
			xic.page_changed.connect(_on_xic_page_changed)
		if not xic.book_put_down.is_connected(_on_xic_closed):
			xic.book_put_down.connect(_on_xic_closed)
 
func _find_xic_in_parents(node: Node) -> Node:
	var current = node
	while current != null:
		if current.has_method("pickup"):
			return current
		current = current.get_parent()
	return null
 
func _on_xic_page_changed(page_index: int) -> void:
	xic_overlay.on_page_changed(page_index)

 
func _on_xic_closed() -> void:
	_held_xic = null
	xic_overlay.hide_xic()

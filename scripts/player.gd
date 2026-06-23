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
 
func _try_interact() -> void:
	if not ray_cast_3d.is_colliding():
		return
	var target = ray_cast_3d.get_collider()
	

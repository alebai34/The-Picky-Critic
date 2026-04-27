extends Node3D

@onready var cam = $Camera3D
@export var ray_cast_3d: RayCast3D


var sensitivity := 0.002
var can_look := true


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ray_cast_3d.enabled = true

func _input(event):
	# ESC toggles look + mouse mode
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		can_look = !can_look

		if can_look:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

		return  # stop processing this event


	# block camera movement when disabled
	if not can_look:
		return


	# mouse look
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		cam.rotate_x(-event.relative.y * sensitivity)

		cam.rotation.x = clamp(
			cam.rotation.x,
			deg_to_rad(-80),
			deg_to_rad(80)
		)

func _physics_process(delta: float) -> void:
	if ray_cast_3d.is_colliding():
		var hit = ray_cast_3d.get_collider()
		print("hit ray_cast_3d")

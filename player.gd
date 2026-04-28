extends Node3D

@onready var cam = $Camera3D
@onready var ray_cast_3d: RayCast3D = $Camera3D/RayCast3D



var sensitivity := 0.002
var can_look := true


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ray_cast_3d.enabled = true

func _input(event):
	#ESC toggles locked mouse
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		can_look = !can_look
		if can_look:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	#interact detection
	if event.is_action_pressed("interact"):
		if ray_cast_3d.is_colliding():
			var collider = ray_cast_3d.get_collider()
			if collider.has_method("interact"):
				collider.interact()
	
		return


	#block camera movement when disabled
	if not can_look:
		return


	#mouse look
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		cam.rotate_x(-event.relative.y * sensitivity)

		cam.rotation.x = clamp(
			cam.rotation.x,
			deg_to_rad(-80),
			deg_to_rad(80)
		)

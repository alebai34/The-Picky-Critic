extends Node3D

@onready var xic_overlay: CanvasLayer = $XICOverlay
@onready var cam = $Camera3D
@onready var ray_cast_3d: RayCast3D = $Camera3D/RayCast3D
@onready var health: int = 1

var _held_xic: Node = null   

var sensitivity := 0.002
var can_look := true


signal health_changed(new_hp: int)


func lose_health():
	health -=1
	print("you lose a health, your health is now ",health)
	if health <= 0:
		die()

func die():
	print("you die")
	return
	#get_tree().reload_current_scene()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ray_cast_3d.enabled = true
	FoodHandler.s_lose_health.connect(lose_health)
	FoodHandler.s_food_binned.connect(_on_food_binned)
	
func _process(delta):
	return
	
func _on_food_binned():
	print("player binned the food")
	
func _input(event):
	# ESC toggles locked mouse.
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and GameManager.focused == false:
		
		can_look = !can_look

		if can_look:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			GameManager.paused = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			GameManager.paused = true
	
	# interact detection.
	
	if event.is_action_pressed("interact") and ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()
		if collider.has_method("interact"):
			if GameManager.paused == true:
				return
			collider.interact()
			get_viewport().set_input_as_handled()
		return


	# block camera movement when disabled.
	if not can_look:
		return


	# mouse look.
	if event is InputEventMouseMotion and GameManager.focused == false:
		rotate_y(-event.relative.x * sensitivity)
		cam.rotate_x(-event.relative.y * sensitivity)

		cam.rotation.x = clamp(
			cam.rotation.x,
			deg_to_rad(-80),
			deg_to_rad(80)
		)

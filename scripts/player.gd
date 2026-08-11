extends Node3D

#@onready var xic_overlay: CanvasLayer = $XICOverlay
@onready var cam = $Camera3D
@onready var ray_cast_3d: RayCast3D = $Camera3D/RayCast3D
@onready var health: int = 1
@onready var score_label = %ScoreLabel

var _held_xic: Node = null
var sensitivity := 0.002
var can_look := true
var score := 0

signal health_changed(new_hp: int)

func die():
	print("you die")
	return
	#get_tree().reload_current_scene()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ray_cast_3d.enabled = true
	FoodHandler.s_food_binned.connect(_on_food_binned)
	GameManager.pause_requested.connect(_on_pause_requested)
	GameManager.resume_requested.connect(_on_resume_requested)
	GameManager.close_book_requested.connect(_on_resume_requested)
	GameManager.safe.connect(update_score)
	GameManager.not_safe.connect(screen_flash)
	
func update_score():
	score = score + 1
	score_label.text = str(score)
	
func screen_flash():
	var ap = get_node_or_null("CanvasLayer/ColourFlash/AnimationPlayer")
	if ap:
		ap.play("take_damage")

	pass

func _process(_delta):
	return

func _on_food_binned():
	print("player binned the food")

func _on_pause_requested():
	can_look = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_resume_requested():
	can_look = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# interact detection
	if event.is_action_pressed("interact") and ray_cast_3d.is_colliding():
		if GameManager.game_paused or GameManager.focused:
			return
		var collider = ray_cast_3d.get_collider()
		if collider.has_method("interact"):
			collider.interact()
			get_viewport().set_input_as_handled()
		return

	# block camera movement when disabled
	if not can_look:
		return

	# mouse look
	if event is InputEventMouseMotion and GameManager.focused == false and GameManager.game_paused == false:
		rotate_y(-event.relative.x * sensitivity)
		cam.rotate_x(-event.relative.y * sensitivity)
		cam.rotation.x = clamp(
			cam.rotation.x,
			deg_to_rad(-80),
			deg_to_rad(80)
		)

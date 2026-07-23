extends Control

@export var heart_container: PackedScene
@onready var heart_box: HBoxContainer = $HeartBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.health_changed.connect(update_health)
	update_health()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_health():
	for child in heart_box.get_children():
		child.queue_free()
	for i in range(GameManager.health):
		var new_heart = heart_container.instantiate()
		heart_box.add_child(new_heart)
	

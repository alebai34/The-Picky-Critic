extends Node

signal s_food_arrived
signal s_food_eaten
signal s_food_binned

func food_arrived():
	print("placing food")
	emit_signal("s_food_arrived")
	
func food_eaten():
	emit_signal("s_food_eaten")

func food_binned():
	if s_food_arrived:
		emit_signal("s_food_binned")
		pass
	
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Node

signal s_food_arrived
signal s_food_eaten

func food_arrived():
	print("placing food")
	emit_signal("s_food_arrived")
	
func food_eaten():
	emit_signal("s_food_eaten")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

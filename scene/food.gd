extends Area3D
class_name FoodDish

@export var safe_to_eat : bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func bin():
	FoodHandler.food_binned

func interact():
	FoodHandler.food_eaten()
	if safe_to_eat:
		print("live")
	else:
		print("die")
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

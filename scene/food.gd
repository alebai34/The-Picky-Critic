extends Area3D
class_name FoodDish

@export var safe_to_eat : bool = true
# Called when the node enters the scene tree for the first time.
func _ready():
	FoodHandler.s_food_eaten.connect(eat_food)
	FoodHandler.s_food_binned.connect(bin)

func eat_food():
	print("EATEN")
	queue_free()
		
	
func bin():
	print("BINNED")
	queue_free()

func interact():
	FoodHandler.food_eaten()
	if safe_to_eat:
		print("live")
	else:
		print("die")
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	return
	#if decline_button.bin_food:
	#	queue_free()
	pass

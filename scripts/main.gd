extends Node3D

@export var food : PackedScene
@onready var food_location: Marker3D = $Table/FoodLocation

func _ready() -> void:
	var player = $Player 
	var health_ui = $HealthUI
	player.health_changed.connect(health_ui.update_health)
	FoodHandler.s_food_arrived.connect(place_food)
	
func place_food():
	var new_food = food.instantiate()
	#new_food.position = food_location.global_position
	food_location.add_child(new_food)
	

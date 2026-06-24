extends Node3D

#@export var foods : Array[PackedScene]
@onready var food_location: Marker3D = $Table/FoodLocation
@export var waiter : CharacterBody3D

func _ready() -> void:
	var player = $Player 
	var health_ui = $HealthUI
	player.health_changed.connect(health_ui.update_health)
	FoodHandler.s_food_arrived.connect(place_food)
	
func place_food(food_scene):
	#var food_scene = foods.pick_random()
	var new_food = food_scene.instantiate()
	#waiter. #create scene here, potentially model here
	food_location.add_child(new_food)
	

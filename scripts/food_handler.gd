extends Node

signal s_food_arrived
signal s_food_eaten
signal s_food_binned
signal s_lose_health
var food_is_present := false
var can_interact = false

func player_lose_health():
	s_lose_health.emit()
	GameManager.lose_health(1)

func food_arrived(food):
	print("placing food")
	food_is_present = true
	s_food_arrived.emit(food)

func food_eaten():
	food_is_present = false
	s_food_eaten.emit()

func food_binned():
	if food_is_present:
		food_is_present = false
		s_food_binned.emit()
		print("food binned")

extends Node

signal s_food_arrived
signal s_food_eaten
signal s_food_binned

var food_is_present := false
var can_interact = false



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

extends Area3D
class_name BinButton
signal bin_food

func interact():
	print("Bin button was clicked!")
	FoodHandler.food_binned()

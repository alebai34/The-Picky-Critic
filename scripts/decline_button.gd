extends Area3D
class_name BinButton
signal bin_food

func interact():
	print("Bin button was clicked!")
	if FoodHandler.can_interact == true:
		FoodHandler.food_binned()
	else:
		print("Can't bin yet")

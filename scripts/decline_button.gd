extends Area3D
class_name BinButton
signal bin_food

func bin():
	print("Bin button was clicked!")
	emit_signal("bin_food")

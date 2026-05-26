extends Area3D
class_name BinButton
signal bin_food

func interact():
	print("Bin button was clicked!")
	emit_signal("bin_food")

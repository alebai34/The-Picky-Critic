extends Control


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file('res://scene/main.tscn')
	
	pass 


func _on_quit_pressed() -> void:
	get_tree().quit()
	
	pass


func _on_records_pressed() -> void:
	
	
	pass

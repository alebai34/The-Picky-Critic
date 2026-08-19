extends CanvasLayer

func _ready() -> void:
	GameManager.dead.connect(show_death_screen)
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	hide()

func show_death_screen() -> void:
	show()
	get_tree().paused = true

func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/main.tscn")

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/titlescreen.tscn")

func save_record() -> void:
	var player_name = $NameInput.text.strip_edges()
	if player_name == "":
		player_name = "Anonymous"
	var final_time = get_node("/root/Main/TimeTrial").total_time_in_secs # adjust path
	RecordsManager.add_record(final_time, player_name)

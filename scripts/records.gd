extends Control

@onready var vbox = $Records/MarginContainer/ScrollContainer/VBoxContainer

func _ready() -> void:
	populate_records()

func populate_records() -> void:
	for child in vbox.get_children():
		child.queue_free()

	for i in range(RecordsManager.records.size()):
		var record = RecordsManager.records[i]
		var t = record["time"]
		var m = int(t / 60.0)
		var s = int(t) % 60
		var label = Label.new()
		label.text = "%d. %s — %02d:%02d" % [i + 1, record["name"], m, s]
		vbox.add_child(label)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/titlescreen.tscn")
	
	pass

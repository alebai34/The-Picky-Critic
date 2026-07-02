extends Node

@onready var pause_menu = $CanvasLayer/PauseMenu
var focused = false
var paused = false

func _ready() -> void:
	pause_menu.visible = false
	
#func toggle_pause():
#	get_tree().paused = !get_tree().paused
#	pause_menu.visible = get_tree().paused

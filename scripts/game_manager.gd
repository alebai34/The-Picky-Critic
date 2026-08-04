extends Node

signal close_book_requested
signal pause_requested
signal resume_requested
signal health_changed

var focused: bool = false
var game_paused: bool = false
var health: = 6


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if focused:
			close_book_requested.emit()
		elif game_paused:
			resume_requested.emit()
		else:
			pause_requested.emit()
		get_viewport().set_input_as_handled()

func lose_health(amount):
	health-=amount
	emit_signal("health_changed")

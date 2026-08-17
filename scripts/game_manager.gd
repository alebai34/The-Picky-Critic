extends Node

signal close_book_requested
signal pause_requested
signal resume_requested
signal health_changed
signal safe
signal not_safe
signal flash
signal dead

var focused: bool = false
var game_paused: bool = false
var health: = 1 # at 1 for debugging

func emit_safe():
	emit_signal("safe")
	
func emit_not_safe():
	emit_signal("not_safe")
	

	
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
	health -= amount
	emit_signal("health_changed")
	if health <= 0:
		await get_tree().process_frame
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		emit_signal("dead")
		
		

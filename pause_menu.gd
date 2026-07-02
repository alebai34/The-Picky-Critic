# ============================================
# PauseMenu.gd
# ============================================
extends CanvasLayer

func _ready() -> void:
	hide()
	GameManager.pause_requested.connect(_on_pause_requested)
	GameManager.resume_requested.connect(_on_resume_requested)

func _on_pause_requested():
	visible = true
	GameManager.game_paused = true

func _on_resume_requested():
	visible = false
	GameManager.game_paused = false

func _on_resume_pressed() -> void:
	GameManager.resume_requested.emit()

func _on_quit_pressed() -> void:
	get_tree().quit()

extends Node3D

func _ready() -> void:
	var player = $Player 
	var health_ui = $HealthUI
	player.health_changed.connect(health_ui.update_health)

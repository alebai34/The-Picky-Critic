extends SpotLight3D

@export var flicker_strength: float = 0.05
@export var flicker_speed: float = 20.0

func _process(delta: float) -> void:
	light_energy = 1.5 + sin(Time.get_ticks_msec() * 0.001 * flicker_speed) * flicker_strength

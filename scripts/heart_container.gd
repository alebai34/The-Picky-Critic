extends Control

@export var tex_full: Texture2D
@export var tex_half: Texture2D
@export var tex_empty: Texture2D

@onready var texture_rect := $TextureRect

# 0 = empty, 1 = half, 2 = full
func set_state(state: int) -> void:
	match state:
		0: texture_rect.texture = tex_empty
		1: texture_rect.texture = tex_half
		2: texture_rect.texture = tex_full

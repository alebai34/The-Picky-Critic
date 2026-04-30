extends Control

# Customize the dot here
@export var dot_radius: float = 2.0
@export var dot_color: Color = Color.WHITE

func _draw():
	# Draw the dot at the center of this control node
	var center = size / 2
	draw_circle(center, dot_radius, dot_color)

extends ColorRect

var tween: Tween

func flash():
	if tween:
		tween.kill()

	color.a = 0.0

	tween = create_tween()
	tween.tween_property(self, "color:a", 0.35, 0.06)
	tween.tween_property(self, "color:a", 0.0, 0.18)

extends HBoxContainer

const MAX_HP := 6  # 3 hearts × 2

@onready var hearts := get_children()

func update_health(current_hp: int) -> void:
	current_hp = clampi(current_hp, 0, MAX_HP)
	for i in hearts.size():
		var hp_for_heart: int = clampi(current_hp - i * 2, 0, 2)
		hearts[i].set_state(hp_for_heart)

extends CharacterBody3D

enum State { WALKING_TO_PLAYER, DOING_ANIMATION, LEAVING, DONE }

@export var walk_speed: float = 0.15
@export var stop_point: float = 0.5

var current_state: State = State.WALKING_TO_PLAYER


func _process(delta: float) -> void:
	match current_state:
		State.WALKING_TO_PLAYER:
			_walk_to_player(delta)
		State.LEAVING:
			_walk_to_exit(delta)


func _walk_to_player(delta: float) -> void:
	get_parent().progress_ratio = move_toward(get_parent().progress_ratio, stop_point, walk_speed * delta)
	if get_parent().progress_ratio >= stop_point:
		current_state = State.DOING_ANIMATION
		_play_animation()


func _walk_to_exit(delta: float) -> void:
	get_parent().progress_ratio = move_toward(get_parent().progress_ratio, 1.0, walk_speed * delta)
	if get_parent().progress_ratio >= 1.0:
		_despawn()


func _play_animation() -> void:
	print("Serving food...")
	await get_tree().create_timer(2.0).timeout
	current_state = State.LEAVING


func _despawn() -> void:
	current_state = State.DONE
	queue_free()

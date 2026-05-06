extends CharacterBody3D

enum State { WALKING_TO_PLAYER, DOING_ANIMATION, LEAVING, DONE }

@export var walk_speed: float = 0.15
@export var stop_point: float = 0.5

@onready var food: Node3D = $HandPoint/Tentacle
@onready var hand_point: Marker3D = $HandPoint

var current_state: State = State.WALKING_TO_PLAYER
var table_position: Vector3  # Where the food gets placed


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
		_place_food()


func _walk_to_exit(delta: float) -> void:
	get_parent().progress_ratio = move_toward(get_parent().progress_ratio, 1.0, walk_speed * delta)
	if get_parent().progress_ratio >= 1.0:
		_despawn()


func _place_food() -> void:
	current_state = State.DOING_ANIMATION

	# Save the food's current world position
	table_position = food.global_position

	# Detach food from NPC and place it in the world
	var food_parent = food.get_parent()
	food_parent.remove_child(food)
	get_tree().current_scene.add_child(food)

	# Keep it in the same world position
	food.global_position = table_position

	# Wait, then leave
	await get_tree().create_timer(1.0).timeout
	current_state = State.LEAVING


func _despawn() -> void:
	current_state = State.DONE
	queue_free()

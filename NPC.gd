extends CharacterBody3D

enum State { IDLE, WALKING_TO_DESTINATION, LEAVING, DONE }

@export var destination: Vector3        # Where the NPC walks to
@export var exit_point: Vector3         # Where the NPC walks to despawn
@export var move_speed: float = 3.0
@export var arrival_wait_time: float = 2.0  # How long they linger at destination

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var current_state: State = State.IDLE


func _ready() -> void:
	# Start walking once the navigation map is ready
	call_deferred("_start_walking")


func _start_walking() -> void:
	current_state = State.WALKING_TO_DESTINATION
	nav_agent.target_position = destination


func _physics_process(delta: float) -> void:
	match current_state:
		State.WALKING_TO_DESTINATION, State.LEAVING:
			_move_along_path(delta)


func _move_along_path(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		_on_destination_reached()
		return

	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = (next_pos - global_position).normalized()

	velocity = direction * move_speed
	move_and_slide()


func _on_destination_reached() -> void:
	match current_state:
		State.WALKING_TO_DESTINATION:
			current_state = State.IDLE
			# Wait at the destination, then leave
			await get_tree().create_timer(arrival_wait_time).timeout
			_start_leaving()

		State.LEAVING:
			_despawn()


func _start_leaving() -> void:
	current_state = State.LEAVING
	nav_agent.target_position = exit_point


func _despawn() -> void:
	current_state = State.DONE
	queue_free()  # Removes the NPC from the scene

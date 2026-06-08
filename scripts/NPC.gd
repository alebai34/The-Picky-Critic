extends CharacterBody3D
enum State { WALKING_TO_PLAYER, DOING_ANIMATION, LEAVING, DONE, BUSY }
@onready var animator: AnimationPlayer = $AnimationPlayer
@export var walk_speed: float = 0.15
@export var stop_point: float = 0.5
@onready var food: Node3D = $HandPoint/Tentacle
@onready var hand_point: Marker3D = $HandPoint

var current_state: State = State.WALKING_TO_PLAYER:
	set(value):
		current_state = value
		print("State changed to: ", State.keys()[value])

var table_position: Vector3

func _ready():
	FoodHandler.s_food_eaten.connect(food_eaten)
	FoodHandler.s_food_binned.connect(food_binned)

func food_eaten():
	current_state = State.WALKING_TO_PLAYER

func food_binned():
	current_state = State.WALKING_TO_PLAYER

func _process(delta: float) -> void:
	match current_state:
		State.BUSY:
			return
		State.WALKING_TO_PLAYER:
			_walk_to_player(delta)
		State.LEAVING:
			_walk_to_exit(delta)

func _walk_to_player(delta: float) -> void:
	FoodHandler.can_interact = false
	current_state = State.BUSY
	animator.play("DELIVER")
	await animator.animation_finished
	
	_place_food()

func _walk_to_exit(delta: float) -> void:
	current_state = State.BUSY
	animator.play("LEAVE")
	await animator.animation_finished
	current_state = State.DONE
	FoodHandler.can_interact = true

func _place_food() -> void:
	current_state = State.BUSY
	FoodHandler.food_arrived()
	await get_tree().create_timer(1.0).timeout
	current_state = State.LEAVING

func _despawn() -> void:
	current_state = State.DONE
	queue_free()

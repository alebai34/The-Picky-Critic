extends CharacterBody3D

enum State { WALKING_TO_PLAYER, DOING_ANIMATION, LEAVING, DONE, BUSY }
@onready var animator: AnimationPlayer = $AnimationPlayer

@export var walk_speed: float = 0.15
@export var stop_point: float = 0.5

@onready var food: Node3D = $HandPoint/Tentacle
@onready var hand_point: Marker3D = $HandPoint
#@export var dishes : = Array[FoodDish]

var current_state: State = State.WALKING_TO_PLAYER
var table_position: Vector3  # Where the food gets placed

func _ready():
	FoodHandler.s_food_eaten.connect(ready_for_delivery)
	FoodHandler.s_food_binned.connect(ready_for_delivery)
	
func ready_for_delivery():
	current_state = State.WALKING_TO_PLAYER
	#generate new food

func _process(delta: float) -> void:
	
	match current_state:
		State.BUSY:
			return
		State.WALKING_TO_PLAYER:
			_walk_to_player(delta)
		State.LEAVING:
			_walk_to_exit(delta)


func _walk_to_player(delta: float) -> void:
		current_state = State.BUSY
		animator.play("DELIVER")
		await animator.animation_finished

		_place_food()


func _walk_to_exit(delta: float) -> void:
	animator.play("LEAVE")
	current_state = State.BUSY
	await animator.animation_finished
	print("BACK IN THE KITCHEN")
	current_state = State.DONE


func _place_food() -> void:
	current_state = State.BUSY

	FoodHandler.food_arrived()
#
	## Wait, then leave
	await get_tree().create_timer(1.0).timeout
	current_state = State.LEAVING


func _despawn() -> void:
	current_state = State.DONE
	queue_free()

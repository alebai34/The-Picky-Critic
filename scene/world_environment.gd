extends WorldEnvironment
@onready var world_environment: WorldEnvironment = $"."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	world_environment.environment.sky_rotation.y += 0.00005
	world_environment.environment.sky_rotation.x += 0.00005
	if world_environment.environment.sky_rotation.y >= 360:
		world_environment.environment.sky_rotation.y = 0

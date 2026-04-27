extends Node

@export var npc_scene: PackedScene

func spawn_npc(spawn_pos: Vector3, dest: Vector3, exit: Vector3) -> void:
	var npc = npc_scene.instantiate()
	add_child(npc)
	npc.global_position = spawn_pos
	npc.destination = dest
	npc.exit_point = exit

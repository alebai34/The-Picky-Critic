extends Node

const SAVE_PATH = "user://time_trial_records.json"
var records: Array = [] # [{ "time": float, "date": String }, ...]

func _ready() -> void:
	load_records()

func add_record(time_in_secs: float, player_name: String) -> void:
	records.append({
		"time": time_in_secs,
		"name": player_name,
		"date": Time.get_datetime_string_from_system()
	})
	records.sort_custom(func(a, b): return a["time"] < b["time"])
	save_records()

func save_records() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(records))
	file.close()

func load_records() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Array:
		records = parsed

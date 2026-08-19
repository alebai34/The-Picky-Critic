extends CanvasLayer
var total_time_in_secs : float = 0.0
var running := true

func _ready() -> void:
	$Timer.start()
	GameManager.dead.connect(_on_player_died)  # adjust if GameManager isn't the autoload name

func _on_timer_timeout() -> void:
	if running:
		total_time_in_secs += 1
		update_label()

func update_label() -> void:
	var m = int(total_time_in_secs / 60.0)
	var s = int(total_time_in_secs) % 60
	$Label.text = '%02d:%02d' % [m, s]

func _on_player_died() -> void:
	running = false
	$Timer.stop()
	RecordsManager.add_record(total_time_in_secs)

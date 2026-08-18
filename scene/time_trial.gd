extends CanvasLayer

var total_time_in_secs : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# start timer at specific time:
	# (or use 'Autostart property')
	$Timer.start()

func _on_timer_timeout() -> void:
	total_time_in_secs += 1
	var m = int(total_time_in_secs / 60.0)
	var s = total_time_in_secs - m * 60
	$Label.text = '%02d:%02d' % [m, s]

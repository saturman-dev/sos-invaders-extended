extends AudioStreamPlayer

class_name ScaledAudioPlayer


func _process(delta: float) -> void:
	if Engine.time_scale == 0:
		stream_paused = true
	else:
		stream_paused = false

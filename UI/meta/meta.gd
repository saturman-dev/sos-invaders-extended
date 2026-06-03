extends CanvasLayer

@onready var fpscounter := $MarginContainer/hbox/vbox/fps

func _process(delta: float) -> void:
	if Saves.data["show_fps"] == true:
		fpscounter.text = str(Engine.get_frames_per_second()) + " FPS"
	else:
		fpscounter.text = ""

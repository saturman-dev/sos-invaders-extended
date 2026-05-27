extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		toggle_fullscreen()

func toggle_fullscreen():
	var current = DisplayServer.window_get_mode()
	if current == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		var base_size = get_viewport().get_visible_rect().size
		DisplayServer.window_set_size(base_size * 3)
		
		var screen = DisplayServer.window_get_current_screen()
		var screen_size = DisplayServer.screen_get_size(screen)
		var window_size = DisplayServer.window_get_size()
		DisplayServer.window_set_position(screen_size / 2 - window_size / 2)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

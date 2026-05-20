extends Node2D

@onready var best := $CanvasLayer/buttons/BEST

func _ready() -> void:
	best.bbcode_enabled = true
	while Saves.is_loading == true:
		await get_tree().process_frame
	var score = Saves.data["score"]
	if score > 0:
		best.text = str("Highest score: [color=#e5ff00]%s[/color]" % str(int(score)))
	else:
		best.queue_free()

func menuClick_play():
	Functions.sfx_play("res://sounds/menuClick.mp3")

func _on_play_pressed() -> void:
	menuClick_play()
	get_parent().start()


func _on_quit_pressed() -> void:
	menuClick_play()
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)


func _on_extra_pressed() -> void:
	menuClick_play()
	get_parent().extra()

func _on_settings_pressed() -> void:
	menuClick_play()
	get_parent().settings()


func _on_play_mouse_entered() -> void:
	$CanvasLayer/buttons/playAnim.play("hover")

func _on_play_mouse_exited() -> void:
	$CanvasLayer/buttons/playAnim.play("unhover")



func _on_quit_mouse_entered() -> void:
	$CanvasLayer/buttons/quitAnim.play("hover")

func _on_quit_mouse_exited() -> void:
	$CanvasLayer/buttons/quitAnim.play("unhover")



func _on_extra_mouse_entered() -> void:
	$CanvasLayer/buttons/extraAnim.play("hover")

func _on_extra_mouse_exited() -> void:
	$CanvasLayer/buttons/extraAnim.play("unhover")



func _on_settings_mouse_entered() -> void:
	$CanvasLayer/buttons/settingsAnim.play("hover")

func _on_settings_mouse_exited() -> void:
	$CanvasLayer/buttons/settingsAnim.play("unhover")

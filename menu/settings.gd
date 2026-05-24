extends Node2D

var able = false

var fade_tween: Tween
var fade_tween1: Tween
var fade_tween2: Tween
var fade_tween3: Tween

var allVolume = Saves.data["v_all"]
var sfxVolume = Saves.data["v_sfx"]
var musicVolume = Saves.data["v_mus"]
var cd = Saves.data["ct"]

@onready var allSlider := $CanvasLayer/ScrollContainer/VBoxContainer/Control/TextureRect/allSlider
@onready var sfxSlider := $CanvasLayer/ScrollContainer/VBoxContainer/Control/TextureRect/sfxSlider
@onready var musicSlider := $CanvasLayer/ScrollContainer/VBoxContainer/Control/TextureRect/musicSlider
@onready var all1 := $CanvasLayer/ScrollContainer/VBoxContainer/Control/TextureRect/all1
@onready var sfx1 := $CanvasLayer/ScrollContainer/VBoxContainer/Control/TextureRect/sfx1
@onready var music1 := $CanvasLayer/ScrollContainer/VBoxContainer/Control/TextureRect/music1
@onready var cdSlider := $CanvasLayer/ScrollContainer/VBoxContainer/gameplay/TextureRect3/cdSlider
@onready var cd1 := $CanvasLayer/ScrollContainer/VBoxContainer/gameplay/TextureRect3/countd1
@onready var scroll := $CanvasLayer/ScrollContainer
@onready var scroll_speed = 10
@onready var bargal := $CanvasLayer/ScrollContainer/VBoxContainer/gameplay/TextureRect3/hbbarsb/hpbarsg

var loaded := false

func _ready():
	if Saves.data["bars"] == 0.0:
		bargal.play("yes")
	else:
		bargal.play("no")
	allSlider.value = allVolume
	sfxSlider.value = sfxVolume
	musicSlider.value = musicVolume
	cdSlider.value = cd
	loaded = true

func _input(event):
	if event.is_action_pressed("ui_cancel") and able == true:
		backk()

func menuClick_play():
	Functions.sfx_play("res://sounds/menuClick.mp3")

func menuClick2_play():
	if loaded == true:
		Functions.sfx_play("res://sounds/menuClick2.mp3")

func _on_back_pressed() -> void:
	menuClick_play()
	backk()

func backk():
	get_parent().back(1)

func _on_back_mouse_entered() -> void:
	$CanvasLayer/backAnim.play("hover")

func _on_back_mouse_exited() -> void:
	$CanvasLayer/backAnim.play("unhover")


func _on_all_slider_value_changed(value: float) -> void:
	menuClick2_play()
	all1.text = str(int(value))
	Saves.data["v_all"] = value
	Globals.update_volume()

func _on_all_slider_drag_ended(value_changed: bool) -> void:
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(all1, "modulate", Color(1,1,1,0), 1.0)
	fade_tween.finished.connect(func(): all1.visible = false)

func _on_all_slider_drag_started() -> void:
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()
	all1.visible = true
	all1.modulate.a = 0
	fade_tween = create_tween()
	fade_tween.tween_property(all1, "modulate", Color(1,1,1,1), 0.0)




func _on_sfx_slider_value_changed(value: float) -> void:
	menuClick2_play()
	sfx1.text = str(int(value))
	Saves.data["v_sfx"] = value
	Globals.update_volume()

func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	if fade_tween1 and fade_tween1.is_running():
		fade_tween1.kill()
	fade_tween1 = create_tween()
	fade_tween1.tween_property(sfx1, "modulate", Color(1,1,1,0), 1.0)
	fade_tween1.finished.connect(func(): sfx1.visible = false)

func _on_sfx_slider_drag_started() -> void:
	if fade_tween1 and fade_tween1.is_running():
		fade_tween1.kill()
	sfx1.visible = true
	sfx1.modulate.a = 0
	fade_tween = create_tween()
	fade_tween.tween_property(sfx1, "modulate", Color(1,1,1,1), 0.0)




func _on_music_slider_value_changed(value: float) -> void:
	menuClick2_play()
	music1.text = str(int(value))
	Saves.data["v_mus"] = value
	Globals.update_volume()

func _on_music_slider_drag_ended(value_changed: bool) -> void:
	if fade_tween2 and fade_tween2.is_running():
		fade_tween2.kill()
	fade_tween2 = create_tween()
	fade_tween2.tween_property(music1, "modulate", Color(1,1,1,0), 1.0)
	fade_tween2.finished.connect(func(): music1.visible = false)

func _on_music_slider_drag_started() -> void:
	if fade_tween2 and fade_tween2.is_running():
		fade_tween2.kill()
	music1.visible = true
	music1.modulate.a = 0
	fade_tween2 = create_tween()
	fade_tween2.tween_property(music1, "modulate", Color(1,1,1,1), 0.0)




func _on_cd_slider_value_changed(value: float) -> void:
	menuClick2_play()
	cd1.text = str(int(value))
	Saves.data["ct"] = value


func _on_cd_slider_drag_ended(value_changed: bool) -> void:
	if fade_tween3 and fade_tween3.is_running():
		fade_tween3.kill()
	fade_tween3 = create_tween()
	fade_tween3.tween_property(cd1, "modulate", Color(1,1,1,0), 1.0)
	fade_tween3.finished.connect(func(): cd1.visible = false)


func _on_cd_slider_drag_started() -> void:
	if fade_tween3 and fade_tween3.is_running():
		fade_tween3.kill()
	cd1.visible = true
	cd1.modulate.a = 0
	fade_tween3 = create_tween()
	fade_tween3.tween_property(cd1, "modulate", Color(1,1,1,1), 0.0)

func slidescroll(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			get_viewport().set_input_as_handled()
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				scroll.scroll_vertical -= scroll_speed
			else:
				scroll.scroll_vertical += scroll_speed

func _on_all_slider_gui_input(event: InputEvent) -> void:
	slidescroll(event)


func _on_sfx_slider_gui_input(event: InputEvent) -> void:
	slidescroll(event)


func _on_music_slider_gui_input(event: InputEvent) -> void:
	slidescroll(event)


func _on_cd_slider_gui_input(event: InputEvent) -> void:
	slidescroll(event)


func _on_hbbarsb_pressed() -> void:
	menuClick2_play()
	if Saves.data["bars"] == 0.0:
		bargal.play("no")
		Saves.data["bars"] = 1.0
	else:
		bargal.play("yes")
		Saves.data["bars"] = 0.0

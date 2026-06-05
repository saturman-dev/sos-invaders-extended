extends Node2D

@onready var sprite := $window/vbox/spriteAndNumber/sprite/sprite
@onready var lock := $window/vbox/spriteAndNumber/sprite/lock
@onready var number := $window/vbox/spriteAndNumber/buttons/buttons/text3
@onready var up := $window/vbox/spriteAndNumber/buttons/buttons/UP/up/up
@onready var down := $window/vbox/spriteAndNumber/buttons/buttons/DOWN/down/down
@onready var window := $window
@onready var go := $window/go
@onready var gobutt := $window/go/go
@onready var difftext := $window/go/text2
@onready var backAnim := $window/backAnim
@onready var bg := $bg

var current_number := int(Saves.data["last_selected_neo"])
func _change_number(diff: int):
	#print(Saves.data["greatest_neo_tier"])
	if current_number >= 10 and diff > 0: return
	if current_number <= 0 and diff < 0: return
	current_number += diff
	number.text = "  " + str(current_number) + "  "
	
	if current_number <= 0:
		down.modulate.a = 0.3
	else:
		down.modulate.a = 1.0
	
	if current_number >= 10:
		up.modulate.a = 0.3
	else:
		up.modulate.a = 1.0
	
	if current_number > int(Saves.data["greatest_neo_tier"]):
		number.modulate.a = 0.3
		_set_neo(0)
		sprite.material.set_shader_parameter("flash_brightness", 0.8)
		lock.show()
		difftext.text = "Get to " + str(current_number * 100) + "%
		difficulty first!"
		difftext.add_theme_color_override("font_color", Color("e5ff00").darkened(0.5))
		go.material.set_shader_parameter("flash_brightness", 0.5)
		
	else:
		number.modulate.a = 1.0
		sprite.material.set_shader_parameter("flash_brightness", 0)
		_set_neo(current_number)
		lock.hide()
		difftext.text = "You'll start from 
		" + str(current_number * 100) + "% difficulty."
		difftext.add_theme_color_override("font_color", Color("e5ff00"))
		go.material.set_shader_parameter("flash_brightness", 0)
	

var downdefscale: Vector2
var updefscale: Vector2
func _ready() -> void:
	#Saves.data["greatest_neo_tier"] = 7
	downdefscale = down.scale
	updefscale = up.scale
	current_number = int(Saves.data["last_selected_neo"])
	_change_number(0)
	_start_ready_animation()

func _start_ready_animation():
	bg.show()
	bg.modulate.a = 0
	window.scale.y = 0
	var atw = create_tween()
	atw.tween_property(bg, "modulate:a", 1.0, 0.2)
	atw.parallel().tween_property(window, "scale:y", 1.0, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func _set_neo(NEO: int):
	if NEO > 0:
		sprite.material.set_shader_parameter("enable_outline", true)
		sprite.material.set_shader_parameter("outline_thickness", 1 + NEO)
		sprite.material.set_shader_parameter("gradient_speed", 5 + float(NEO) / 2)
		sprite.material.set_shader_parameter("gradient_color1", Color("ffe600"))
		sprite.material.set_shader_parameter("gradient_color2", Color("ff6600"))
		sprite.material.set_shader_parameter("blend_strength", 0)
		if NEO >= 5:
			sprite.material.set_shader_parameter("blend_strength", float(NEO) / 10)
		if NEO >= 10:
			sprite.material.set_shader_parameter("gradient_color1", Color("ffe600").inverted())
			sprite.material.set_shader_parameter("gradient_color2", Color("ff6600").inverted())
	else:
		sprite.material.set_shader_parameter("enable_outline", false)
		sprite.material.set_shader_parameter("blend_strength", 0)



var dtw: Tween
func _on_down_button_down() -> void:
	if current_number <= 0: return
	if dtw and dtw.is_running(): dtw.kill()
	dtw = create_tween()
	dtw.tween_property(down, "scale", downdefscale * 0.8, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_down_button_up() -> void:
	if current_number <= 0: return
	if dtw and dtw.is_running(): dtw.kill()
	dtw = create_tween()
	dtw.tween_property(down, "scale", downdefscale, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func _on_down_pressed() -> void:
	if current_number > 0: Functions.sfx_play("res://sounds/menuClick2.mp3", 3.0)
	await get_tree().process_frame
	if not is_inside_tree(): return
	_change_number(-1)



var utw: Tween
func _on_up_button_down() -> void:
	if current_number >= 10: return
	if utw and utw.is_running(): utw.kill()
	utw = create_tween()
	utw.tween_property(up, "scale", updefscale * 0.8, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_up_button_up() -> void:
	if current_number >= 10: return
	if utw and utw.is_running(): utw.kill()
	utw = create_tween()
	utw.tween_property(up, "scale", updefscale, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_up_pressed() -> void:
	if current_number < 10: Functions.sfx_play("res://sounds/menuClick2.mp3", 3.0)
	await get_tree().process_frame
	if not is_inside_tree(): return
	_change_number(1)
	



func _on_go_mouse_entered() -> void:
	go.material.set_shader_parameter("enable_outline", true)

func _on_go_mouse_exited() -> void:
	go.material.set_shader_parameter("enable_outline", false)

func _on_go_button_down() -> void:
	go.material.set_shader_parameter("blend_strength", 1)

func _on_go_button_up() -> void:
	go.material.set_shader_parameter("blend_strength", 0)

func _on_go_pressed() -> void:
	if current_number > Saves.data["greatest_neo_tier"]:
		_start_pokachivanie()
		_start_redflash()
		return
	Saves.data["last_selected_neo"] = current_number
	get_parent().get_parent().start()
	bg.hide()
	var stw = create_tween()
	stw.tween_property(self, "position:y", -170, 1.5).as_relative().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	stw.parallel().tween_property(go, "position:y", 170 * 2, 1.5).as_relative().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	Functions.sfx_play("res://sounds/menuClick.mp3", 5.0, 1.0, false, 0.2)



func _start_pokachivanie():
	Functions.sfx_play("res://sounds/menuWrong.mp3")
	gobutt.disabled = true
	var poktw = create_tween()
	poktw.tween_property(self, "position:x", 40, 0.2).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	poktw.chain().tween_property(self, "position:x", -65, 0.3).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	poktw.chain().tween_property(self, "position:x", 50, 0.25).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	poktw.chain().tween_property(self, "position:x", -35, 0.2).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	poktw.chain().tween_property(self, "position:x", 20, 0.15).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	poktw.chain().tween_property(self, "position:x", -15, 0.1).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	poktw.chain().tween_property(self, "position:x", 5, 0.1).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	poktw.tween_callback(func(): gobutt.disabled = false)

func _start_redflash():
	modulate = Color.RED
	go.material.set_shader_parameter("flash_color", Color.RED)
	go.material.set_shader_parameter("flash_brightness", 1.0)
	var rdtw = create_tween()
	rdtw.tween_property(go.material, "shader_parameter/flash_color", Color.BLACK, 0.5)
	rdtw.parallel().tween_property(go.material, "shader_parameter/flash_brightness", 0, 0.5)
	rdtw.parallel().tween_property(self, "modulate", Color.WHITE, 1)



func _on_back_mouse_entered() -> void:
	backAnim.play("hover")

func _on_back_mouse_exited() -> void:
	backAnim.play("unhover")

func _on_back_pressed() -> void:
	back()

func back():
	Functions.sfx_play("res://sounds/menuCancel.mp3")
	bg.hide()
	gobutt.disabled = true
	var stw = create_tween()
	stw.tween_property(self, "position:y", -170, 1.5).as_relative().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	stw.parallel().tween_property(go, "position:y", 170 * 2, 1.5).as_relative().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	stw.tween_callback(queue_free)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): back()

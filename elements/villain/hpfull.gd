extends ColorRect

@export var y_offset = 20
@export var hp_size_coefficient := 0.4
@export var hp_size_exponent := 0.6
@export var hp_height_coefficient := 0.017
@export var hp_height_exponent := 1.5
@export var tween_speed := 0.2

var target_y = y_offset

var x = randf_range(-200.0, 200.0)
var y = -1000.0
var gr = 3000.0

var defaultRedSize: float
var defaultRedHeight: float
var fullRedSize: float
var blackXoffset: float
var blackYoffset: float

signal setted_default

@onready var yellow := $yellow
@onready var red := $red
@onready var waiter := $yellowwaiter

func set_hp(full_hp: float):
	target_y = y_offset
	red.size.x = defaultRedSize * pow(full_hp, hp_size_exponent) * hp_size_coefficient
	red.size.y = defaultRedHeight * (1.0 + pow(full_hp * hp_height_coefficient, hp_height_exponent))
	yellow.size = red.size
	fullRedSize = red.size.x
	size.x = red.size.x + blackXoffset
	size.y = red.size.y + blackYoffset
	
	position.x = -size.x / 2
	#target_y = y_offset + size.y

func _ready() -> void:
	defaultRedHeight = red.size.y
	defaultRedSize = red.size.x
	blackXoffset = size.x - red.size.x
	blackYoffset = size.y - red.size.y
	await get_tree().process_frame
	setted_default.emit()
	
	Events.unpaused.connect(_on_unp)
	if Saves.data["bars"] == 0.0:
		modulate.a = 0.0

func _on_unp():
	if Saves.data["bars"] == 0.0:
		modulate.a = 0.0
	else:
		modulate.a = 1.0

var ended = false
func end():
	if ended: return
	ended = true
	
	var endtween = create_tween()
	endtween.tween_property(self, "scale", Vector2(0, 0), randf_range(1.0, 2.0)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	if yellowTween and yellowTween.is_running():
		yellowTween.kill()
	yellowTween = create_tween()
	yellowTween.tween_property(yellow, "size:x", 0.0, tween_speed * 2)


func _physics_process(delta: float) -> void:
	if get_parent().died == true:
		end()
		y += gr * delta
		position.y += y * delta
		position.x += x * delta
		rotation += x / 10 * delta
	else:
		global_position.y = clampf(get_parent().global_position.y - target_y, 1, 240 - 5)

var yellowTween: Tween
var redTween: Tween

func damage(remaining_hp_relative: float):
	
	if yellowTween and yellowTween.is_running():
		yellowTween.kill()
	if redTween and redTween.is_running():
		redTween.kill()
	
	redTween = create_tween()
	redTween.tween_property(red, "size:x", fullRedSize * remaining_hp_relative, tween_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	waiter.start()



func _on_yellowwaiter_timeout() -> void:
	
	if yellowTween and yellowTween.is_running():
		yellowTween.kill()
	yellowTween = create_tween()
	yellowTween.tween_property(yellow, "size:x", red.size.x, tween_speed * 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

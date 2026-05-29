extends ColorRect

@export var y_offset = 15
var x = randf_range(-200.0, 200.0)
#var y = randf_range(-1000.0, -500.0)
var y = -1000.0
var gr = 2000.0

var bar1PreSize
var bar1NewSize
var fullsize

var oldpos
var oldsize

@onready var hpbar2 = $hp2
@onready var hpbar = $hp

func set_hp(hp: float):
	size.x = hp * 25
	hpbar.size.x = size.x - 8
	hpbar2.size.x = hpbar.size.x
	
	var parpos = get_parent().global_position.x
	
	global_position.x = parpos #- size.x / 2
	#hpbar.global_position.x = parpos - hpbar.size.x / 2
	#hpbar2.global_position.x = parpos - hpbar2.size.x / 2

func _ready() -> void:
	
	oldsize = size.x
	
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

func _physics_process(delta: float) -> void:
	if get_parent().died == true:
		end()
		y += gr * delta
		position.y += y * delta
		position.x += x * delta
		rotation += x / 10 * delta
	else:
		#global_position.y = 1
		global_position.y = clampf(get_parent().global_position.y - y_offset, 1, 240 - 5)

extends ParallaxBackground

var defspeed := 10.0
var speed := 10.0
var hue := 0.0
var huespeed := 0.0

@onready var wallB := $ParallaxLayer2/WallB
@onready var wallB2 := $ParallaxLayer2/WallB2
@onready var wallB3 := $ParallaxLayer2/WallB3
@onready var wallB4 := $ParallaxLayer2/WallB4
@onready var wall1 := $ParallaxLayer2/Wall
@onready var wall2 := $ParallaxLayer2/Wall2
@onready var wall3 := $ParallaxLayer2/Wall3
@onready var wall4 := $ParallaxLayer2/Wall4

var loadOffset = 40
var loadTrans = Tween.TRANS_EXPO
var loadTime = 5.0
func _ready() -> void:
	wall1.material.set_shader_parameter("hue_offset", hue)
	wall2.material.set_shader_parameter("hue_offset", hue)
	wall3.material.set_shader_parameter("hue_offset", hue)
	wall4.material.set_shader_parameter("hue_offset", hue)
	wall1.position.x -= loadOffset
	wall2.position.x -= loadOffset
	wall3.position.x += loadOffset
	wall4.position.x += loadOffset
	var s = create_tween()
	s.tween_property(wall1, "position:x", loadOffset, loadTime).as_relative().set_trans(loadTrans).set_ease(Tween.EASE_OUT)
	s.parallel().tween_property(wall2, "position:x", loadOffset, loadTime).as_relative().set_trans(loadTrans).set_ease(Tween.EASE_OUT)
	s.parallel().tween_property(wall3, "position:x", -loadOffset, loadTime).as_relative().set_trans(loadTrans).set_ease(Tween.EASE_OUT)
	s.parallel().tween_property(wall4, "position:x", -loadOffset, loadTime).as_relative().set_trans(loadTrans).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	if Globals.bgStay == true:
		return
	scroll_base_offset.y += speed * delta
	if Globals.game_running == true:
		speed = defspeed + Globals.diffi
		huespeed = Globals.diffi / 360
		if Globals.diffi > 0:
			hue += huespeed * delta
			wall1.material.set_shader_parameter("hue_offset", hue)
			wall2.material.set_shader_parameter("hue_offset", hue)
			wall3.material.set_shader_parameter("hue_offset", hue)
			wall4.material.set_shader_parameter("hue_offset", hue)

var bgblacktween: Tween
func flseye_animation():
	if bgblacktween and bgblacktween.is_running():
		bgblacktween.kill()
	
	bgblacktween = create_tween()
	bgblacktween.tween_property(wallB, "modulate:a", 1.0, 2.0)
	bgblacktween.parallel().tween_property(wallB2, "modulate:a", 1.0, 2.0)
	bgblacktween.parallel().tween_property(wallB3, "modulate:a", 1.0, 2.0)
	bgblacktween.parallel().tween_property(wallB4, "modulate:a", 1.0, 2.0)
	await bgblacktween.finished

func flseye_animation_finished():
	wallB.modulate.a = 0.0
	wallB2.modulate.a = 0.0
	wallB3.modulate.a = 0.0
	wallB4.modulate.a = 0.0

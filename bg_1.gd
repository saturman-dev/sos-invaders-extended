extends ParallaxBackground

@onready var sprite := $ParallaxLayer/Bg
@onready var black := $ParallaxLayer2/ColorRect

@onready var wall1 := $ParallaxLayer2/Wall
@onready var wall2 := $ParallaxLayer2/Wall2
@onready var wall3 := $ParallaxLayer2/Wall3
@onready var wall4 := $ParallaxLayer2/Wall4

var defspeed := 10.0
var speed := 10.0
var hue := 0.0
var huespeed := 0.0

var loadOffset = 30
var loadTrans = Tween.TRANS_EXPO
var loadTime = 7.5
func _ready() -> void:
	sprite.material.set_shader_parameter("hue_offset", hue)
	wall1.material.set_shader_parameter("hue_offset", hue)
	wall3.material.set_shader_parameter("hue_offset", hue)
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
			sprite.material.set_shader_parameter("hue_offset", hue)
			wall1.material.set_shader_parameter("hue_offset", hue)
			wall3.material.set_shader_parameter("hue_offset", hue)

var fgblacktween: Tween
func flseye_animation():
	if fgblacktween and fgblacktween.is_running():
		fgblacktween.kill()
	
	fgblacktween = create_tween()
	fgblacktween.tween_property(black, "modulate:a", 1.0, 2.0)
	await fgblacktween.finished

func flseye_animation_finished():
	black.modulate.a = 0.0

extends ParallaxBackground

@onready var sprite := $ParallaxLayer/Bg
@onready var black := $ParallaxLayer2/ColorRect

var defspeed := 10.0
var speed := 10.0
var hue := 0.0
var huespeed := 0.0

func _ready() -> void:
	Events.bossfight_start.connect(func(type): spawn_boss_flseye())
	sprite.material.set_shader_parameter("hue_offset", hue)

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
			$ParallaxLayer2/Wall.material.set_shader_parameter("hue_offset", hue)
			$ParallaxLayer2/Wall3.material.set_shader_parameter("hue_offset", hue)

func spawn_boss_flseye():
	var btween := create_tween()
	btween.tween_property(black, "modulate:a", 1.0, 2.0)
	await Events.boss_animation_finished
	black.modulate.a = 0.0

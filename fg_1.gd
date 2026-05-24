extends ParallaxBackground

var defspeed := 10.0
var speed := 10.0
var hue := 0.0
var huespeed := 0.0

@onready var wallB := $ParallaxLayer2/WallB
@onready var wallB2 := $ParallaxLayer2/WallB2
@onready var wallB3 := $ParallaxLayer2/WallB3
@onready var wallB4 := $ParallaxLayer2/WallB4

func _ready() -> void:
	Events.bossfight_start.connect(func(type): spawn_boss_flseye())

func _process(delta: float) -> void:
	if Globals.bgStay == true:
		return
	scroll_base_offset.y += speed * delta
	if Globals.game_running == true:
		speed = defspeed + Globals.diffi
		huespeed = Globals.diffi / 360
		if Globals.diffi > 0:
			hue += huespeed * delta
			$ParallaxLayer2/Wall.material.set_shader_parameter("hue_offset", hue)
			$ParallaxLayer2/Wall2.material.set_shader_parameter("hue_offset", hue)
			$ParallaxLayer2/Wall3.material.set_shader_parameter("hue_offset", hue)
			$ParallaxLayer2/Wall4.material.set_shader_parameter("hue_offset", hue)

func spawn_boss_flseye():
	var t = create_tween()
	t.tween_property(wallB, "modulate:a", 1.0, 2.0)
	t.parallel().tween_property(wallB2, "modulate:a", 1.0, 2.0)
	t.parallel().tween_property(wallB3, "modulate:a", 1.0, 2.0)
	t.parallel().tween_property(wallB4, "modulate:a", 1.0, 2.0)
	await Events.boss_animation_finished
	wallB.modulate.a = 0.0
	wallB2.modulate.a = 0.0
	wallB3.modulate.a = 0.0
	wallB4.modulate.a = 0.0

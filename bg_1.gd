extends ParallaxBackground

@onready var sprite = $ParallaxLayer/Bg

var defspeed := 10.0
var speed := 10.0
var hue := 0.0
var huespeed := 0.0

func _ready() -> void:
	sprite.material.set_shader_parameter("hue_offset", hue)

func _process(delta: float) -> void:
	scroll_base_offset.y += speed * delta
	if Globals.game_running == true:
		speed = defspeed + Globals.diffi
		huespeed = Globals.diffi / 360
		if Globals.diffi > 0:
			hue += huespeed * delta
			sprite.material.set_shader_parameter("hue_offset", hue)

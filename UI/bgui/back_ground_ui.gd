extends ParallaxBackground

@onready var bossbarcontainer := $bossBars
const bossbar = preload("res://UI/bosshpbar/bosshpbar.tscn")

func _ready() -> void:
	Events.bossfight_start.connect(func(type): add_hpbar(type))

func add_hpbar(type: String):
	await Events.boss_animation_finished
	var Bossbar = bossbar.instantiate()
	bossbarcontainer.add_child(Bossbar)
	Bossbar.label.text = type.to_upper()

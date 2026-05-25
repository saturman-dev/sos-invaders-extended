extends ColorRect

@onready var s = $stamina

var target_size: float = 20.0
var full_color := Color("59a5ff")
var charging_color := Color("2c4d75")
var bg_color := Color("001a39")

var dryn = false

func _ready() -> void:
	size.x = target_size
	s.size.x = 0

func set_fill(amount: float):
	s.size.x = amount * target_size
	
	if amount >= 1.0:
		s.color = full_color
		color = bg_color
		if dryn == false:
			dryn = true
			Functions.sfx_play("res://sounds/staminaCharge.mp3", 7.0, 0.8 + Globals.currentStaminas/10)
	else:
		s.color = charging_color
		dryn = false

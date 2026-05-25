extends AnimatedSprite2D

@onready var title := $title
@onready var now := $nowPlaying

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if frame == 0:
		title.color = Color("ffdd00")
		

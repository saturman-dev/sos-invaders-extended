extends Control

@onready var nameText := $vbox/name/text
@onready var nameText2 := $text2
@onready var icon := $vbox/name/icon/icon

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	
	if modulate.a <= 0: return
	
	nameText2.text = nameText.text
	nameText2.global_position = Vector2(nameText.global_position.x, nameText.global_position.y + 1)

	if icon.frame == 0:
		nameText.add_theme_color_override("font_color", Color("ffe74e"))
		nameText2.add_theme_color_override("font_color", Color("0628ff"))
	
	if icon.frame == 1 or icon.frame == 5:
		nameText.add_theme_color_override("font_color", Color("ffe334"))
		nameText2.add_theme_color_override("font_color", Color("203fff"))
	
	if icon.frame == 2 or icon.frame == 4:
		nameText.add_theme_color_override("font_color", Color("ffe01b"))
		nameText2.add_theme_color_override("font_color", Color("3954ff"))
		
	if icon.frame == 3:
		nameText.add_theme_color_override("font_color", Color("ffdd01"))
		nameText2.add_theme_color_override("font_color", Color("536aff"))

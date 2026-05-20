extends CanvasLayer

var score = Saves.data["score"]
var ptsize = 1.5
var pton = 0.1
var ptoff = 0.3

@onready var highest := $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/highest
@onready var pts1 := $MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var pts2 := $Label2
@onready var multi1 := $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/multiplyer
@onready var multi2 := $multiplyer2
@onready var bonuses := $activeBonuses

var ATween: Tween
var BTween: Tween

func _ready() -> void:
	Events.points_changed.connect(update_points)
	if score > 0:
		highest.text = str("/ ", int(score))
	else:
		highest.queue_free()

func align_position():
	multi2.global_position = multi1.global_position

func align_ptsPosition():
	pts2.global_position = pts1.global_position

func update_points(points: int):
	align_ptsPosition()
	pts1.modulate.a = 0.0
	pts1.text = str(points)
	Globals.pts = points
	pts2.text = pts1.text
	pts2.pivot_offset = pts2.size / 2
	pts2.modulate = Color.YELLOW
	ATween = create_tween().set_parallel(true)
	ATween.tween_property(pts2, "scale", Vector2(ptsize, ptsize), pton)
	await ATween.finished
	BTween = create_tween().set_parallel(true)
	BTween.tween_property(pts2, "modulate", Color.WHITE, pton + ptoff)
	ATween = create_tween().set_parallel(true)
	ATween.tween_property(pts2, "scale", Vector2(1.0, 1.0), ptoff)
	await ATween.finished

var multiplyer := 1.0
func _process(delta: float) -> void:
	pass
	#multiplyer += delta / 5
	#update_multi(multiplyer)

func update_multi(multi: float):
	multi1.text = "x%.2f" % multi
	multi2.text = multi1.text
	if multi >= 2.0:
		multi2.scale = Vector2(1.2, 1.2)
		multi2.add_theme_color_override("font_color", Color.ORANGE)
		if multi >= 3.0:
			multi2.scale = Vector2(1.5, 1.5)
			multi2.add_theme_color_override("font_color", Color.RED)
	align_position()

const trioUI = preload("res://elements/bonuses/trio/trioUI.tscn")
const speedUI = preload("res://elements/bonuses/speed/speedUI.tscn")
const splashUI = preload("res://elements/bonuses/splash/splashUI.tscn")

func addBonus(bonus_type: String):
	if bonus_type == "trio":
		var TrioUI = trioUI.instantiate()
		bonuses.add_child(TrioUI)
	if bonus_type == "speed":
		var SpeedUI = speedUI.instantiate()
		bonuses.add_child(SpeedUI)
	if bonus_type == "splash":
		var SplashUI = splashUI.instantiate()
		bonuses.add_child(SplashUI)

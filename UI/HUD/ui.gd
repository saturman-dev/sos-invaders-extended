extends CanvasLayer

var score = Saves.data["score"]
var ptsize = 1.5
var pton = 0.05
var ptoff = 0.2

@onready var scoreV := $scoreV
@onready var highest := $scoreV/scoreH/scorePanel/scoreHH/highscore
@onready var pts1 := $scoreV/scoreH/scorePanel/scoreHH/score
@onready var pts2 := $Label2
@onready var multi1 := $scoreV/scoreH/multiV/multiplyer
@onready var multi2 := $multiplyer2
@onready var bonuses := $everythingButTime/thewholedown/staminaHpBonuses/bonusesH/bonusesV
@onready var diffLabel = $VBoxContainer3/HBoxContainer/diffLabel
@onready var ptBonuses := $scoreV/ptBonuses

var ATween: Tween

func _ready() -> void:
	Events.points_added.connect(func(diff): update_points(diff))
	if score > 0:
		highest.text = str("/ ", int(score))
	else:
		highest.queue_free()
	ready_animation()

var scoreVoffsetx = 30
var scoreVoffsety = 20
func ready_animation():
	scoreV.position.y += scoreVoffsety
	scoreV.position.x -= scoreVoffsetx
	var scoreTween = create_tween()
	scoreTween.tween_property(scoreV, "position", Vector2(scoreVoffsetx, -scoreVoffsety), 3.0).as_relative().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(2.0, false).timeout
	if not is_inside_tree(): return
	Globals.paused = false
	#Globals.change_points(528374)

func align_position():
	multi2.global_position = multi1.global_position

func align_ptsPosition():
	pts2.global_position = pts1.global_position

func update_points(points: int):
	if ATween and ATween.is_running():
		ATween.kill()
	
	pts2.scale = Vector2.ONE
	
	pts1.text = str(Globals.points)
	pts2.text = pts1.text
	
	pts2.reset_size()
	pts2.pivot_offset = pts2.size / 2
	
	align_ptsPosition()
	
	pts1.modulate.a = 0.0
	Globals.pts = points
	pts2.modulate = Color("f61900")
	
	ATween = create_tween()
	
	if points >= 50:
		ATween.tween_property(pts2, "scale", Vector2(ptsize * 2, ptsize * 2), pton * 4)
		ATween.chain().tween_property(pts2, "scale", Vector2.ONE, ptoff * 4)
		ATween.parallel().tween_property(pts2, "modulate", Color.WHITE, (pton + ptoff) * 2)
	else:
		ATween.tween_property(pts2, "scale", Vector2(ptsize, ptsize), pton)
		ATween.chain().tween_property(pts2, "scale", Vector2.ONE, ptoff)
		ATween.parallel().tween_property(pts2, "modulate", Color.WHITE, pton + ptoff)

var multiOffset := Vector2.ZERO
var multiShakeStr := 1.25
var diffsec = 0.01
var multiplyer := 1.0
func _process(delta: float) -> void:
	pass
	if Globals.diffi > diffsec:
		diffLabel.text = str("Difficulty: ", str(round(diffsec * 100) / 100))
		diffsec += 0.01
	multi2.text = Functions.floor_to(Globals.pointMultiplyer) + "x"
	multi2.global_position.x = multi1.global_position.x + multiOffset.x
	multi2.global_position.y = multi1.global_position.y + (multi1.size.y - (multi2.scale.y * multi1.size.y)) / 2.0 + multiOffset.y
	if Globals.pointMultiplyer == 1.0:
		multiOffset = Vector2.ZERO
		multi2.scale = Vector2(0.75, 0.75)
		multi2.add_theme_color_override("font_color", Color.WEB_GRAY)
	elif Globals.pointMultiplyer < 2.0:
		multiOffset = Vector2.ZERO
		multi2.scale = Vector2(1, 1)
		multi2.add_theme_color_override("font_color", Color.WHITE)
	elif Globals.pointMultiplyer < 3.0:
		multiOffset = Vector2.ZERO
		multi2.scale = Vector2(1.35, 1.35)
		multi2.add_theme_color_override("font_color", Color.ORANGE)
	elif Globals.pointMultiplyer >= 3.0:
		multi2.scale = Vector2(1.7, 1.7)
		multi2.add_theme_color_override("font_color", Color.RED)
		multiOffset.x = randf_range(-multiShakeStr * 5, multiShakeStr * 5)
		multiOffset.y = randf_range(-multiShakeStr, multiShakeStr)
	
	$killsDebug.text = str(Globals.kills)



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

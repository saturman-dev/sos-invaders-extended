extends Node2D

var able = false

var noEnemyInfoText := "[color=7f7f7f]?????[/color]"
@onready var backButton := $CanvasLayer2/backAnim
@onready var specialText := $CanvasLayer2/specialNote/specialNoteText
@onready var special := $CanvasLayer2/specialNote
@onready var bonusesButton := $CanvasLayer2/bonuses
@onready var bonusesAct := $CanvasLayer2/bonusesActive
@onready var enemiesButton := $CanvasLayer2/enemies
@onready var enemiesAct := $CanvasLayer2/enemiesActive
@onready var enemiesScroll := $CanvasLayer2/ScrollContainer
@onready var bonusesScroll := $CanvasLayer2/ScrollContainer2
@onready var bonusesHover := $CanvasLayer2/bonuses/bonusesHover
@onready var enemiesHover := $CanvasLayer2/enemies/enemiesHover
var bgNoEnemyColor := Color("#7f7f7f")
var noSpecial := "No special note"
var yesSpecial := "See special note"



var darsinInfoText := "[color=ffc472]Darsin:[/color]   Spawns in groups of 2-4 darsins. Teleports a bit down after hitting a wall. Shoots slow tiny bullets."
var darsinNoText := "[color=ffc472]?????[/color]"

var bigdarInfoText := "[color=18ff3b]BigDar:[/color]   Fires a bomb that leaves a damaging area briefly after detonating. Has a lot of HP, but his own bomb can instantly kill him."
var bigdarNoText := "[color=18ff3b]?????[/color]"
var bigdarSpecialNote := "[color=18ff3b]Shoot the bomb to instantly detonate it! This can be used to defeat groups of enemies.[/color]"

var a3InfoText := "[color=fb00cf]A3:[/color]   Shoots 3 bullets and has a lot of HP. There's a really small chance to defeat it before it shoots, because the first shot cooldown is set to 1 second."
var a3NoText := "[color=fb00cf]?????[/color]"

var wertueInfoText := "[color=00ffdc]Wertue:[/color]   Creates a beam of light that follows the player. The beam stops after a few seconds and activates for a moment, dealing damage. After 3 failed attacks it becomes enraged, doubling its attack speed."
var wertueNoText := "[color=00ffdc]?????[/color]"
var wertueSpecialNote := "[color=00ffdc]If you kill Wertue right before the beam activates, it will attack significantly harder, damaging enemies.[/color]"



var healLockedText := "[color=00ff22]???[/color]   [color=7f7f7f]Defeat any enemy after taking damage to get this bonus.[/color]"
var healInfoText := "[color=00ff22]Heal:[/color]   Heals 1 HP. Maximum amount is 3."

var overhealLockedText := "[color=ffff00]???[/color]   [color=7f7f7f]Defeat " + str(int(Saves.data["killed_enemies"])) + "/" + str(Globals.needForOverheal) + " enemies to get this bonus.[/color]"
var overhealInfoText := "[color=ffff00]Overheal:[/color]   Gives you additional 1 HP. Maximum amount of additional HP is 3."

var splashLockedText := "[color=ff0009]???[/color]   [color=7f7f7f]Defeat ????? with his own bomb to get this bonus.[/color]"
var splashUnlockedText := "[color=ff0009]???[/color]   [color=7f7f7f]Defeat BigDar with his own bomb to get this bonus.[/color]"
var splashInfoText := "[color=ff0009]Splash:[/color]   Allows your bullets pass through enemies."

var trioLockedText := "[color=ff00dd]???[/color]   [color=7f7f7f]Defeat ????? to get this bonus.[/color]"
var trioUnlockedText := "[color=ff00dd]???[/color]   [color=7f7f7f]Defeat A3 to get this bonus.[/color]"
var trioInfoText := "[color=ff00dd]Trio:[/color]   Allows you shoot 3 bullets instead of 1. additional bullets take 0.75x damage."

var speedLockedText := "[color=00fff6]???[/color]   [color=7f7f7f]Defeat ????? to get this bonus.[/color]"
var speedUnlockedText := "[color=00fff6]???[/color]   [color=7f7f7f]Defeat Wertue to get this bonus.[/color]"
var speedInfoText := "[color=00fff6]Speed:[/color]   Significantly increases your movement and attack speed."



@onready var darsinInfo := $CanvasLayer2/ScrollContainer/VBoxContainer/darsin/info/text
@onready var darsinSpecialButton := $CanvasLayer2/ScrollContainer/VBoxContainer/darsin/info/specialNote/darsin
@onready var darsinIcon := $CanvasLayer2/ScrollContainer/VBoxContainer/darsin/icon/enemy
@onready var darsinLock := $CanvasLayer2/ScrollContainer/VBoxContainer/darsin/icon/lock
@onready var darsinBg := $CanvasLayer2/ScrollContainer/VBoxContainer/darsin/icon/bg
@onready var darsinCount := $CanvasLayer2/ScrollContainer/VBoxContainer/darsin/icon/count

@onready var bigdarInfo := $CanvasLayer2/ScrollContainer/VBoxContainer/bigdar/info/text
@onready var bigdarSpecialButton := $CanvasLayer2/ScrollContainer/VBoxContainer/bigdar/info/specialNote/bigdar
@onready var bigdarIcon := $CanvasLayer2/ScrollContainer/VBoxContainer/bigdar/icon/enemy
@onready var bigdarLock := $CanvasLayer2/ScrollContainer/VBoxContainer/bigdar/icon/lock
@onready var bigdarBg := $CanvasLayer2/ScrollContainer/VBoxContainer/bigdar/icon/bg
@onready var bigdarCount := $CanvasLayer2/ScrollContainer/VBoxContainer/bigdar/icon/count

@onready var a3Info := $CanvasLayer2/ScrollContainer/VBoxContainer/a3/info/text
@onready var a3SpecialButton := $CanvasLayer2/ScrollContainer/VBoxContainer/a3/info/specialNote/a3
@onready var a3Icon := $CanvasLayer2/ScrollContainer/VBoxContainer/a3/icon/enemy
@onready var a3Lock := $CanvasLayer2/ScrollContainer/VBoxContainer/a3/icon/lock
@onready var a3Bg := $CanvasLayer2/ScrollContainer/VBoxContainer/a3/icon/bg
@onready var a3Count := $CanvasLayer2/ScrollContainer/VBoxContainer/a3/icon/count

@onready var wertueInfo := $CanvasLayer2/ScrollContainer/VBoxContainer/wertue/info/text
@onready var wertueSpecialButton := $CanvasLayer2/ScrollContainer/VBoxContainer/wertue/info/specialNote/wertue
@onready var wertueIcon := $CanvasLayer2/ScrollContainer/VBoxContainer/wertue/icon/enemy
@onready var wertueLock := $CanvasLayer2/ScrollContainer/VBoxContainer/wertue/icon/lock
@onready var wertueBg := $CanvasLayer2/ScrollContainer/VBoxContainer/wertue/icon/bg
@onready var wertueCount := $CanvasLayer2/ScrollContainer/VBoxContainer/wertue/icon/count
@onready var wertueLeftWing := $CanvasLayer2/ScrollContainer/VBoxContainer/wertue/icon/enemy/wingLeft



@onready var healInfo := $CanvasLayer2/ScrollContainer2/VBoxContainer/heal/info/text
@onready var healIcon := $CanvasLayer2/ScrollContainer2/VBoxContainer/heal/icon/bonus
@onready var healLock := $CanvasLayer2/ScrollContainer2/VBoxContainer/heal/icon/lock
@onready var healCount := $CanvasLayer2/ScrollContainer2/VBoxContainer/heal/icon/count

@onready var overhealInfo := $CanvasLayer2/ScrollContainer2/VBoxContainer/overheal/info/text
@onready var overhealIcon := $CanvasLayer2/ScrollContainer2/VBoxContainer/overheal/icon/bonus
@onready var overhealLock := $CanvasLayer2/ScrollContainer2/VBoxContainer/overheal/icon/lock
@onready var overhealCount := $CanvasLayer2/ScrollContainer2/VBoxContainer/overheal/icon/count

@onready var splashInfo := $CanvasLayer2/ScrollContainer2/VBoxContainer/splash/info/text
@onready var splashIcon := $CanvasLayer2/ScrollContainer2/VBoxContainer/splash/icon/bonus
@onready var splashLock := $CanvasLayer2/ScrollContainer2/VBoxContainer/splash/icon/lock
@onready var splashCount := $CanvasLayer2/ScrollContainer2/VBoxContainer/splash/icon/count

@onready var trioInfo := $CanvasLayer2/ScrollContainer2/VBoxContainer/trio/info/text
@onready var trioIcon := $CanvasLayer2/ScrollContainer2/VBoxContainer/trio/icon/bonus
@onready var trioLock := $CanvasLayer2/ScrollContainer2/VBoxContainer/trio/icon/lock
@onready var trioCount := $CanvasLayer2/ScrollContainer2/VBoxContainer/trio/icon/count

@onready var speedInfo := $CanvasLayer2/ScrollContainer2/VBoxContainer/speed/info/text
@onready var speedIcon := $CanvasLayer2/ScrollContainer2/VBoxContainer/speed/icon/bonus
@onready var speedLock := $CanvasLayer2/ScrollContainer2/VBoxContainer/speed/icon/lock
@onready var speedCount := $CanvasLayer2/ScrollContainer2/VBoxContainer/speed/icon/count



func _on_back_mouse_entered() -> void:
	backButton.play("hover")

func _on_back_mouse_exited() -> void:
	backButton.play("unhover")

func _on_back_pressed() -> void:
	menuClick_play()
	back()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		back()
	if event.is_action_pressed("ui_right"):
		turnToBonuses()
	if event.is_action_pressed("ui_left"):
		turnToEnemies()

func back():
	if able == false:
		return
	get_parent().back(-1)

func menuClick_play():
	Functions.sfx_play("res://sounds/menuClick.mp3")



func _ready() -> void:
	darsinCount.text = str(int(Saves.data["killed_darsins"]))
	bigdarCount.text = str(int(Saves.data["killed_bigdars"]))
	a3Count.text = str(int(Saves.data["killed_a3s"]))
	wertueCount.text = str(int(Saves.data["killed_wertues"]))
	healCount.text = str(int(Saves.data["gotten_heals"]))
	overhealCount.text = str(int(Saves.data["gotten_overheals"]))
	splashCount.text = str(int(Saves.data["gotten_splashes"]))
	trioCount.text = str(int(Saves.data["gotten_trios"]))
	speedCount.text = str(int(Saves.data["gotten_speeds"]))
	if Saves.data["ever_met_darsin"] == true:
		darsinInfo.text = darsinInfoText
		darsinSpecialButton.text = noSpecial
	else:
		darsinCount.visible = false
		darsinInfo.text = darsinNoText
		darsinSpecialButton.queue_free()
		darsinBg.modulate = bgNoEnemyColor
		darsinLock.visible = true
		darsinIcon.visible = false
	if Saves.data["ever_met_bigdar"] == true:
		splashLockedText = splashUnlockedText
		bigdarInfo.text = bigdarInfoText
		bigdarSpecialButton.text = yesSpecial
		bigdarSpecialButton.add_theme_color_override("font_color", Color("18ff3b"))
	else:
		bigdarCount.visible = false
		bigdarInfo.text = bigdarNoText
		bigdarSpecialButton.queue_free()
		bigdarBg.modulate = bgNoEnemyColor
		bigdarLock.visible = true
		bigdarIcon.visible = false
	if Saves.data["ever_met_a3"] == true:
		trioLockedText = trioUnlockedText
		a3Info.text = a3InfoText
		a3SpecialButton.text = noSpecial
	else:
		a3Count.visible = false
		a3Info.text = a3NoText
		a3SpecialButton.queue_free()
		a3Bg.modulate = bgNoEnemyColor
		a3Lock.visible = true
		a3Icon.visible = false
	if Saves.data["ever_met_wertue"] == true:
		speedLockedText = speedUnlockedText
		wertueLeftWing.left()
		wertueInfo.text = wertueInfoText
		wertueSpecialButton.text = yesSpecial
		wertueSpecialButton.add_theme_color_override("font_color", Color("00ffdc"))
	else:
		wertueCount.visible = false
		wertueInfo.text = wertueNoText
		wertueSpecialButton.queue_free()
		wertueBg.modulate = bgNoEnemyColor
		wertueLock.visible = true
		wertueIcon.visible = false
	if Saves.data["ever_got_heal_bonus"] == true:
		healInfo.text = healInfoText
	else:
		healCount.visible = false
		healInfo.text = healLockedText
		healLock.visible = true
		healIcon.visible = false
	if Saves.data["ever_got_overheal_bonus"] == true:
		overhealInfo.text = overhealInfoText
	else:
		overhealCount.visible = false
		overhealInfo.text = overhealLockedText
		overhealLock.visible = true
		overhealIcon.visible = false
	if Saves.data["ever_got_splash_bonus"] == true:
		splashInfo.text = splashInfoText
	else:
		splashCount.visible = false
		splashInfo.text = splashLockedText
		splashLock.visible = true
		splashIcon.visible = false
	if Saves.data["ever_got_trio_bonus"] == true:
		trioInfo.text = trioInfoText
	else:
		trioCount.visible = false
		trioInfo.text = trioLockedText
		trioLock.visible = true
		trioIcon.visible = false
	if Saves.data["ever_got_speed_bonus"] == true:
		speedInfo.text = speedInfoText
	else:
		speedCount.visible = false
		speedInfo.text = speedLockedText
		speedLock.visible = true
		speedIcon.visible = false



func _on_bigdar_mouse_entered() -> void:
	specialText.text = bigdarSpecialNote
	special.visible = true

func _on_bigdar_mouse_exited() -> void:
	special.visible = false



func _on_wertue_mouse_entered() -> void:
	specialText.text = wertueSpecialNote
	special.visible = true

func _on_wertue_mouse_exited() -> void:
	special.visible = false

func _on_enemies_pressed() -> void:
	turnToEnemies()

func _on_bonuses_pressed() -> void:
	turnToBonuses()

func turnToEnemies():
	Functions.sfx_play("res://sounds/menuClick.mp3")
	enemiesAct.visible = true
	enemiesButton.disabled = true
	bonusesAct.visible = false
	bonusesButton.disabled = false
	bonusesScroll.visible = false
	enemiesScroll.visible = true

func turnToBonuses():
	Functions.sfx_play("res://sounds/menuClick.mp3")
	enemiesAct.visible = false
	enemiesButton.disabled = false
	bonusesAct.visible = true
	bonusesButton.disabled = true
	bonusesScroll.visible = true
	enemiesScroll.visible = false

func _on_enemies_mouse_entered() -> void:
	enemiesHover.visible = true

func _on_enemies_mouse_exited() -> void:
	enemiesHover.visible = false


func _on_bonuses_mouse_entered() -> void:
	bonusesHover.visible = true

func _on_bonuses_mouse_exited() -> void:
	bonusesHover.visible = false

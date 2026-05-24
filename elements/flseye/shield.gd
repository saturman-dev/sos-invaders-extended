extends CharacterBody2D

var color = Color("9646ff")

# FOR DAMAGE
var fullhp = 20.0
var hp = fullhp
var yellwait = 0.7
@onready var timer := $dmgstop
@onready var sprite := $AnimatedSprite2D
var dmgColor = Color.RED
@onready var hpbar := $hpfull/hp
var bar1 = 0.2
var fullsize = 0.0
var undam = 0.3

var died = false
var bar2 = 0.4
var afterdead = 1.0

@onready var hpbar1 := $hpfull
@onready var hpbar2 := $hpfull/hp2
@onready var cldown := $cldown
@onready var hitbox := $CollisionShape2D

var enabled = true

func _process(delta: float) -> void:
	sprite.rotation_degrees -= 120 * delta

func damageAnimation():
	sprite.stop()
	sprite.play("dmg")

func _ready() -> void:
	Events.flseye_shield_made.emit()
	var defscale = scale
	scale = Vector2.ZERO
	ATween = create_tween()
	ATween.tween_property(self, "scale", defscale, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var bar1PreSize = hpbar1.size.x
	hpbar.size.x *= fullhp / 3.5
	hpbar1.size.x = hpbar.size.x + 8.0
	var bar1NewSize = hpbar1.size.x
	hpbar1.position.x -= (bar1NewSize - bar1PreSize) / 2
	hpbar2.size.x = hpbar.size.x
	fullsize = hpbar.size.x

@onready var dmgcldown := $dmgCldown
func periodic_dmg(dmg: float):
	if dmgcldown.time_left <= 0:
		Functions.dmg(self, dmg)
		dmgcldown.wait_time = 1.0
		dmgcldown.start()

@onready var dmgcldown2 := $dmgCldown2
func beam_dmg(dmg: float):
	if dmgcldown2.time_left <= 0:
		Functions.dmg(self, dmg)
		dmgcldown2.wait_time = 0.5
		dmgcldown2.start()

var fadetime = 0.8
func die():
	remove_from_group("enemies")
	Functions.big_enemy_explosion(self)
	Functions.sfx_play("res://sounds/ENRAGE.mp3", 0.0, randf_range(1.05, 1.15))
	if not hitbox:
		return
	Events.flseye_shield_broken.emit()
	Functions.addRandomBonus(self, 3.0)
	#Functions.sfx_play("res://sounds/wertueDead.mp3")
	died = true
	hitbox.queue_free()
	ATween = create_tween()
	ATween.tween_property(sprite, "modulate:a", 0.0, fadetime)
	BTween = create_tween()
	BTween.tween_property(sprite, "scale", Vector2(3.0, 3.0), fadetime).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	CTween = create_tween()
	CTween.tween_property(hpbar, "size:x", (fullsize / fullhp) * hp, bar1 * 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	ETween = create_tween()
	ETween.tween_property(hpbar2, "size:x", (fullsize / fullhp) * hp, bar2 * 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await ATween.finished
	queue_free()


var ATween: Tween
var BTween: Tween
var CTween: Tween
var DTween: Tween
var ETween: Tween
var FTween: Tween

func _on_dmgstop_timeout() -> void:
	ETween = create_tween()
	ETween.tween_property(hpbar2, "size:x", (fullsize / fullhp) * hp, bar2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

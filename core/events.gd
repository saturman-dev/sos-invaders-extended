extends Node


signal points_changed(points: int)
signal points_added(diff: int)
signal lives_changed(lives: int)
signal deflives_changed(lives: int)
signal overlives_changed(lives: int)
signal unpaused()
signal notification_finished()
signal bossfight_start(type: String)
signal bossfight_end()
signal boss_damaged(health_percent: float)
signal boss_animation_finished()
signal flseye_shield_broken()
signal flseye_shield_made()

extends Node

const SAVE_PATH = "user://save.json"

var data = {
	"score": 0,
	"v_all": 50.0,
	"v_sfx": 50.0,
	"v_mus": 25.0,
	"ct": 3,
	"bars": 1,
	"killed_enemies": 0,
	"educated": false,
	"ever_got_trio_bonus": false,
	"ever_got_speed_bonus": false,
	"ever_got_splash_bonus": false,
	"ever_got_heal_bonus": false,
	"ever_got_overheal_bonus": false,
	"ever_met_darsin": false,
	"ever_met_bigdar": false,
	"ever_met_a3": false,
	"ever_met_wertue": false,
	"ever_met_flseye": false,
	"killed_darsins": 0,
	"killed_bigdars": 0,
	"killed_a3s": 0,
	"killed_wertues": 0,
	"killed_flseyes": 0,
	"gotten_heals": 0,
	"gotten_overheals": 0,
	"gotten_splashes": 0,
	"gotten_trios": 0,
	"gotten_speeds": 0
}

var is_loading = true

func _ready():
	sload()
	get_tree().set_auto_accept_quit(false)

func save():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("saveError: no file found")
	else:
		var json_string = JSON.stringify(data)
		file.store_line(json_string)
		file.close()
		print("Saved!")

func sload():
	if not FileAccess.file_exists(SAVE_PATH):
		is_loading = false
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		print("loadError: no file found")
	else:
		var json_string = file.get_line()
		file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var loaded_data = json.get_data()
			if loaded_data is Dictionary:
				data.merge(loaded_data, true)
				print("МАТЕМАТИЧЕСКИ ТОЧНЫЙ КЛИК-СИНК")
			else:
				print("no")
		print("Save loaded!")
		is_loading = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Saving...")
		save()
		get_tree().quit()

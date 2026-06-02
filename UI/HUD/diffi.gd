extends Label

func _process(delta: float) -> void:
	text = Functions.floor_to(Globals.diffi / get_tree().get_first_node_in_group("level").NEO_GAP * 100) + "%"

extends VBoxContainer

@export var max_bonuses := 5
@export var custom_font: Font
@export var font_size := 18

func add(text: String):
	if get_child_count() >= max_bonuses:
		get_child(0).queue_free()
	
	var item_wrapper = Control.new()
	item_wrapper.custom_minimum_size.y = font_size
	add_child(item_wrapper)
	
	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.text = text
	label.fit_content = true
	label.scroll_active = false
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.custom_minimum_size.x = 500
	
	if custom_font:
		label.add_theme_font_override("normal_font", custom_font)
	label.add_theme_font_size_override("normal_font_size", font_size)
	
	item_wrapper.add_child(label)
	
	label.modulate.a = 0.0
	label.position.x = 40.0
	
	var t = create_tween()
	t.parallel().tween_property(label, "modulate:a", 1.0, 0.12).set_trans(Tween.TRANS_CUBIC)
	t.parallel().tween_property(label, "position:x", 0.0, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_interval(3.0)
	t.tween_property(item_wrapper, "modulate:a", 0.0, 0.2)
	t.tween_callback(item_wrapper.queue_free)

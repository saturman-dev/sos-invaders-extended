extends Control

@export_category("Настройки текста")
@export var text: String = "[color=#ffffff33]MAX POINTS: [/color][color=yellow]9999[/color]  •  " : set = _set_text
@export var speed: float = 100.0
@export var target_width: float = 3500.0

@onready var label1: RichTextLabel = $TemplateLabel

var label2: RichTextLabel
var label_width: float

func _ready() -> void:
	if text.is_empty():
		return
	
	label1.bbcode_enabled = true
	label1.autowrap_mode = TextServer.AUTOWRAP_OFF
	
	# 1. Задаем ОДИН базовый кусочек текста
	label1.text = text
	
	# Измеряем ширину ровно ОДНОГО кусочка (это происходит мгновенно)
	var chunk_width = label1.get_content_width()
	
	# Защита от деления на ноль, если текст оказался пустым
	if chunk_width <= 0:
		return
	
	# 2. МАТЕМАТИКА: Считаем, сколько раз нужно повторить кусок, чтобы перекрыть target_width
	# ceil() округляет в большую сторону. Прибавляем +1 для запаса на бесшовность.
	var repetitions = ceil(target_width / chunk_width) + 1
	
	# Собираем финальную строку в оперативной памяти (это очень быстро)
	var final_text = ""
	for i in range(repetitions):
		final_text += text
	
	# Применяем готовый текст ОДИН РАЗ за весь запуск
	label1.text = final_text
	
	# Запоминаем финальную ширину
	label_width = label1.get_content_width()
	label1.size.x = label_width
	
	# 3. Создаем близнеца
	label2 = label1.duplicate()
	add_child(label2)
	
	# 4. Выставляем стартовые позиции
	label1.position = Vector2.ZERO
	if speed >= 0:
		label2.position = Vector2(-label_width, 0)
	else:
		label2.position = Vector2(label_width, 0)

func _process(delta: float) -> void:
	if text.is_empty():
		return
	
	label1.position.x += speed * delta
	label2.position.x += speed * delta
	
	if speed < 0:
		if label1.position.x <= -label_width:
			label1.position.x = label2.position.x + label_width
		if label2.position.x <= -label_width:
			label2.position.x = label1.position.x + label_width
	else:
		if label1.position.x >= label_width:
			label1.position.x = label2.position.x - label_width
		if label2.position.x >= label_width:
			label2.position.x = label1.position.x - label_width

func _set_text(new_text: String) -> void:
	text = new_text
	if is_node_ready():
		_ready()

extends Node

# Ссылки на ноды внутри синглтона
@onready var audio_player: AudioStreamPlayer = $AudioPlayer
@onready var ui_animation: AnimationPlayer = $NowPlayingCanvas/AnimationPlayer # укажи свой путь
@onready var track_label: Label # укажи свой путь
@onready var nowPlaying := $NowPlayingCanvas/nowPlaying

# ИЗМЕНЕНИЕ 1: Теперь это переменные, а не константы.
# Они автоматически определяют, где запущена игра: в редакторе или в виде .exe
var PATH_DEFAULT: String
var PATH_NEO: String

# Списки треков (пулы)
var default_pool: Array[String] = []
var neo_pool: Array[String] = []

# Очереди проигрывания (чтобы треки не повторялись)
var default_queue: Array[String] = []
var neo_queue: Array[String] = []

var last_played_track: String = ""
var is_boss_fight: bool = false
var audio_tween: Tween

func _init() -> void:
	if OS.has_feature("web"):
		PATH_DEFAULT = "res://music/default"
		PATH_NEO = "res://music/neo"
	# ИЗМЕНЕНИЕ 2: Умное разделение для разработки и для релиза
	elif OS.has_feature("editor"):
		# Когда ты тестируешь игру из редактора Godot, папки создадутся прямо в корне твоего проекта
		PATH_DEFAULT = ProjectSettings.globalize_path("res://").path_join("music/default/")
		PATH_NEO = ProjectSettings.globalize_path("res://").path_join("music/neo/")
	else:
		# В готовой игре (.exe) пути будут вести в папку "music" рядом с экзешником
		var base_dir = OS.get_executable_path().get_base_dir()
		PATH_DEFAULT = base_dir.path_join("music/default/")
		PATH_NEO = base_dir.path_join("music/neo/")

func _ready() -> void:
	audio_player.stream = null
	track_label = nowPlaying.nameText
	
	# ИЗМЕНЕНИЕ 3: Автоматически создаем эти папки на диске, если игрок их случайно удалил
	if not OS.has_feature("web"):
		_ensure_folder_exists(PATH_DEFAULT)
		_ensure_folder_exists(PATH_NEO)
	
	# Сканируем внешние папки при запуске игры
	default_pool = _scan_music_folder(PATH_DEFAULT)
	neo_pool = _scan_music_folder(PATH_NEO)
	
	# Разрешаем плееру играть, даже если игра на паузе
	process_mode = Node.PROCESS_MODE_ALWAYS

# Вспомогательная функция для создания папок на ПК пользователя
func _ensure_folder_exists(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)

# Функция автоматического подбора треков по сложности
func play_level_music() -> void:
	if is_boss_fight: return
	
	var track_to_play: String = ""
	
	# Проверяем твой глобальный класс сложности
	if Globals.diffi < 149.7:
		track_to_play = _get_next_track(default_pool, default_queue)
	else:
		track_to_play = _get_next_track(neo_pool, neo_queue)
		
	if track_to_play != "":
		_play_track(track_to_play, false)

# Функция плавного затухания текущей музыки
func fade_out_music(duration: float = 1.5) -> void:
	is_boss_fight = true
	if audio_tween: audio_tween.kill()
	audio_tween = create_tween()
	audio_tween.tween_property(audio_player, "volume_db", -60.0, duration)
	audio_tween.tween_callback(func():
		audio_player.stop()
	)

# Функция запуска темы босса
func play_boss_music(boss_track_path: String) -> void:
	is_boss_fight = true
	if audio_tween: audio_tween.kill()
	audio_player.volume_db = 0.0 
	_play_track(boss_track_path, true)

# Победа над боссом
func boss_defeated() -> void:
	if audio_tween: audio_tween.kill()
	audio_player.stop()
	is_boss_fight = false

# Кастомный загрузчик аудиофайлов (теперь поддерживает и внутренние, и внешние ресурсы)
func _load_external_audio(path: String) -> AudioStream:
	# ЕСЛИ путь встроенный (начинается с res://), загружаем обычной функцией движка
	if path.begins_with("res://"):
		return load(path) as AudioStream
		
	# ИНАЧЕ загружаем как внешний файл с жесткого диска
	if not FileAccess.file_exists(path):
		return null
		
	if path.ends_with(".ogg"):
		return AudioStreamOggVorbis.load_from_file(path)
		
	elif path.ends_with(".mp3"):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var stream = AudioStreamMP3.new()
			stream.data = file.get_buffer(file.get_length())
			return stream
			
	elif path.ends_with(".wav"):
		return AudioStreamWAV.load_from_file(path)
		
	return null

# Внутренняя функция запуска аудио и UI
func _play_track(track_path: String, loop: bool) -> void:
	if audio_tween: audio_tween.kill()
	
	# Используем наш новый внешний загрузчик ресурсов
	var stream = _load_external_audio(track_path)
	
	if stream:
		# Настройка зацикливания в Godot 4 в зависимости от формата
		if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
			stream.loop = loop
		elif stream is AudioStreamWAV:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED
			
		audio_player.stream = stream
		audio_player.volume_db = 0.0
		audio_player.play()
		
		last_played_track = track_path
		_show_now_playing_ui(track_path)

func _show_now_playing_ui(track_path: String) -> void:
	
	if nowPlaying:
		nowPlaying.show()
	
	var file_name = track_path.get_file().get_basename()
	var clean_title = file_name.replace("_", " ")
	track_label.text = clean_title
	
	ui_animation.play("show")
	await get_tree().create_timer(3.5, false).timeout
	if not is_inside_tree(): return
	
	if track_label.text == clean_title:
		ui_animation.play("hide")

# Менеджер неповторяющейся очереди (Shuffle Bag)
func _get_next_track(pool: Array[String], queue: Array[String]) -> String:
	if pool.is_empty(): 
		return ""
		
	if queue.is_empty():
		queue.append_array(pool)
		queue.shuffle()
		if queue.size() > 1 and queue[0] == last_played_track:
			var first = queue.pop_front()
			queue.insert(randi_range(1, queue.size()), first)
			
	return queue.pop_front()

# Твой безопасный сканер (прекрасно работает и с внешними путями)
func _scan_music_folder(path: String) -> Array[String]:
	var list: Array[String] = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var clean_name = file_name.replace(".remap", "").replace(".import", "")
				if clean_name.ends_with(".mp3") or clean_name.ends_with(".ogg") or clean_name.ends_with(".wav"):
					var full_path = path.path_join(clean_name)
					if not list.has(full_path):
						list.append(full_path)
			file_name = dir.get_next()
	return list

func _on_audio_player_finished() -> void:
	if not is_boss_fight:
		play_level_music()

# Полное обнуление и мгновенная остановка всей музыки и интерфейса перед перезапуском
func stop_all() -> void:
	is_boss_fight = false       # 1. Сбрасываем режим босса, открывая доступ обычной музыке
	
	if audio_tween:
		audio_tween.kill()      # 2. Убиваем запущенные таймеры плавного затухания (fade)
		
	audio_player.stop()         # 3. Полностью выключаем звук
	audio_player.volume_db = 0.0 # 4. Возвращаем громкость на нормальный уровень (0 дБ)
	
	# 5. Очищаем очереди треков, чтобы при новом старте они перемешались заново
	default_queue.clear()
	neo_queue.clear()
	
	# 6. Прячем плашку "Сейчас играет", если она была на экране
	if nowPlaying:
		nowPlaying.hide()

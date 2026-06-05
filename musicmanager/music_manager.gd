extends Node

# Ссылки на ноды внутри синглтона
@onready var audio_player: AudioStreamPlayer = $AudioPlayer
@onready var ui_animation: AnimationPlayer = $NowPlayingCanvas/AnimationPlayer # укажи свой путь
@onready var track_label: Label # укажи свой путь
@onready var nowPlaying := $NowPlayingCanvas/nowPlaying

# Пути к папкам
const PATH_DEFAULT = "res://music/default/"
const PATH_NEO = "res://music/neo/"

# Списки треков (пулы)
var default_pool: Array[String] = []
var neo_pool: Array[String] = []

# Очереди проигрывания (чтобы треки не повторялись)
var default_queue: Array[String] = []
var neo_queue: Array[String] = []

var last_played_track: String = ""
var is_boss_fight: bool = false
var audio_tween: Tween

func _ready() -> void:
	
	audio_player.stream = null
	track_label = nowPlaying.nameText
	# Сканируем папки при запуске игры
	default_pool = _scan_music_folder(PATH_DEFAULT)
	neo_pool = _scan_music_folder(PATH_NEO)
	
	# Разрешаем плееру играть, даже если игра на паузе
	process_mode = Node.PROCESS_MODE_ALWAYS

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
		_play_track(track_to_play, false) # Обычные треки зацикливаем, пока идет уровень

# 1. Функция плавного затухания текущей музыки
func fade_out_music(duration: float = 1.5) -> void:
	is_boss_fight = true # Сразу блокируем автоматический запуск обычных треков
	
	if audio_tween: audio_tween.kill()
	audio_tween = create_tween()
	
	# Плавно уводим громкость в ноль за указанное время
	audio_tween.tween_property(audio_player, "volume_db", -60.0, duration)
	audio_tween.tween_callback(func():
		audio_player.stop()
	)

# 2. Функция запуска темы босса (вызывается после анимации)
func play_boss_music(boss_track_path: String) -> void:
	is_boss_fight = true
	if audio_tween: audio_tween.kill()
	
	# Сбрасываем громкость в дефолт, так как после fade_out она осталась на -60.0
	audio_player.volume_db = 0.0 
	
	_play_track(boss_track_path, true) # Запускаем трек босса с зацикливанием

# Победа над боссом: резкий стоп
func boss_defeated() -> void:
	if audio_tween: audio_tween.kill()
	audio_player.stop()
	is_boss_fight = false
	# ПРИМЕЧАНИЕ: Новую музыку не включаем здесь! 
	# Ждем, пока в уровне отработает анимация смерти босса, 
	# и затем из скрипта уровня вызовем MusicManager.play_level_music()

# Внутренняя функция запуска аудио и UI
func _play_track(track_path: String, loop: bool) -> void:
	if audio_tween: audio_tween.kill()
	
	var stream = load(track_path)
	if stream:
		# Настройка зацикливания в Godot 4
		if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
			stream.loop = loop
			
		audio_player.stream = stream
		audio_player.volume_db = 0.0 # Возвращаем дефолтную громкость
		audio_player.play()
		
		# Запоминаем последний трек, чтобы избежать повтора при перезапуске пула
		last_played_track = track_path
		
		# Показываем UI плашку "Now Playing"
		_show_now_playing_ui(track_path)

func _show_now_playing_ui(track_path: String) -> void:
	var file_name = track_path.get_file().get_basename()
	var clean_title = file_name.replace("_", " ")
	track_label.text = clean_title
	
	# 1. Включаем анимацию появления. 
	# Она сама за 0.4 секунды сделает плашку видимой.
	ui_animation.play("show")
	
	# 2. Ждем 3.5 секунды, пока игрок читает название трека
	await get_tree().create_timer(3.5, false).timeout
	if not is_inside_tree(): return
	
	# 3. Проверяем, не включился ли за это время новый трек
	if track_label.text == clean_title:
		# 4. Плавно убираем плашку в прозрачность
		ui_animation.play("hide")

# Менеджер неповторяющейся очереди (Shuffle Bag)
func _get_next_track(pool: Array[String], queue: Array[String]) -> String:
	if pool.is_empty(): 
		push_error("Папка с музыкой пуста!")
		return ""
		
	if queue.is_empty():
		queue.append_array(pool)
		queue.shuffle()
		# Защита: если первый трек в новой очереди совпадает с только что сыгранным
		if queue.size() > 1 and queue[0] == last_played_track:
			var first = queue.pop_front()
			queue.insert(randi_range(1, queue.size()), first)
			
	return queue.pop_front()

# Безопасный сканер папок для Godot 4 (работает и в .exe/.apk)
func _scan_music_folder(path: String) -> Array[String]:
	var list: Array[String] = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				# Защита релиза: убираем движковые ремапы импортов
				var clean_name = file_name.replace(".remap", "").replace(".import", "")
				if clean_name.ends_with(".mp3") or clean_name.ends_with(".ogg") or clean_name.ends_with(".wav"):
					var full_path = path.path_join(clean_name)
					if not list.has(full_path):
						list.append(full_path)
			file_name = dir.get_next()
	return list

# Автоматический запуск следующего трека по окончании текущего
func _on_audio_player_finished() -> void:
	# Если это был не босс, просто запускаем следующий случайный трек уровня
	if not is_boss_fight:
		play_level_music()


# Полное обнуление и мгновенная остановка всей музыки и интерфейса
func stop_all() -> void:
	is_boss_fight = false
	
	# 1. Жестко тушим звук и убиваем активные твины плавного затухания
	if audio_tween:
		audio_tween.kill()
	audio_player.stop()
	
	# 2. Сбрасываем анимации интерфейса
	ui_animation.stop()        # останавливаем show/hide, если они проигрывались
	ui_animation.play("RESET") # возвращаем плашку в дефолтную невидимость
	
	# 3. Очищаем текст, чтобы сломать проверку в прошлых await-таймерах
	track_label.text = ""

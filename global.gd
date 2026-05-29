extends Node

var record_bajas = 0
const RUTA_GUARDADO = "user://record_jugador.save"
const RUTA_AJUSTES = "user://ajustes.cfg"

var desde_pausa := false

var _menu_player: AudioStreamPlayer
var _game_player: AudioStreamPlayer
var _menu_pos: float = 0.0

var MENU_STREAM: AudioStreamOggVorbis
var JUEGO_STREAMS: Array[AudioStreamOggVorbis]

var volumen_maestro := 80
var volumen_efectos := 90
var volumen_musica := 70
var pantalla_completa := true
var resolucion_idx := 0

const RESOLUCIONES := [
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1366, 768),
	Vector2i(1280, 720),
]

func _ready():
	MENU_STREAM = load("res://musica/menu_principal.ogg")
	JUEGO_STREAMS = []
	for i in range(1, 10):
		var path = "res://musica/musica%d.ogg" % i
		JUEGO_STREAMS.append(load(path))
	JUEGO_STREAMS.append(load("res://musica/muscia3.ogg"))
	cargar_record()
	cargar_ajustes()
	randomize()

func _get_menu_player() -> AudioStreamPlayer:
	if _menu_player == null or not is_instance_valid(_menu_player):
		_menu_player = AudioStreamPlayer.new()
		_menu_player.name = "MenuMusicPlayer"
		_menu_player.process_mode = PROCESS_MODE_ALWAYS
		_menu_player.volume_db = 0.0
		_menu_player.bus = &"Music"
		var parent = get_tree().current_scene
		if parent:
			parent.add_child(_menu_player)
	return _menu_player

func _get_game_player() -> AudioStreamPlayer:
	if _game_player == null or not is_instance_valid(_game_player) or not _game_player.is_inside_tree():
		_game_player = AudioStreamPlayer.new()
		_game_player.name = "GameMusicPlayer"
		_game_player.process_mode = PROCESS_MODE_ALWAYS
		_game_player.volume_db = 0.0
		_game_player.bus = &"Music"
		get_tree().root.add_child(_game_player)
	return _game_player

func save_menu_pos():
	if _menu_player and is_instance_valid(_menu_player) and _menu_player.playing:
		_menu_pos = _menu_player.get_playback_position()

func play_menu_music():
	if _game_player and is_instance_valid(_game_player) and _game_player.playing:
		_game_player.stop()
	var mp = _get_menu_player()
	if not mp.playing:
		MENU_STREAM.loop = true
		mp.stream = MENU_STREAM
		mp.play(_menu_pos)
		_menu_pos = 0.0

func play_game_music():
	if _menu_player and is_instance_valid(_menu_player) and _menu_player.playing:
		_menu_player.stop()
	var gp = _get_game_player()
	gp.stop()
	var stream = JUEGO_STREAMS[randi() % JUEGO_STREAMS.size()]
	stream.loop = true
	gp.stream = stream
	gp.play()

func aplicar_ajustes():
	var master_idx = AudioServer.get_bus_index("Master")
	var sfx_idx = AudioServer.get_bus_index("SFX")
	var music_idx = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(master_idx, linear_to_db(volumen_maestro / 100.0))
	AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(volumen_efectos / 100.0))
	AudioServer.set_bus_volume_db(music_idx, linear_to_db(volumen_musica / 100.0))
	if pantalla_completa:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		if resolucion_idx >= 0 and resolucion_idx < RESOLUCIONES.size():
			var size = RESOLUCIONES[resolucion_idx]
			DisplayServer.window_set_size(size)
			var screen = DisplayServer.window_get_current_screen()
			var screen_size = DisplayServer.screen_get_size(screen)
			DisplayServer.window_set_position(Vector2i(
				(screen_size.x - size.x) / 2,
				(screen_size.y - size.y) / 2
			))

func guardar_ajustes():
	var cfg = ConfigFile.new()
	cfg.set_value("audio", "volumen_maestro", volumen_maestro)
	cfg.set_value("audio", "volumen_efectos", volumen_efectos)
	cfg.set_value("audio", "volumen_musica", volumen_musica)
	cfg.set_value("video", "pantalla_completa", pantalla_completa)
	cfg.set_value("video", "resolucion_idx", resolucion_idx)
	cfg.save(RUTA_AJUSTES)

func cargar_ajustes():
	var cfg = ConfigFile.new()
	var err = cfg.load(RUTA_AJUSTES)
	if err == OK:
		volumen_maestro = cfg.get_value("audio", "volumen_maestro", 80)
		volumen_efectos = cfg.get_value("audio", "volumen_efectos", 90)
		volumen_musica = cfg.get_value("audio", "volumen_musica", 70)
		pantalla_completa = cfg.get_value("video", "pantalla_completa", true)
		resolucion_idx = cfg.get_value("video", "resolucion_idx", 0)
	aplicar_ajustes()

func guardar_record(nuevo_puntaje):
	# Solo guardamos si el puntaje nuevo es mayor al récord histórico
	if nuevo_puntaje > record_bajas:
		record_bajas = nuevo_puntaje
		
		# Abrimos el archivo en modo ESCRITURA (WRITE)
		var archivo = FileAccess.open(RUTA_GUARDADO, FileAccess.WRITE)
		if archivo != null:
			archivo.store_32(record_bajas) # Guardamos el número
			archivo.close()
			print("¡NUEVO RÉCORD GUARDADO EN EL DISCO: ", record_bajas, "!")

func cargar_record():
	# Revisamos si el archivo existe en tu compu
	if FileAccess.file_exists(RUTA_GUARDADO):
		# Lo abrimos en modo LECTURA (READ)
		var archivo = FileAccess.open(RUTA_GUARDADO, FileAccess.READ)
		if archivo != null:
			record_bajas = archivo.get_32() # Sacamos el número
			archivo.close()
			print("Récord cargado exitosamente: ", record_bajas)

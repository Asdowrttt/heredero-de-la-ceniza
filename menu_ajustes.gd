extends Control

signal regresar_ajustes

@onready var slider_maestro: HSlider = find_child("VolumenMaestroSlider", true, false)
@onready var slider_efectos: HSlider = find_child("VolumenEfectosSlider", true, false)
@onready var slider_musica: HSlider = find_child("VolumenMusicaSlider", true, false)
@onready var check_pantalla_completa: CheckBox = find_child("PantallaCompletaCheck", true, false)
@onready var opcion_resolucion: OptionButton = find_child("ResolucionOption", true, false)

func _ready():
	set_process_input(true)
	set_process_unhandled_key_input(true)
	if Global.desde_pausa:
		process_mode = PROCESS_MODE_WHEN_PAUSED
	if not Global.desde_pausa:
		Global.play_menu_music()
	if slider_maestro: slider_maestro.value = Global.volumen_maestro
	if slider_efectos: slider_efectos.value = Global.volumen_efectos
	if slider_musica: slider_musica.value = Global.volumen_musica
	if check_pantalla_completa: check_pantalla_completa.button_pressed = Global.pantalla_completa
	if opcion_resolucion: opcion_resolucion.selected = Global.resolucion_idx

func _on_volumen_maestro_slider_value_changed(value: float):
	Global.volumen_maestro = int(value)
	var idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(idx, linear_to_db(value / 100.0))

func _on_volumen_efectos_slider_value_changed(value: float):
	Global.volumen_efectos = int(value)
	var idx = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(idx, linear_to_db(value / 100.0))

func _on_volumen_musica_slider_value_changed(value: float):
	Global.volumen_musica = int(value)
	var idx = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(idx, linear_to_db(value / 100.0))

func _on_pantalla_completa_check_toggled(button_pressed: bool):
	Global.pantalla_completa = button_pressed
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_resolucion_option_item_selected(index: int):
	Global.resolucion_idx = index
	if Global.pantalla_completa:
		return
	var tam = Global.RESOLUCIONES[index]
	DisplayServer.window_set_size(tam)
	var screen = DisplayServer.window_get_current_screen()
	var screen_size = DisplayServer.screen_get_size(screen)
	DisplayServer.window_set_position(Vector2i(
		(screen_size.x - tam.x) / 2,
		(screen_size.y - tam.y) / 2
	))

func _unhandled_key_input(event: InputEvent):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		_on_boton_regresar_pressed()

func _on_boton_regresar_pressed():
	Global.guardar_ajustes()
	Global.save_menu_pos()
	if Global.desde_pausa:
		Global.desde_pausa = false
		regresar_ajustes.emit()
	else:
		get_tree().change_scene_to_file("res://menu_principal.tscn")

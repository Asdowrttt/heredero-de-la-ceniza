extends Control

@onready var texto_record_menu = $TextoRecord

func _ready():
	if texto_record_menu != null:
		texto_record_menu.text = "Récord Histórico: " + str(Global.record_bajas)

func _on_boton_jugar_pressed():
	# Borramos el menú y cargamos el nivel 3D
	get_tree().change_scene_to_file("res://mundo.tscn")

func _on_boton_salir_pressed():
	# Cerramos el juego por completo
	get_tree().quit()

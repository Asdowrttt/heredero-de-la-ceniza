extends Control

@onready var texto_record_menu = $TextoRecord

func _ready():
	Global.play_menu_music()
	if texto_record_menu != null:
		texto_record_menu.text = "Récord Histórico: " + str(Global.record_bajas)

func _on_boton_jugar_pressed():
	Global.save_menu_pos()
	get_tree().change_scene_to_file("res://menu_clases.tscn")

func _on_boton_instrucciones_pressed():
	Global.save_menu_pos()
	get_tree().change_scene_to_file("res://menu_instrucciones.tscn")

func _on_boton_creadores_pressed():
	Global.save_menu_pos()
	get_tree().change_scene_to_file("res://menu_creadores.tscn")

func _on_boton_ajustes_pressed():
	Global.save_menu_pos()
	get_tree().change_scene_to_file("res://menu_ajustes.tscn")

func _on_boton_salir_pressed():
	get_tree().quit()

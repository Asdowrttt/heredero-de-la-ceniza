extends Control

func _ready():
	Global.play_menu_music()

func _on_boton_regresar_pressed():
	Global.save_menu_pos()
	get_tree().change_scene_to_file("res://menu_principal.tscn")

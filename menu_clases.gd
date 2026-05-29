extends Control

# --- CENTRO (Atributos Base) ---
@onready var titulo_clase = $MarginContainer/HBoxContainer/SeccionCentral/TituloClase
@onready var valor_vida = $MarginContainer/HBoxContainer/SeccionCentral/TablaAtributos/ValorVitalidad
@onready var valor_magia = $MarginContainer/HBoxContainer/SeccionCentral/TablaAtributos/ValorMagia
@onready var valor_velocidad = $MarginContainer/HBoxContainer/SeccionCentral/TablaAtributos/ValorVelocidad
@onready var valor_armadura = $MarginContainer/HBoxContainer/SeccionCentral/TablaAtributos/ValorArmadura
@onready var valor_fuerza = $MarginContainer/HBoxContainer/SeccionCentral/TablaAtributos/ValorFuerza

# --- DERECHA (Equipo) ---
@onready var nombre_arma = $MarginContainer/HBoxContainer/PanelDerecho/NombreArma
@onready var nombre_objeto = $MarginContainer/HBoxContainer/PanelDerecho/NombreObjeto
@onready var desc_objeto = $MarginContainer/HBoxContainer/PanelDerecho/DescObjeto

# --- MODELOS 3D ---
@onready var modelo_mago: Node3D = $MarginContainer/HBoxContainer/SeccionCentral/Contenedor3D/Pantalla3D/Mundo3D/ModeloMago
@onready var modelo_caballero: Node3D = $MarginContainer/HBoxContainer/SeccionCentral/Contenedor3D/Pantalla3D/Mundo3D/ModeloCaballero
@onready var modelo_tanque: Node3D = $MarginContainer/HBoxContainer/SeccionCentral/Contenedor3D/Pantalla3D/Mundo3D/ModeloTanque

@onready var contenedor_3d = $MarginContainer/HBoxContainer/SeccionCentral/Contenedor3D
@onready var boton_jugar = $MarginContainer/HBoxContainer/PanelDerecho/Button
@onready var botones_clase = [
	$MarginContainer/HBoxContainer/MenuIzquierdo/BotonMago,
	$MarginContainer/HBoxContainer/MenuIzquierdo/BotonEspadachin,
	$MarginContainer/HBoxContainer/MenuIzquierdo/BotonTanque,
	$MarginContainer/HBoxContainer/MenuIzquierdo/BotonMarginado,
]

var clase_activa = "mago"

var datos_clases = {
	"mago": {
		"nombre": "El Erudito",
		"vida": 10, "magia": 5, "velocidad": 100, "armadura": 0, "fuerza": 15,
		"arma": "Báculo de Ceniza",
		"obj_nom": "Anillo del Sabio",
		"obj_desc": "+8% velocidad de proyectiles.",
		"hab_q": "[Q] Masa de Alma (12s): Orbes automáticos.",
		"hab_f": "[F] Milagro Fuerza (Bloqueado): Onda expansiva.",
		"hab_c": "[C] Poder Interior (Bloqueado): +50% daño, drena vida."
	},
	"espadachin": {
		"nombre": "El Ágil",
		"vida": 15, "magia": 2, "velocidad": 110, "armadura": 2, "fuerza": 10,
		"arma": "Katana Oxidada",
		"obj_nom": "Anillo de Cloranthy",
		"obj_desc": "+4% velocidad de movimiento.",
		"hab_q": "[Q] Corte Iai (8s): Desenfunde rápido que corta el viento.",
		"hab_f": "[F] Paso Rápido (Bloqueado): Esquive con invulnerabilidad.",
		"hab_c": "[C] Hoja Sangrante (Bloqueado): Aplica hemorragia por 15s."
	},
	"tanque": {
		"nombre": "El Pesado",
		"vida": 25, "magia": 1, "velocidad": 85, "armadura": 5, "fuerza": 20,
		"arma": "Espadón de Hierro",
		"obj_nom": "Anillo de Acero",
		"obj_desc": "Reduce en 1 punto el daño recibido.",
		"hab_q": "[Q] Pisotón (10s): Aumenta aplomo y remata.",
		"hab_f": "[F] Perseverancia (Bloqueado): Absorción de daño masiva.",
		"hab_c": "[C] Grito de Guerra (Bloqueado): +Daño físico por 20s."
	},
	"marginado": {
		"nombre": "El Marginado",
		"vida": 8, "magia": 1, "velocidad": 100, "armadura": 0, "fuerza": 5,
		"arma": "Garrote Podrido",
		"obj_nom": "Ojo de la Muerte",
		"obj_desc": "Enemigos pegan +50%, doble de puntos.",
		"hab_q": "[Q] (Sin habilidad)",
		"hab_f": "[F] (Sin habilidad)",
		"hab_c": "[C] (Sin habilidad)"
	}
}

func _ready():
	Global.play_menu_music()
	_aplicar_estilo_ds()
	mostrar_clase("mago")
	_crear_descripciones_habilidades()

func _aplicar_estilo_ds():
	var fondo_btn = StyleBoxFlat.new()
	fondo_btn.bg_color = Color(0.08, 0.06, 0.05, 1)
	fondo_btn.border_color = Color(0.5, 0.4, 0.15, 1)
	fondo_btn.set_border_width_all(2)
	fondo_btn.border_blend = true
	fondo_btn.set_corner_radius_all(2)
	
	var hover_btn = StyleBoxFlat.new()
	hover_btn.bg_color = Color(0.12, 0.09, 0.07, 1)
	hover_btn.border_color = Color(0.7, 0.55, 0.2, 1)
	hover_btn.set_border_width_all(2)
	hover_btn.border_blend = true
	hover_btn.set_corner_radius_all(2)
	
	var press_btn = StyleBoxFlat.new()
	press_btn.bg_color = Color(0.15, 0.11, 0.08, 1)
	press_btn.border_color = Color(0.9, 0.7, 0.25, 1)
	press_btn.set_border_width_all(2)
	press_btn.border_blend = true
	press_btn.set_corner_radius_all(2)
	
	var botones = [$MarginContainer/HBoxContainer/MenuIzquierdo/BotonMago,
		$MarginContainer/HBoxContainer/MenuIzquierdo/BotonEspadachin,
		$MarginContainer/HBoxContainer/MenuIzquierdo/BotonTanque,
		$MarginContainer/HBoxContainer/MenuIzquierdo/BotonMarginado]
	
	for btn in botones:
		btn.add_theme_font_size_override("font_size", 20)
		btn.add_theme_color_override("font_color", Color(0.85, 0.8, 0.7, 1))
		btn.add_theme_color_override("font_hover_color", Color(1, 1, 0.95, 1))
		btn.add_theme_stylebox_override("normal", fondo_btn)
		btn.add_theme_stylebox_override("hover", hover_btn)
		btn.add_theme_stylebox_override("pressed", press_btn)
		btn.custom_minimum_size = Vector2(200, 50)
	
	if boton_jugar:
		boton_jugar.add_theme_font_size_override("font_size", 22)
		boton_jugar.add_theme_color_override("font_color", Color(0.85, 0.8, 0.7, 1))
		boton_jugar.add_theme_color_override("font_hover_color", Color(1, 1, 0.95, 1))
		boton_jugar.add_theme_stylebox_override("normal", fondo_btn)
		boton_jugar.add_theme_stylebox_override("hover", hover_btn)
		boton_jugar.add_theme_stylebox_override("pressed", press_btn)
		boton_jugar.custom_minimum_size = Vector2(250, 60)
		boton_jugar.text = "JUGAR"
	
	if contenedor_3d:
		var borde_3d = StyleBoxFlat.new()
		borde_3d.bg_color = Color(0, 0, 0, 0)
		borde_3d.border_color = Color(0.5, 0.4, 0.15, 1)
		borde_3d.set_border_width_all(2)
		borde_3d.border_blend = true
		contenedor_3d.add_theme_stylebox_override("panel", borde_3d)

var labels_habilidades = []

func _crear_descripciones_habilidades():
	var panel = $MarginContainer/HBoxContainer/PanelDerecho
	var idx_btn = boton_jugar.get_index()
	
	for i in range(3):
		var lbl = Label.new()
		lbl.name = "Habilidad" + str(i)
		lbl.add_theme_color_override("font_color", Color(0.75, 0.7, 0.58, 1))
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.autowrap_mode = 1
		lbl.text = ""
		panel.add_child(lbl)
		panel.move_child(lbl, idx_btn + i)
		labels_habilidades.append(lbl)

func mostrar_clase(id_clase):
	var datos = datos_clases[id_clase]
	clase_activa = id_clase
	
	titulo_clase.text = datos["nombre"]
	valor_vida.text = str(datos["vida"])
	valor_magia.text = str(datos["magia"])
	valor_velocidad.text = str(datos["velocidad"])
	valor_armadura.text = str(datos["armadura"])
	valor_fuerza.text = str(datos["fuerza"])
	
	nombre_arma.text = datos["arma"]
	nombre_objeto.text = datos["obj_nom"]
	desc_objeto.text = datos["obj_desc"]
	
	if labels_habilidades.size() >= 3:
		labels_habilidades[0].text = datos.get("hab_q", "")
		labels_habilidades[1].text = datos.get("hab_f", "")
		labels_habilidades[2].text = datos.get("hab_c", "")
	
	if modelo_mago: modelo_mago.visible = false
	if modelo_caballero: modelo_caballero.visible = false
	if modelo_tanque: modelo_tanque.visible = false
	
	match id_clase:
		"mago":
			if modelo_mago: modelo_mago.visible = true
		"espadachin":
			if modelo_caballero: modelo_caballero.visible = true
		"tanque":
			if modelo_tanque: modelo_tanque.visible = true
	
	GameManager.clase_seleccionada = id_clase
	
	_resaltar_selector_clase(id_clase)

func _resaltar_selector_clase(id_clase):
	var colores = {
		"mago": botones_clase[0],
		"espadachin": botones_clase[1],
		"tanque": botones_clase[2],
		"marginado": botones_clase[3],
	}
	
	for btn in botones_clase:
		btn.remove_theme_color_override("font_color")
		btn.add_theme_color_override("font_color", Color(0.65, 0.6, 0.5, 1))
	
	var activo = colores.get(id_clase)
	if activo:
		activo.add_theme_color_override("font_color", Color(1, 0.95, 0.85, 1))
		activo.add_theme_color_override("font_hover_color", Color(1, 1, 0.95, 1))

# --- SEÑALES DE BOTONES DE CLASE ---
func _on_boton_mago_pressed():
	mostrar_clase("mago")

func _on_boton_espadachin_pressed():
	mostrar_clase("espadachin")

func _on_boton_tanque_pressed():
	mostrar_clase("tanque")

func _on_boton_marginado_pressed():
	mostrar_clase("marginado")

# --- TRANSICIÓN AL JUEGO ---
func _on_boton_jugar_pressed():
	if not Engine.has_singleton("GameManager"):
		print("Error: GameManager no encontrado")
		return
	if GameManager.clase_seleccionada == "":
		print("Error del sistema: No se ha seleccionado una clase.")
		return
		
	get_tree().change_scene_to_file("res://mundo.tscn")

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://mundo.tscn")

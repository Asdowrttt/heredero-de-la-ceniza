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
	mostrar_clase("mago")

func mostrar_clase(id_clase):
	var datos = datos_clases[id_clase]
	
	titulo_clase.text = datos["nombre"]
	valor_vida.text = str(datos["vida"])
	valor_magia.text = str(datos["magia"])
	valor_velocidad.text = str(datos["velocidad"])
	valor_armadura.text = str(datos["armadura"])
	valor_fuerza.text = str(datos["fuerza"])
	
	nombre_arma.text = datos["arma"]
	nombre_objeto.text = datos["obj_nom"]
	desc_objeto.text = datos["obj_desc"]
	
	# 1. Ocultar todos los modelos por defecto
	if modelo_mago: modelo_mago.visible = false
	if modelo_caballero: modelo_caballero.visible = false
	if modelo_tanque: modelo_tanque.visible = false

	# 2. Activar la visibilidad del modelo seleccionado
	match id_clase:
		"mago":
			if modelo_mago: modelo_mago.visible = true
		"espadachin":
			if modelo_caballero: modelo_caballero.visible = true
		"tanque":
			if modelo_tanque: modelo_tanque.visible = true

	# 3. Registrar la selección en la memoria persistente
	GameManager.clase_seleccionada = id_clase


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
	# Validación para asegurar que existe un dato en el Singleton
	if GameManager.clase_seleccionada == "":
		print("Error del sistema: No se ha seleccionado una clase.")
		return
		
	# Descarga la interfaz actual y carga el nivel tridimensional en memoria.
	# Modifica el parámetro con la ruta absoluta de tu escena de nivel.
	get_tree().change_scene_to_file("res://mundo.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://mundo.tscn")

extends CharacterBody3D

# --- CONSTANTES BASE (No cambian) ---
const VIDA_BASE = 100.0
const MAGIA_BASE = 12
const DANO_BASE = 50.0
const VELOCIDAD_BASE = 8.0 
const VENTANA_PARRY = 0.25 
const DASH_SPEED = 40.0
const DASH_DURATION = 0.25

# --- ESCALAMIENTO ESTILO DARK SOULS (Soft Caps por nivel) ---
const MAX_NIVEL_STAT = 10
const MAX_NIVEL_PASIVA = 3
const MAX_NIVEL_ACTIVA = 5
# Cada entrada = nivel 1..10
const ESCALA_VIDA = [15, 12, 10, 8, 6, 5, 4, 3, 2, 2]
const ESCALA_MAGIA = [2, 1, 1, 1, 1, 1, 1, 1, 1, 1]
const ESCALA_VELOCIDAD = [0.05, 0.04, 0.03, 0.02, 0.02, 0.01, 0.01, 0.01, 0.01, 0.01]
const ESCALA_ARMADURA = [2, 2, 1, 1, 1, 1, 1, 1, 1, 1]
const ESCALA_REGENERACION = [0.5, 0.35, 0.25, 0.2, 0.15, 0.1, 0.1, 0.1, 0.1, 0.1]
const ESCALA_DANO = [8, 6, 5, 4, 3, 3, 2, 2, 2, 2]
const ESCALA_VEL_DISPARO = [0.10, 0.08, 0.06, 0.05, 0.04, 0.03, 0.03, 0.02, 0.02, 0.02]
const ESCALA_AREA = [0.12, 0.10, 0.08, 0.06, 0.05, 0.04, 0.03, 0.03, 0.02, 0.02]
const ESCALA_DURACION = [0.18, 0.14, 0.12, 0.10, 0.08, 0.06, 0.05, 0.04, 0.03, 0.03]
const ESCALA_LUCK = [0.08, 0.06, 0.05, 0.04, 0.03, 0.02, 0.02, 0.01, 0.01, 0.01]
const ESCALA_XP = [0.12, 0.10, 0.08, 0.06, 0.05, 0.04, 0.03, 0.03, 0.02, 0.02]
const ESCALA_ORO = [0.18, 0.15, 0.12, 0.10, 0.08, 0.06, 0.05, 0.04, 0.03, 0.03]
const ESCALA_MALDICION = [0.30, 0.30, 0.35, 0.35, 0.40, 0.0, 0.0, 0.0, 0.0, 0.0]
const ESCALA_PROYECTILES = [1, 1, 1, 0, 0, 0, 0, 0, 0, 0]
const ESCALA_REVIVE = [1, 1, 1, 0, 0, 0, 0, 0, 0, 0]

var GolpeVisual = preload("res://golpe_visual.tscn")
var Impacto = preload("res://impacto.tscn")

# --- ESTADÍSTICAS Y ATRIBUTOS DE RPG ---

var SPEED = 8.0
var vida_maxima = 100.0
var vida_actual = 100.0
var municion_maxima = 12
var municion_actual = 12
var daño_ataque = 50.0          
var armadura = 0.0              
var regeneracion_vida = 0.0     
var velocidad_disparo = 1.0     
var modificador_area = 1.0      
var modificador_duracion = 1.0  
var proyectiles_extra = 0       
var suerte = 1.0               
var multiplicador_xp = 1.0      
var multiplicador_oro = 1.0     
var maldicion = 0.0             
var revivires_actuales = 0      
var multiplicador_dano = 1.0    
var probabilidad_esquivar = 0.0 

# --- SISTEMAS DEL JUGADOR ---
var puntaje = 0
var nivel = 1
var xp_actual = 0.0
var xp_necesaria = 100.0 
var curaciones_maximas = 3
var curaciones_actuales = 3
var cantidad_curacion = 30.0 
var tiempo_cooldown_curacion = 3.0 
var en_cooldown_curacion = false
var tiempo_recarga = 1.8 
var esta_recargando = false
var es_invencible = false
var esta_bloqueando = false
var tiempo_bloqueo = 0.0
var puede_disparar = true

# --- ESTADOS Y ANILLOS (PASIVAS) ---

# --- HABILIDADES ACTIVAS ---
var activas_equipadas = [] 
var cooldowns_actuales = [0.0, 0.0, 0.0] 
var opciones_actuales = []

# --- BUFFS TEMPORALES DE HABILIDADES ---
var buff_poder_interior = false
var buff_hoja_sangrante = false
var buff_perseverancia = false
var buff_grito_guerra = false
var armadura_perseverancia = 0.0

# --- ESTADO DE MUERTE ---
var esta_muerto = false

# --- VARIABLES PARA UI ESTILO DARK SOULS ---
var vida_ghost = 100.0
var vida_ghost_velocity = 0.0
var magia_ghost = 12.0
var magia_ghost_velocity = 0.0
var tween_ghost_vida = null
var tween_ghost_magia = null 

# --- NODOS DE INTERFAZ (UI) ---
@onready var menu_pausa = $HUD/MenuPausa
@onready var texto_stats = $HUD/MenuPausa/HBoxContainer/ColumnaStats/TextoStats
@onready var texto_habilidades = $HUD/MenuPausa/HBoxContainer/ColumnaHabilidades/TextoHabilidades
@onready var pantalla_nivel = $HUD/PantallaSubirNivel
@onready var humo_poder = $HumoPoderInterior
@onready var onda_fuerza = $OndaExpansiva
@onready var barra_vida = $HUD/BarraVida
@onready var texto_vida = $HUD/BarraVida/TextoVida
@onready var barra_xp = $HUD/BarraXP
@onready var texto_curaciones = $HUD/UI_Estus/TextoCuraciones
@onready var cooldown_estus = $HUD/UI_Estus/CooldownEstus
@onready var marcador_texto = $HUD/Marcador
@onready var pantalla_derrota = $HUD/PantallaDerrota
@onready var texto_record = $HUD/PantallaDerrota/Centro/Columna/TextoRecord
@onready var texto_municion = $HUD/UI_Magia/TextoMunicion 
@onready var cooldown_recarga = $HUD/UI_Magia/CooldownRecarga 
@onready var cooldown_dash = $HUD/UI_Dash/CooldownDash
@onready var slots_ui = [
	$HUD/CinturonActivas/Slot0,
	$HUD/CinturonActivas/Slot1,
	$HUD/CinturonActivas/Slot2
]

# --- NODOS VISUALES DEL JUGADOR ---
# 1. Agregamos las referencias a los 3 modelos
@onready var modelo_mago = $ModeloMago
@onready var modelo_caballero = $ModeloCaballero
@onready var modelo_tanque = $ModeloTanque

# 2. Volvemos el AnimationPlayer y el PuntoDisparo variables vacías, se llenarán en _ready
var anim : AnimationPlayer
var idle_anim_name = "idle"
var attack_anim_name = "ataque/mixamo_com"
@onready var punto_disparo : Node3D = $PuntoDisparo

@onready var escudo_visual = $EscudoVisual
@onready var brillo_dash = $BrilloDash

# --- ESCENAS EXTERNAS ---
var jefe_scene = preload("res://jefe.tscn")
var flecha_scene = preload("res://flechadealma.tscn")
var orbe_masa_alma_scene = preload("res://orbe_masa_alma.tscn")

# --- DICCIONARIO DE CARTAS (TIENDA) ---
var mazo_habilidades = [
	{"id": "masa_alma", "nombre": "Masa de Alma", "tipo": "activa", "cooldown": 12.0, "nivel": 0, "nivel_maximo": MAX_NIVEL_ACTIVA, "desc": "Orbes de alma que persiguen enemigos."},
	{"id": "fuerza", "nombre": "Milagro: Fuerza", "tipo": "activa", "cooldown": 18.0, "nivel": 0, "nivel_maximo": MAX_NIVEL_ACTIVA, "desc": "Onda expansiva daña y repele."},
	{"id": "poder_interior", "nombre": "Poder Interior", "tipo": "activa", "cooldown": 25.0, "nivel": 0, "nivel_maximo": MAX_NIVEL_ACTIVA, "desc": "Sacrifica vida para aumentar daño."},
	{"id": "lagrima_roja", "nombre": "Lágrima Roja", "tipo": "pasiva", "nivel": 0, "nivel_maximo": MAX_NIVEL_PASIVA, "desc": "Aumenta daño cuando la vida es baja."},
	{"id": "abejorro", "nombre": "Anillo Abejorro", "tipo": "pasiva", "nivel": 0, "nivel_maximo": MAX_NIVEL_PASIVA, "desc": "Probabilidad de esquivar ataques."},
	{"id": "mal_ojo", "nombre": "Ojo del Mal", "tipo": "pasiva", "nivel": 0, "nivel_maximo": MAX_NIVEL_PASIVA, "desc": "Vampirismo: cura al eliminar enemigos."},
	{"id": "stat_vida", "nombre": "Vitalidad de Hierro", "tipo": "estadistica", "nivel": 0, "nivel_maximo": MAX_NIVEL_STAT},
	{"id": "stat_magia", "nombre": "Mente Profunda", "tipo": "estadistica", "nivel": 0, "nivel_maximo": MAX_NIVEL_STAT},
	{"id": "stat_velocidad", "nombre": "Anillo de Cloranthy", "tipo": "estadistica", "nivel": 0, "nivel_maximo": MAX_NIVEL_STAT},
	{"id": "stat_armadura", "nombre": "Anillo de Acero", "tipo": "estadistica", "nivel": 0, "nivel_maximo": MAX_NIVEL_STAT},
	{"id": "stat_recuperacion", "nombre": "Princesa del Sol", "tipo": "estadistica", "nivel": 0, "nivel_maximo": MAX_NIVEL_STAT},
	{"id": "stat_fuerza", "nombre": "Fuerza Cruda", "tipo": "estadistica", "nivel": 0, "nivel_maximo": MAX_NIVEL_STAT},
	{"id": "stat_vel_disparo", "nombre": "Anillo del Sabio", "tipo": "estadistica", "nivel": 0, "nivel_maximo": MAX_NIVEL_STAT},
	{"id": "stat_area", "nombre": "Sello de Ampliación", "tipo": "estadistica", "nivel": 0, "nivel_maximo": MAX_NIVEL_STAT},
	{"id": "stat_duracion", "nombre": "Anillo de Lingote", "tipo": "estadistica", "nivel": 0, "nivel_maximo": MAX_NIVEL_STAT},
	{"id": "stat_proyectiles", "nombre": "Disparo Dividido", "tipo": "estadistica", "nivel": 0, "nivel_maximo": MAX_NIVEL_STAT},
	{"id": "stat_luck", "nombre": "Serpiente Dorada", "tipo": "estadistica", "nivel": 0, "nivel_maximo": MAX_NIVEL_STAT},
	{"id": "stat_xp", "nombre": "Serpiente Plateada", "tipo": "estadistica", "nivel": 0, "nivel_maximo": MAX_NIVEL_STAT},
	{"id": "stat_oro", "nombre": "Moneda de Oro", "tipo": "estadistica", "nivel": 0, "nivel_maximo": MAX_NIVEL_STAT},
	{"id": "stat_maldicion", "nombre": "Ojo de la Muerte", "tipo": "estadistica", "nivel": 0, "nivel_maximo": MAX_NIVEL_STAT},
	{"id": "stat_revive", "nombre": "Anillo de Sacrificio", "tipo": "estadistica", "nivel": 0, "nivel_maximo": MAX_NIVEL_STAT, "desc": "Revive al morir con 15% de vida."},
	# --- HABILIDADES ESPADACHÍN ---
	{"id": "corte_iai", "nombre": "Corte Iai", "tipo": "activa", "cooldown": 8.0, "nivel": 0, "nivel_maximo": MAX_NIVEL_ACTIVA, "desc": "Corte frontal de alto daño."},
	{"id": "paso_rapido", "nombre": "Paso Rápido", "tipo": "activa", "cooldown": 12.0, "nivel": 0, "nivel_maximo": MAX_NIVEL_ACTIVA, "desc": "Esquive extendido con invulnerabilidad."},
	{"id": "hoja_sangrante", "nombre": "Hoja Sangrante", "tipo": "activa", "cooldown": 20.0, "nivel": 0, "nivel_maximo": MAX_NIVEL_ACTIVA, "desc": "Aumenta daño de ataque por tiempo limitado."},
	# --- HABILIDADES TANQUE ---
	{"id": "pisoton", "nombre": "Pisotón", "tipo": "activa", "cooldown": 10.0, "nivel": 0, "nivel_maximo": MAX_NIVEL_ACTIVA, "desc": "Golpe de área que inmoviliza enemigos."},
	{"id": "perseverancia", "nombre": "Perseverancia", "tipo": "activa", "cooldown": 15.0, "nivel": 0, "nivel_maximo": MAX_NIVEL_ACTIVA, "desc": "Aumenta armadura por tiempo limitado."},
	{"id": "grito_guerra", "nombre": "Grito de Guerra", "tipo": "activa", "cooldown": 25.0, "nivel": 0, "nivel_maximo": MAX_NIVEL_ACTIVA, "desc": "Aumenta daño por tiempo limitado."},
	# --- HABILIDADES MARGINADO ---
	{"id": "sin_hab_q", "nombre": "Desarmado", "tipo": "activa", "cooldown": 0.0, "nivel": 0, "nivel_maximo": 1, "desc": "No tiene efecto."},
]

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_dashing = false
var can_dash = true
var dash_direction = Vector3.ZERO

func _ready():
	up_direction = Vector3.UP
	add_to_group("jugador")
	Global.play_game_music()
	_cargar_modelo_clase()
	
	vida_ghost = vida_maxima
	magia_ghost = municion_maxima
	
	_ocultar_slots_iniciales()
	
	_inicializar_habilidades_clase()
	
	actualizar_ui_vida()
	if barra_xp: barra_xp.max_value = xp_necesaria; barra_xp.value = xp_actual
	actualizar_texto_curaciones()
	if has_node("HUD/UI_Magia"): actualizar_ui_magia()
	
	_setup_minimap()
	_connect_director()

func _connect_director():
	var director = get_tree().get_first_node_in_group("director")
	if director:
		if director.has_signal("phase_changed"):
			director.phase_changed.connect(_on_director_phase_changed)
		if director.has_signal("climax_started"):
			director.climax_started.connect(_on_director_climax)

func _on_director_phase_changed(phase: int):
	pass

func _on_director_climax():
	pass

func _setup_minimap():
	var minimap_script = load("res://minimap.gd")
	if not minimap_script:
		return
	var mh = Control.new()
	mh.set_script(minimap_script)
	mh.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mh.name = "MinimapHUD"
	mh.custom_minimum_size = Vector2(160, 160)
	mh.size = Vector2(160, 160)
	$HUD.add_child(mh)
	mh.anchors_preset = Control.PRESET_TOP_RIGHT
	mh.anchor_right = 1.0
	mh.offset_left = -170
	mh.offset_top = 10

	var placeholder = $HUD/MenuPausa/HBoxContainer/ColumnaSistema/MapaPlaceholder
	if placeholder:
		var mf = Control.new()
		mf.set_script(minimap_script)
		mf.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mf.full_map = true
		mf.name = "MapaFull"
		mf.size = placeholder.size
		placeholder.add_child(mf)
		mf.anchors_preset = Control.PRESET_FULL_RECT
		mf.grow_horizontal = Control.GROW_DIRECTION_BOTH
		mf.grow_vertical = Control.GROW_DIRECTION_BOTH
		mf.layout_mode = 3
		placeholder.resized.connect(func():
			if is_instance_valid(mf):
				mf.size = placeholder.size
		)

func _ocultar_slots_iniciales():
	for i in range(slots_ui.size()):
		var slot = slots_ui[i]
		if slot and is_instance_valid(slot):
			slot.visible = false

func _inicializar_habilidades_clase():
	print("[DEBUG] Clase seleccionada: ", GameManager.clase_seleccionada)
	
	match GameManager.clase_seleccionada:
		"mago":
			_equipar_habilidad_inicial("masa_alma")
			_bloquear_habilidades_otras_clases(["espadachin", "tanque"])
		"espadachin":
			_equipar_habilidad_inicial("corte_iai")
			_bloquear_habilidades_otras_clases(["mago", "tanque"])
		"tanque":
			_equipar_habilidad_inicial("pisoton")
			_bloquear_habilidades_otras_clases(["mago", "espadachin"])
		_:
			_equipar_habilidad_inicial("masa_alma")
	
	print("[DEBUG] Habilidades equipadas: ", activas_equipadas.size())

func _equipar_habilidad_inicial(id_habilidad):
	for carta in mazo_habilidades:
		if carta["id"] == id_habilidad:
			carta["nivel"] = 1
			activas_equipadas.append(carta)
			var idx = activas_equipadas.size() - 1
			
			if idx < slots_ui.size() and slots_ui[idx]:
				var slot = slots_ui[idx]
				slot.visible = true
				
				if slot.has_node("IconoTecla"):
					var icono = slot.get_node("IconoTecla")
					icono.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65, 1))
				
				if slot.has_node("BordeSlot"):
					slot.get_node("BordeSlot").color = Color(0.45, 0.35, 0.15, 1)
				
				if slot.has_node("CooldownOverlay"):
					slot.get_node("CooldownOverlay").visible = false
				if slot.has_node("TextoCooldown"):
					slot.get_node("TextoCooldown").visible = false
			
			print("[DEBUG] Habilidad equipada en slot ", idx, ": ", carta["nombre"], " Nv.", carta["nivel"])
			break

func _bloquear_habilidades_otras_clases(clases_a_bloquear):
	var ids_bloqueados = []
	if "mago" in clases_a_bloquear:
		ids_bloqueados.append("masa_alma")
		ids_bloqueados.append("fuerza")
		ids_bloqueados.append("poder_interior")
	if "espadachin" in clases_a_bloquear:
		ids_bloqueados.append("corte_iai")
		ids_bloqueados.append("paso_rapido")
		ids_bloqueados.append("hoja_sangrante")
	if "tanque" in clases_a_bloquear:
		ids_bloqueados.append("pisoton")
		ids_bloqueados.append("perseverancia")
		ids_bloqueados.append("grito_guerra")
	
	for carta in mazo_habilidades:
		if carta["id"] in ids_bloqueados:
			carta["nivel"] = carta["nivel_maximo"]

# --- FUNCIONES DE ESCALAMIENTO Y DESCRIPCIÓN ---
func _escala_para_stat(id):
	match id:
		"stat_vida": return ESCALA_VIDA
		"stat_magia": return ESCALA_MAGIA
		"stat_velocidad": return ESCALA_VELOCIDAD
		"stat_armadura": return ESCALA_ARMADURA
		"stat_recuperacion": return ESCALA_REGENERACION
		"stat_fuerza": return ESCALA_DANO
		"stat_vel_disparo": return ESCALA_VEL_DISPARO
		"stat_area": return ESCALA_AREA
		"stat_duracion": return ESCALA_DURACION
		"stat_proyectiles": return ESCALA_PROYECTILES
		"stat_luck": return ESCALA_LUCK
		"stat_xp": return ESCALA_XP
		"stat_oro": return ESCALA_ORO
		"stat_maldicion": return ESCALA_MALDICION
		"stat_revive": return ESCALA_REVIVE
	return [0]

func _valor_mejora(id, nivel):
	var escala = _escala_para_stat(id)
	if nivel < 1 or nivel > escala.size():
		return 0
	return escala[nivel - 1]

func _unidad_para_stat(id):
	match id:
		"stat_vida": return "Vida Máx."
		"stat_magia": return "Munición"
		"stat_velocidad": return "Vel. Movimiento"
		"stat_armadura": return "Armadura"
		"stat_recuperacion": return "Regen HP/s"
		"stat_fuerza": return "Daño Base"
		"stat_vel_disparo": return "Vel. Proyectil"
		"stat_area": return "Área"
		"stat_duracion": return "Duración"
		"stat_proyectiles": return "Proyectiles"
		"stat_luck": return "Suerte"
		"stat_xp": return "XP Ganada"
		"stat_oro": return "Oro Ganado"
		"stat_maldicion": return "Riesgo y Puntos"
		"stat_revive": return "Revivir"
	return ""

func _valor_con_unidad(id, nivel):
	var v = _valor_mejora(id, nivel)
	match id:
		"stat_velocidad", "stat_vel_disparo", "stat_area", "stat_duracion", "stat_luck", "stat_xp", "stat_oro", "stat_maldicion":
			return "+" + str(v * 100) + "% " + _unidad_para_stat(id)
		"stat_armadura":
			return "-" + str(v) + " Daño " + _unidad_para_stat(id)
		"stat_proyectiles":
			if v > 0: return "+" + str(v) + " " + _unidad_para_stat(id) + " (-30% daño c/u)"
			else: return _unidad_para_stat(id) + " al máximo"
		"stat_recuperacion":
			return "+" + str(v) + " " + _unidad_para_stat(id)
		"stat_revive":
			if v > 0: return "+" + str(v) + " " + _unidad_para_stat(id)
			else: return _unidad_para_stat(id) + " al máximo"
		_:
			return "+" + str(v) + " " + _unidad_para_stat(id)

func _descripcion_carta(carta):
	var sig = min(carta["nivel"] + 1, carta["nivel_maximo"])
	var nmax = carta["nivel_maximo"]
	var texto_desc = carta.get("desc", "")
	
	if carta["nivel"] >= nmax:
		return "MEJORA COMPLETADA (Nv.Máx.)"
	
	match carta["tipo"]:
		"estadistica":
			var linea1 = _valor_con_unidad(carta["id"], sig)
			var linea2 = "Nv." + str(sig) + "/" + str(nmax)
			if texto_desc != "":
				return linea1 + "\n" + texto_desc + "\n" + linea2
			return linea1 + "\n" + linea2
		"activa":
			var cd_base = carta["cooldown"]
			var cd_mejorado = cd_base * pow(0.90, sig - 1)
			if carta["nivel"] == 0:
				return texto_desc + "\nCD: " + str(cd_base) + "s\n(Nv." + str(sig) + "/" + str(nmax) + ")"
			else:
				return texto_desc + "\nCD: " + str(snapped(cd_mejorado, 0.1)) + "s\n(Nv." + str(sig) + "/" + str(nmax) + ")"
		"pasiva":
			if carta["nivel"] == 0:
				return texto_desc + "\n(Nv." + str(sig) + "/" + str(nmax) + ")"
			else:
				return texto_desc + "\nMejora Nv." + str(sig) + "/" + str(nmax)
	return ""

# --- NUEVA FUNCIÓN PARA INYECTAR LA CLASE ---
func _cargar_modelo_clase():
	if modelo_mago: modelo_mago.visible = false
	if modelo_caballero: modelo_caballero.visible = false
	if modelo_tanque: modelo_tanque.visible = false

	match GameManager.clase_seleccionada:
		"mago":
			if modelo_mago:
				modelo_mago.visible = true
				anim = modelo_mago.get_node("AnimationPlayer")
				idle_anim_name = "idle"
				attack_anim_name = "ataque/mixamo_com"
				var ba = $ModeloMago/Skeleton3D/BoneAttachment3D
				if ba:
					punto_disparo = ba
		"espadachin":
			if modelo_caballero:
				modelo_caballero.visible = true
				anim = modelo_caballero.get_node("AnimationPlayer")
				idle_anim_name = "mixamo_com"
				attack_anim_name = "slash/mixamo_com"
				punto_disparo = $PuntoDisparo
		"tanque":
			if modelo_tanque:
				modelo_tanque.visible = true
				anim = modelo_tanque.get_node("AnimationPlayer")
				idle_anim_name = "mixamo_com"
				attack_anim_name = "slash/mixamo_com"
				punto_disparo = $PuntoDisparo
		_:
			if modelo_mago:
				modelo_mago.visible = true
				anim = modelo_mago.get_node("AnimationPlayer")
				idle_anim_name = "idle"
				attack_anim_name = "ataque/mixamo_com"
				var ba = $ModeloMago/Skeleton3D/BoneAttachment3D
				if ba:
					punto_disparo = ba

# ==========================================
# (EL RESTO DEL CÓDIGO)
# ==========================================

func _physics_process(delta):
	if not is_inside_tree() or get_tree().paused or esta_muerto: 
		return
	
	if not is_on_floor(): 
		velocity.y -= gravity * delta

	if regeneracion_vida > 0.0 and vida_actual < vida_maxima:
		vida_actual = min(vida_actual + (regeneracion_vida * delta), vida_maxima)
		actualizar_ui_vida()

	var nuevo_multiplicador = 1.0
	
	var nv_lagrima = _nivel_carta("lagrima_roja")
	if nv_lagrima > 0:
		var umbral = 0.2 + (nv_lagrima - 1) * 0.05
		var mult_roja = 1.5 + (nv_lagrima - 1) * 0.25
		if vida_actual <= (vida_maxima * umbral):
			nuevo_multiplicador *= mult_roja
	
	if buff_poder_interior:
		nuevo_multiplicador *= 1.5
	
	multiplicador_dano = nuevo_multiplicador
	
	var nv_abejorro = _nivel_carta("abejorro")
	probabilidad_esquivar = 0.0
	if nv_abejorro > 0:
		probabilidad_esquivar = 0.08 + (nv_abejorro - 1) * 0.06

	for i in range(activas_equipadas.size()):
		if i >= slots_ui.size():
			continue
			
		var slot = slots_ui[i]
		if not slot or not is_instance_valid(slot):
			continue
		
		if cooldowns_actuales[i] > 0:
			cooldowns_actuales[i] -= delta
			var cooldown_max = activas_equipadas[i]["cooldown"] * pow(0.92, activas_equipadas[i]["nivel"] - 1)
			var segundos_restantes = ceil(cooldowns_actuales[i])
			var porcentaje_faltante = (cooldowns_actuales[i] / cooldown_max)
			
			if slot.has_node("CooldownOverlay"):
				var overlay = slot.get_node("CooldownOverlay")
				overlay.visible = true
				overlay.anchor_top = 1.0 - porcentaje_faltante
			
			if slot.has_node("TextoCooldown"):
				var texto_cd = slot.get_node("TextoCooldown")
				texto_cd.visible = true
				if segundos_restantes > 0:
					texto_cd.text = str(int(segundos_restantes))
				else:
					texto_cd.visible = false
		else:
			if slot.has_node("CooldownOverlay"):
				slot.get_node("CooldownOverlay").visible = false
			if slot.has_node("TextoCooldown"):
				slot.get_node("TextoCooldown").visible = false

	aim_at_mouse()
	
	if Input.is_action_pressed("bloquear") and not is_dashing:
		if not esta_bloqueando:
			esta_bloqueando = true
			tiempo_bloqueo = 0.0
			if escudo_visual: escudo_visual.visible = true
		else: 
			tiempo_bloqueo += delta
	else:
		esta_bloqueando = false
		if escudo_visual: escudo_visual.visible = false

	var current_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if Input.is_action_just_pressed("dash") and can_dash and current_input != Vector2.ZERO and not esta_bloqueando:
		ejecutar_dash(current_input)

	if Input.is_action_just_pressed("disparar") and not esta_bloqueando and not is_dashing and not esta_recargando:
		if GameManager.clase_seleccionada in ["espadachin", "tanque"]:
			ejecutar_espadazo()
		elif municion_actual > 0:
			disparar()

	if Input.is_action_just_pressed("recargar") and not esta_recargando and municion_actual < municion_maxima:
		empezar_recarga()
		
	if Input.is_action_just_pressed("curar") and not esta_bloqueando and not is_dashing:
		usar_curacion()

	if Input.is_action_just_pressed("habilidad_1") and activas_equipadas.size() > 0:
		intentar_usar_activa(0)
	if Input.is_action_just_pressed("habilidad_2") and activas_equipadas.size() > 1:
		intentar_usar_activa(1)
	if Input.is_action_just_pressed("habilidad_3") and activas_equipadas.size() > 2:
		intentar_usar_activa(2)

	if is_dashing:
		velocity.x = dash_direction.x * DASH_SPEED
		velocity.z = dash_direction.z * DASH_SPEED
	else:
		var dir = Vector3(current_input.x, 0, current_input.y).normalized()
		var vel = SPEED / 2.0 if esta_bloqueando else SPEED 
		
		if dir: 
			velocity.x = dir.x * vel
			velocity.z = dir.z * vel
		else: 
			velocity.x = move_toward(velocity.x, 0, vel)
			velocity.z = move_toward(velocity.z, 0, vel)

	if anim:
		if anim.current_animation == "morir/mixamo_com":
			pass 
		elif anim.current_animation == attack_anim_name:
			pass 
		elif is_dashing:
			pass 
		elif esta_bloqueando:
			if anim.assigned_animation != "bloqueo/mixamo_com":
				anim.play("bloqueo/mixamo_com")
		elif velocity.length() > 0.2:
			if GameManager.clase_seleccionada in ["espadachin", "tanque"]:
				var anim_correr = "run/mixamo_com"
				if current_input != Vector2.ZERO:
					var fwd = -transform.basis.z
					fwd.y = 0
					fwd = fwd.normalized()
					var right = transform.basis.x
					right.y = 0
					right = right.normalized()
					var input_dir = Vector3(current_input.x, 0, current_input.y).normalized()
					var dot_fwd = fwd.dot(input_dir)
					var dot_right = right.dot(input_dir)
					if dot_fwd < -0.3:
						anim_correr = "run_back/mixamo_com"
					elif dot_right > 0.3:
						anim_correr = "strafe_right/mixamo_com"
					elif dot_right < -0.3:
						anim_correr = "strafe_left/mixamo_com"
					else:
						anim_correr = "run/mixamo_com"
				if anim.current_animation != anim_correr:
					anim.play(anim_correr)
			else:
				if anim.current_animation != "correr/mixamo_com":
					anim.play("correr/mixamo_com")
		else:
			if anim.current_animation != idle_anim_name:
				anim.play(idle_anim_name)

	_step_up()
	move_and_slide()

func _step_up():
	if not is_on_floor() or velocity.length_squared() < 1.0:
		return
	var sh = 0.45
	var ahead = Vector3(velocity.x, 0, velocity.z).normalized() * 0.15
	if test_move(global_transform, ahead):
		if not test_move(global_transform, Vector3(0, sh, 0)):
			var xform = global_transform
			xform.origin.y += sh
			if not test_move(xform, ahead):
				global_position.y += sh

# --- FUNCIONES DE COMBATE ---

func ejecutar_espadazo():
	if not puede_disparar:
		return
	puede_disparar = false

	var es_tanque = GameManager.clase_seleccionada == "tanque"

	if anim: anim.play(attack_anim_name, -1, 1.5 if not es_tanque else 1.2)

	var gv_pos = Vector3(0, 0.8, -2.5) if not es_tanque else Vector3(0, 0.4, -3.5)
	var gv = GolpeVisual.instantiate()
	add_child(gv)
	gv.position = gv_pos
	gv.emitting = true
	get_tree().create_timer(0.6 if not es_tanque else 0.8).timeout.connect(func():
		if is_instance_valid(gv): gv.queue_free()
	)

	if es_tanque and onda_fuerza:
		onda_fuerza.global_position = global_position + Vector3(0, 0.1, 0)
		onda_fuerza.emitting = true

	var cam = get_viewport().get_camera_3d()
	if cam and cam.has_method("aplicar_temblor"):
		cam.aplicar_temblor(0.15 if not es_tanque else 0.35, 0.2 if not es_tanque else 0.5)
	if has_node("SonidoDisparo"):
		$SonidoDisparo.play()

	await get_tree().create_timer(0.12 if not es_tanque else 0.2).timeout
	if not is_inside_tree(): return

	var rango_espada = 4.0 if not es_tanque else 7.0
	var angulo_espada = 100.0 if not es_tanque else 140.0
	var dano_golpe = daño_ataque * multiplicador_dano * (1.0 if not es_tanque else 1.5)

	var enemigos = _obtener_enemigos_cercanos(rango_espada)
	var frente = -transform.basis.z
	frente.y = 0
	frente = frente.normalized()

	for enemigo in enemigos:
		if not is_instance_valid(enemigo):
			continue
		var dir_enemigo = enemigo.global_position - global_position
		dir_enemigo.y = 0
		dir_enemigo = dir_enemigo.normalized()
		var angulo = rad_to_deg(frente.angle_to(dir_enemigo))
		if angulo <= angulo_espada / 2:
			_dañar_enemigo(enemigo, dano_golpe)
			var imp = Impacto.instantiate()
			if es_tanque:
				imp.scale = Vector3(1.5, 1.5, 1.5)
			imp.position = enemigo.global_position
			get_tree().root.add_child(imp)
			get_tree().create_timer(0.5 if not es_tanque else 0.6).timeout.connect(func():
				if is_instance_valid(imp): imp.queue_free()
			)

	await get_tree().create_timer(1.0).timeout
	if not is_inside_tree(): return
	puede_disparar = true

func disparar():
	if not puede_disparar:
		return
		
	puede_disparar = false
	
	if anim: anim.play(attack_anim_name, -1, 1.5)
	
	municion_actual -= 1
	actualizar_ui_magia()
	if has_node("SonidoDisparo"): $SonidoDisparo.play()
	
	var dano_base_flecha = daño_ataque
	if proyectiles_extra > 0:
		dano_base_flecha *= 0.70 
		
	var dano_total_calculado = dano_base_flecha * multiplicador_dano

	for i in range(proyectiles_extra + 1):
		var flecha = flecha_scene.instantiate()
		get_tree().current_scene.add_child(flecha)
		
		if punto_disparo:
			flecha.global_transform = Transform3D(global_transform.basis, punto_disparo.global_position)
		else:
			flecha.global_transform = global_transform
		
		if i > 0:
			var dispersion = randf_range(-0.2, 0.2) 
			flecha.rotate_y(dispersion)
		
		if "dano" in flecha: flecha.dano = dano_total_calculado
		elif "cantidad_dano" in flecha: flecha.cantidad_dano = dano_total_calculado
			
		if "velocidad" in flecha: flecha.velocidad *= velocidad_disparo
		elif "speed" in flecha: flecha.speed *= velocidad_disparo
			
		if "area" in flecha: flecha.area *= modificador_area
		if "escala_explosion" in flecha: flecha.escala_explosion *= modificador_area
		if "duracion" in flecha: flecha.duracion *= modificador_duracion

	if municion_actual <= 0: 
		empezar_recarga()
		
	var tiempo_espera = 0.6 / velocidad_disparo 
	await get_tree().create_timer(tiempo_espera).timeout
	if not is_inside_tree(): return
	puede_disparar = true

func empezar_recarga():
	esta_recargando = true
	if cooldown_recarga:
		cooldown_recarga.max_value = 100; cooldown_recarga.value = 100
		var tween = create_tween()
		tween.tween_property(cooldown_recarga, "value", 0.0, tiempo_recarga)
	await get_tree().create_timer(tiempo_recarga).timeout
	if not is_inside_tree(): return
	municion_actual = municion_maxima
	esta_recargando = false
	actualizar_ui_magia()

func actualizar_ui_magia():
	if texto_municion: texto_municion.text = str(municion_actual) + " / " + str(municion_maxima)

func ejecutar_dash(input_dir):
	is_dashing = true; can_dash = false; es_invencible = true
	if brillo_dash: brillo_dash.emitting = true
	dash_direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	await get_tree().create_timer(DASH_DURATION).timeout
	if not is_inside_tree(): return
	is_dashing = false; es_invencible = false
	if brillo_dash: brillo_dash.emitting = false
	if cooldown_dash:
		cooldown_dash.max_value = 100; cooldown_dash.value = 100
		var t = create_tween()
		t.tween_property(cooldown_dash, "value", 0.0, 2.0)
	await get_tree().create_timer(2.0).timeout
	if not is_inside_tree(): return
	can_dash = true

func aim_at_mouse():
	var cam = get_viewport().get_camera_3d()
	var ray = cam.project_ray_normal(get_viewport().get_mouse_position())
	var inter = Plane(Vector3.UP, global_position).intersects_ray(cam.project_ray_origin(get_viewport().get_mouse_position()), ray)
	if inter: look_at(Vector3(inter.x, global_position.y, inter.z), Vector3.UP)

func recibir_dano_jugador(cantidad, atacante = null):
	if esta_muerto or is_dashing or es_invencible or esta_bloqueando:
		return 

	if probabilidad_esquivar > 0 and randf() < probabilidad_esquivar:
		print("🐝 ¡Anillo Abejorro esquivó el ataque!")
		return

	var dano_enemigo = cantidad * (1.0 + maldicion)
	var dano_final = dano_enemigo - armadura
	dano_final = max(dano_final, 1.0) 
	
	var vida_anterior = vida_actual
	vida_actual -= dano_final
	
	if vida_ghost > vida_actual:
		_iniciar_ghost_vida(vida_anterior)
	
	actualizar_ui_vida()
	
	if vida_actual <= 0:
		if revivires_actuales > 0:
			revivires_actuales -= 1
			vida_actual = vida_maxima * 0.15
			vida_ghost = vida_actual
			actualizar_ui_vida()
			print("🛡️ ¡ANILLO DE SACRIFICIO ROTO! Tienes 2 segundos de inmunidad.")
			activar_inmunidad_temporal(2.0) 
			return 
			
		morir()

func _iniciar_ghost_vida(valor_anterior):
	if tween_ghost_vida:
		tween_ghost_vida.kill()
	
	vida_ghost = valor_anterior
	tween_ghost_vida = create_tween()
	tween_ghost_vida.set_ease(Tween.EASE_OUT)
	tween_ghost_vida.set_trans(Tween.TRANS_LINEAR)
	tween_ghost_vida.tween_property(self, "vida_ghost", vida_actual, 1.5)
	tween_ghost_vida.finished.connect(func():
		tween_ghost_vida = null
	)

# --- MARCADOR Y ESCALAMIENTO ---
func sumar_punto():
	puntaje += 1
	var nv_ojo = _nivel_carta("mal_ojo")
	if nv_ojo > 0 and vida_actual < vida_maxima:
		var curacion_ojo = 2.0 + (nv_ojo - 1) * 2.0
		vida_actual = min(vida_actual + curacion_ojo, vida_maxima)
		actualizar_ui_vida()
		print("👁️ Vampirismo: Recuperaste ", curacion_ojo, " de vida.")
		
	if marcador_texto: 
		marcador_texto.text = "Bajas: " + str(puntaje)

func usar_curacion():
	if curaciones_actuales > 0 and vida_actual < vida_maxima and not en_cooldown_curacion:
		curaciones_actuales -= 1
		vida_actual = min(vida_actual + cantidad_curacion, vida_maxima)
		vida_ghost = vida_actual
		if tween_ghost_vida:
			tween_ghost_vida.kill()
			tween_ghost_vida = null
		actualizar_ui_vida()
		actualizar_texto_curaciones()
		iniciar_cooldown_estus()

func iniciar_cooldown_estus():
	en_cooldown_curacion = true
	if cooldown_estus:
		cooldown_estus.max_value = 100; cooldown_estus.value = 100
		var t = create_tween()
		t.tween_property(cooldown_estus, "value", 0.0, tiempo_cooldown_curacion)
		await t.finished
	else: await get_tree().create_timer(tiempo_cooldown_curacion).timeout
	if not is_inside_tree(): return
	en_cooldown_curacion = false

func actualizar_texto_curaciones():
	if texto_curaciones: texto_curaciones.text = str(curaciones_actuales)

func ganar_experiencia(cantidad):
	var bonus_riesgo = 2.0 if maldicion > 0.0 else 1.0
	var xp_final = cantidad * multiplicador_xp * bonus_riesgo
	xp_actual += xp_final
	
	if barra_xp: barra_xp.value = xp_actual
	
	if xp_actual >= xp_necesaria:
		subir_de_nivel()

func subir_de_nivel():
	nivel += 1
	xp_actual -= xp_necesaria
	xp_necesaria *= 1.5
	
	if barra_xp: 
		barra_xp.max_value = xp_necesaria
		barra_xp.value = xp_actual
		
	print("¡LEVEL UP! Ahora eres nivel ", nivel)
	abrir_menu_cartas() 

func abrir_menu_cartas():
	get_tree().paused = true
	pantalla_nivel.visible = true
	opciones_actuales.clear()
	
	var disponibles = []
	for carta in mazo_habilidades:
		if carta["nivel"] >= carta["nivel_maximo"]:
			continue
		if carta["tipo"] == "activa":
			var ya_equipada = false
			for a in activas_equipadas:
				if a["id"] == carta["id"]:
					ya_equipada = true
					break
			if not ya_equipada and activas_equipadas.size() >= 3:
				continue
		disponibles.append(carta)
		
	disponibles.shuffle()
	
	# Priorizar variedad: si hay muchas opciones, intentar mostrar cartas no repetidas
	var seleccionadas = []
	for carta in disponibles:
		if seleccionadas.size() >= 3:
			break
		var ya_mostrada = false
		for s in seleccionadas:
			if s["id"] == carta["id"]:
				ya_mostrada = true
				break
		if not ya_mostrada:
			seleccionadas.append(carta)
	if seleccionadas.size() < 3:
		for carta in disponibles:
			if seleccionadas.size() >= 3:
				break
			var ya_mostrada = false
			for s in seleccionadas:
				if s["id"] == carta["id"]:
					ya_mostrada = true
					break
			if not ya_mostrada:
				seleccionadas.append(carta)
	
	opciones_actuales = seleccionadas
	
	var nombres_cartas_ui = ["Carta1", "Carta2", "Carta3"]
	for i in range(3):
		var ruta_carta = $HUD/PantallaSubirNivel/ContenedorCartas.get_node(nombres_cartas_ui[i])
		if i < opciones_actuales.size():
			var carta = opciones_actuales[i]
			var sufijo_nivel = ""
			if carta["nivel"] > 0:
				sufijo_nivel = " +" + str(carta["nivel"])
			ruta_carta.get_node("TituloCarta").text = carta["nombre"] + sufijo_nivel
			ruta_carta.get_node("DescripcionCarta").text = _descripcion_carta(carta)
			ruta_carta.visible = true
		else:
			ruta_carta.visible = false

func _input(event):
	if event.is_action_pressed("pausar"):
		if (pantalla_derrota and pantalla_derrota.visible) or (pantalla_nivel and pantalla_nivel.visible):
			return 
		alternar_pausa()
		
func _unhandled_input(event):
	if not pantalla_nivel.visible:
		return
		
	if event.is_action_pressed("elegir_carta_1") and opciones_actuales.size() > 0:
		aplicar_mejora(0)
	elif event.is_action_pressed("elegir_carta_2") and opciones_actuales.size() > 1:
		aplicar_mejora(1)
	elif event.is_action_pressed("elegir_carta_3") and opciones_actuales.size() > 2:
		aplicar_mejora(2)

func aplicar_mejora(indice):
	var carta_elegida = opciones_actuales[indice]
	carta_elegida["nivel"] += 1
	var nv = carta_elegida["nivel"]
	
	match carta_elegida["id"]:
		"stat_vida":
			var v = _valor_mejora("stat_vida", nv)
			vida_maxima += v
			vida_actual += v
			actualizar_ui_vida()
		"stat_magia":
			var v = _valor_mejora("stat_magia", nv)
			municion_maxima += v
			municion_actual += v
			actualizar_ui_magia()
		"stat_velocidad":
			SPEED += VELOCIDAD_BASE * _valor_mejora("stat_velocidad", nv)
		"stat_armadura":
			armadura += _valor_mejora("stat_armadura", nv)
		"stat_recuperacion":
			regeneracion_vida += _valor_mejora("stat_recuperacion", nv)
		"stat_fuerza":
			daño_ataque += _valor_mejora("stat_fuerza", nv)
		"stat_vel_disparo":
			velocidad_disparo += _valor_mejora("stat_vel_disparo", nv)
		"stat_area":
			modificador_area += _valor_mejora("stat_area", nv)
		"stat_duracion":
			modificador_duracion += _valor_mejora("stat_duracion", nv)
		"stat_proyectiles":
			proyectiles_extra += _valor_mejora("stat_proyectiles", nv)
		"stat_luck":
			suerte += _valor_mejora("stat_luck", nv)
		"stat_xp":
			multiplicador_xp += _valor_mejora("stat_xp", nv)
		"stat_oro":
			multiplicador_oro += _valor_mejora("stat_oro", nv)
		"stat_maldicion":
			maldicion += _valor_mejora("stat_maldicion", nv)
		"stat_revive":
			revivires_actuales += _valor_mejora("stat_revive", nv)
			
		"masa_alma", "fuerza", "poder_interior", "corte_iai", "paso_rapido", "hoja_sangrante", "pisoton", "perseverancia", "grito_guerra":
			if carta_elegida["tipo"] == "activa":
				var ya_equipada = false
				for a in activas_equipadas:
					if a["id"] == carta_elegida["id"]:
						ya_equipada = true
						break
				if not ya_equipada:
					activas_equipadas.append(carta_elegida)
					var idx = activas_equipadas.size() - 1
					if idx < slots_ui.size() and slots_ui[idx]:
						var slot = slots_ui[idx]
						slot.visible = true
						if slot.has_node("BordeSlot"):
							slot.get_node("BordeSlot").color = Color(0.45, 0.35, 0.15, 1)
						if slot.has_node("IconoTecla"):
							slot.get_node("IconoTecla").add_theme_color_override("font_color", Color(0.95, 0.85, 0.65, 1))

	pantalla_nivel.visible = false
	get_tree().paused = false

func intentar_usar_activa(slot):
	if slot >= cooldowns_actuales.size():
		return
		
	if cooldowns_actuales[slot] > 0:
		return
	
	if slot >= activas_equipadas.size():
		return
		
	var habilidad = activas_equipadas[slot]
	cooldowns_actuales[slot] = habilidad["cooldown"] * pow(0.92, habilidad["nivel"] - 1)
	
	print("[DEBUG] Usando habilidad: ", habilidad["nombre"], " (slot ", slot, ")")
	
	_feedback_visual_habilidad(slot)
	
	match habilidad["id"]:
		"masa_alma":
			_activar_masa_alma()
		"fuerza":
			_activar_fuerza()
		"poder_interior":
			_activar_poder_interior()
		"corte_iai":
			_activar_corte_iai()
		"paso_rapido":
			_activar_paso_rapido()
		"hoja_sangrante":
			_activar_hoja_sangrante()
		"pisoton":
			_activar_pisoton()
		"perseverancia":
			_activar_perseverancia()
		"grito_guerra":
			_activar_grito_guerra()

func _obtener_enemigos_cercanos(rango):
	var enemigos = []
	_buscar_enemigos_recursivo(get_tree().current_scene, rango, enemigos)
	return enemigos

func _buscar_enemigos_recursivo(nodo, rango, lista_enemigos):
	if not is_instance_valid(nodo):
		return
	
	if nodo != self and nodo.has_method("recibir_dano"):
		if global_position.distance_to(nodo.global_position) <= rango:
			lista_enemigos.append(nodo)
	
	for hijo in nodo.get_children():
		_buscar_enemigos_recursivo(hijo, rango, lista_enemigos)

func _dañar_enemigo(enemigo, cantidad):
	if enemigo == null or not is_instance_valid(enemigo):
		return
	if enemigo.has_method("recibir_dano"):
		enemigo.recibir_dano(cantidad * multiplicador_dano)

func _feedback_visual_habilidad(slot):
	if slot >= slots_ui.size():
		return
	
	var slot_node = slots_ui[slot]
	if not slot_node or not is_instance_valid(slot_node):
		return
	
	if slot_node.has_node("IconoTecla"):
		var icono = slot_node.get_node("IconoTecla")
		icono.modulate = Color(1.5, 1.5, 1.5, 1)
		await get_tree().create_timer(0.15).timeout
		if is_instance_valid(icono):
			icono.modulate = Color(1, 1, 1, 1)
	
	if slot_node.has_node("BordeSlot"):
		var borde = slot_node.get_node("BordeSlot")
		borde.color = Color(0.8, 0.65, 0.3, 1)
		await get_tree().create_timer(0.2).timeout
		if is_instance_valid(borde):
			borde.color = Color(0.45, 0.35, 0.15, 1)

# --- OBTENER NIVEL DE HABILIDAD ACTIVA ---
func _nivel_de_activa(id_habilidad):
	for a in activas_equipadas:
		if a["id"] == id_habilidad:
			return a["nivel"]
	return 1

# ==========================================
# HABILIDADES GENERALES / MAGO
# ==========================================

func _activar_masa_alma():
	var nv = _nivel_de_activa("masa_alma")
	var mult_dano_orb = 0.6 * (1.0 + (nv - 1) * 0.15)
	var dano_orb = daño_ataque * mult_dano_orb * multiplicador_dano
	var orbes_totales = 5 + (nv - 1) / 2
	var orbes_creados = 0
	
	print("[Masa de Alma] Iniciando, daño por orbe: ", dano_orb, ", multiplicador: ", multiplicador_dano)
	
	for i in range(orbes_totales):
		await get_tree().create_timer(0.3).timeout
		if not is_instance_valid(self):
			return
			
		var enemigos = _obtener_enemigos_cercanos(20.0)
		print("[Masa de Alma] Enemigos encontrados: ", enemigos.size())
		
		if enemigos.size() > 0:
			enemigos.shuffle()
			var objetivo = enemigos[0]
			if is_instance_valid(objetivo) and is_instance_valid(orbe_masa_alma_scene):
				var orbe = orbe_masa_alma_scene.instantiate()
				orbe.global_position = global_position + Vector3(randf_range(-0.5, 0.5), 1.2 + randf_range(-0.2, 0.2), randf_range(-0.5, 0.5))
				orbe.objetivo = objetivo
				orbe.dano = dano_orb
				get_tree().current_scene.add_child(orbe)
				
				orbes_creados += 1
				print("[Masa de Alma] Orbe ", orbes_creados, " lanzado contra: ", objetivo.name)

func _activar_fuerza():
	var nv = _nivel_de_activa("fuerza")
	var rango_onda = 8.0 + (nv - 1) * 0.5
	var mult_dano = 1.2 * (1.0 + (nv - 1) * 0.15)
	var dano_onda = daño_ataque * mult_dano
	var fuerza_empuje = 10.0 + (nv - 1) * 2.0
	
	if onda_fuerza:
		onda_fuerza.global_position = global_position + Vector3(0, 0.5, 0)
		onda_fuerza.restart()
	
	var enemigos = _obtener_enemigos_cercanos(rango_onda)
	for enemigo in enemigos:
		if is_instance_valid(enemigo):
			_dañar_enemigo(enemigo, dano_onda)
			var direccion = enemigo.global_position - global_position
			direccion.y = 0
			direccion = direccion.normalized()
			if enemigo.has_method("velocity"):
				enemigo.velocity = direccion * fuerza_empuje
	
	print("[Fuerza] Onda expansiva impactó a ", enemigos.size(), " enemigos")

func _activar_poder_interior():
	var nv = _nivel_de_activa("poder_interior")
	buff_poder_interior = true
	multiplicador_dano *= 1.5
	
	if humo_poder:
		humo_poder.emitting = true
	
	var duracion_base = 8.0 + (nv - 1) * 0.5
	var duracion = duracion_base * modificador_duracion
	var tick = 0.1
	var ticks_totales = int(duracion / tick)
	var drain_por_tick = (2.0 - (nv - 1) * 0.15) * tick
	
	for i in range(ticks_totales):
		await get_tree().create_timer(tick).timeout
		if not is_instance_valid(self) or not buff_poder_interior:
			if humo_poder:
				humo_poder.emitting = false
			return
		if vida_actual > 1.0:
			vida_actual -= max(drain_por_tick, 0.05 * tick)
			actualizar_ui_vida()
	
	if is_instance_valid(self) and buff_poder_interior:
		buff_poder_interior = false
		multiplicador_dano /= 1.5
		if humo_poder:
			humo_poder.emitting = false
		print("[Poder Interior] Efecto terminado")

# ==========================================
# HABILIDADES ESPADACHÍN
# ==========================================

func _activar_corte_iai():
	var nv = _nivel_de_activa("corte_iai")
	var rango_corte = 5.0 + (nv - 1) * 0.3
	var mult_dano = 2.0 * (1.0 + (nv - 1) * 0.15)
	var dano_corte = daño_ataque * mult_dano
	var angulo_corte = 90.0 + (nv - 1) * 5.0

	var gv = GolpeVisual.instantiate()
	add_child(gv)
	gv.position = Vector3(0, 0.8, -3.0)
	gv.emitting = true
	get_tree().create_timer(0.6).timeout.connect(func():
		if is_instance_valid(gv): gv.queue_free()
	)

	var cam = get_viewport().get_camera_3d()
	if cam and cam.has_method("aplicar_temblor"):
		cam.aplicar_temblor(0.12, 0.25)

	var enemigos_dañados = []
	var enemigos = _obtener_enemigos_cercanos(rango_corte)

	var frente_jugador = -transform.basis.z
	frente_jugador.y = 0
	frente_jugador = frente_jugador.normalized()

	for enemigo in enemigos:
		if is_instance_valid(enemigo):
			var direccion_enemigo = enemigo.global_position - global_position
			direccion_enemigo.y = 0
			direccion_enemigo = direccion_enemigo.normalized()

			var angulo = rad_to_deg(frente_jugador.angle_to(direccion_enemigo))
			if angulo <= angulo_corte / 2:
				_dañar_enemigo(enemigo, dano_corte)
				enemigos_dañados.append(enemigo)
				var imp = Impacto.instantiate()
				imp.position = enemigo.global_position
				get_tree().root.add_child(imp)
				get_tree().create_timer(0.5).timeout.connect(func():
					if is_instance_valid(imp): imp.queue_free()
				)

	print("[Corte Iai] Cortó a ", enemigos_dañados.size(), " enemigos")

func _activar_paso_rapido():
	var nv = _nivel_de_activa("paso_rapido")
	var current_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if current_input == Vector2.ZERO:
		current_input = Vector2(0, -1)
	
	is_dashing = true
	can_dash = false
	es_invencible = true
	
	if brillo_dash: brillo_dash.emitting = true
	dash_direction = Vector3(current_input.x, 0, current_input.y).normalized()
	
	var duracion_extendida = DASH_DURATION * (1.8 + (nv - 1) * 0.1)
	await get_tree().create_timer(duracion_extendida).timeout
	
	if is_instance_valid(self):
		is_dashing = false
		es_invencible = false
		if brillo_dash: brillo_dash.emitting = false
		
		if cooldown_dash:
			cooldown_dash.max_value = 100
			cooldown_dash.value = 100
			var t = create_tween()
			t.tween_property(cooldown_dash, "value", 0.0, 2.0)
		
		var espera_recarga = max(2.0 - (nv - 1) * 0.3, 0.5)
		await get_tree().create_timer(espera_recarga).timeout
		if is_instance_valid(self):
			can_dash = true
	
	print("[Paso Rápido] Esquive extendido completado")

func _activar_hoja_sangrante():
	var nv = _nivel_de_activa("hoja_sangrante")
	buff_hoja_sangrante = true
	
	var cam = get_viewport().get_camera_3d()
	if cam and cam.has_method("aplicar_temblor"):
		cam.aplicar_temblor(0.1, 0.2)
	
	var duracion_base = 15.0 + (nv - 1) * 1.0
	var duracion = duracion_base * modificador_duracion
	var mult_sangre = 0.3 * (1.0 + (nv - 1) * 0.15)
	var dano_sangre = daño_ataque * mult_sangre
	
	daño_ataque += dano_sangre
	
	await get_tree().create_timer(duracion).timeout
	
	if is_instance_valid(self) and buff_hoja_sangrante:
		buff_hoja_sangrante = false
		daño_ataque -= dano_sangre
		print("[Hoja Sangrante] Efecto de hemorragia terminado")

# ==========================================
# HABILIDADES TANQUE
# ==========================================

func _activar_pisoton():
	var nv = _nivel_de_activa("pisoton")
	var rango_pisoton = 6.0 + (nv - 1) * 0.5
	var mult_dano = 1.5 * (1.0 + (nv - 1) * 0.15)
	var dano_pisoton = daño_ataque * mult_dano

	var cam = get_viewport().get_camera_3d()
	if cam != null and cam.has_method("aplicar_temblor"):
		cam.aplicar_temblor(0.3 + (nv - 1) * 0.05, 0.5)

	if onda_fuerza:
		onda_fuerza.global_position = global_position + Vector3(0, 0.1, 0)
		onda_fuerza.emitting = true

	var enemigos = _obtener_enemigos_cercanos(rango_pisoton)
	for enemigo in enemigos:
		if is_instance_valid(enemigo):
			_dañar_enemigo(enemigo, dano_pisoton)
			if enemigo.has_method("velocity"):
				enemigo.velocity = Vector3.ZERO
			var imp = Impacto.instantiate()
			imp.scale = Vector3(1.5, 1.5, 1.5)
			imp.position = enemigo.global_position
			get_tree().root.add_child(imp)
			get_tree().create_timer(0.5).timeout.connect(func():
				if is_instance_valid(imp): imp.queue_free()
			)

	print("[Pisotón] Impactó a ", enemigos.size(), " enemigos")

func _activar_perseverancia():
	var nv = _nivel_de_activa("perseverancia")
	buff_perseverancia = true
	armadura_perseverancia = 20.0 + (nv - 1) * 5.0
	armadura += armadura_perseverancia

	var cam = get_viewport().get_camera_3d()
	if cam and cam.has_method("aplicar_temblor"):
		cam.aplicar_temblor(0.2, 0.3)

	if escudo_visual:
		escudo_visual.visible = true
		escudo_visual.scale = Vector3(1.5, 1.5, 1.5)

	var duracion_base = 15.0 + (nv - 1) * 1.0
	var duracion = duracion_base * modificador_duracion

	await get_tree().create_timer(duracion).timeout

	if is_instance_valid(self) and buff_perseverancia:
		buff_perseverancia = false
		armadura -= armadura_perseverancia
		if escudo_visual:
			escudo_visual.visible = false
			escudo_visual.scale = Vector3.ONE
		print("[Perseverancia] Resistencia mejorada terminada")

func _activar_grito_guerra():
	var nv = _nivel_de_activa("grito_guerra")
	buff_grito_guerra = true

	var cam = get_viewport().get_camera_3d()
	if cam and cam.has_method("aplicar_temblor"):
		cam.aplicar_temblor(0.25, 0.35)

	if onda_fuerza:
		onda_fuerza.global_position = global_position + Vector3(0, 0.5, 0)
		onda_fuerza.emitting = true

	if escudo_visual:
		escudo_visual.visible = true
		escudo_visual.modulate = Color(1.0, 0.3, 0.1, 0.8)
		await get_tree().create_timer(0.3).timeout
		if is_instance_valid(escudo_visual):
			escudo_visual.visible = false
			escudo_visual.modulate = Color(1, 1, 1, 1)

	var duracion_base = 20.0 + (nv - 1) * 2.0
	var duracion = duracion_base * modificador_duracion
	var mult_bonus = 0.5 * (1.0 + (nv - 1) * 0.1)
	var dano_bonus = daño_ataque * mult_bonus

	daño_ataque += dano_bonus

	await get_tree().create_timer(duracion).timeout

	if is_instance_valid(self) and buff_grito_guerra:
		buff_grito_guerra = false
		daño_ataque -= dano_bonus
		print("[Grito de Guerra] Daño aumentado terminado")

# --- FUNCIONES DE LA PANTALLA DE ESTADO ---
func alternar_pausa():
	var nuevo_estado = not get_tree().paused
	get_tree().paused = nuevo_estado
	
	var mm = $HUD/MinimapHUD
	if menu_pausa:
		menu_pausa.visible = nuevo_estado
		if nuevo_estado:
			actualizar_pantalla_estado()
		if mm:
			mm.visible = not nuevo_estado
	
	if nuevo_estado:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 

func _nivel_carta(id):
	for carta in mazo_habilidades:
		if carta["id"] == id:
			return carta["nivel"]
	return 0

func actualizar_pantalla_estado():
	var texto_atributos = "[b]--- ATRIBUTOS PRINCIPALES ---[/b]\n\n"
	
	var nv_vida = _nivel_carta("stat_vida")
	var bonus_vida = vida_maxima - VIDA_BASE
	texto_atributos += "Vitalidad: " + str(VIDA_BASE)
	if bonus_vida > 0: texto_atributos += " [color=green](+" + str(bonus_vida) + ")[/color]"
	texto_atributos += " [color=gold]Nv." + str(nv_vida) + "/" + str(MAX_NIVEL_STAT) + "[/color]\n"
	
	var nv_magia = _nivel_carta("stat_magia")
	var bonus_magia = municion_maxima - MAGIA_BASE
	texto_atributos += "Mente (Magia): " + str(MAGIA_BASE)
	if bonus_magia > 0: texto_atributos += " [color=green](+" + str(bonus_magia) + ")[/color]"
	texto_atributos += " [color=gold]Nv." + str(nv_magia) + "/" + str(MAX_NIVEL_STAT) + "[/color]\n"
	
	var nv_dano = _nivel_carta("stat_fuerza")
	var bonus_dano = daño_ataque - DANO_BASE
	texto_atributos += "Fuerza (Dano Base): " + str(DANO_BASE)
	if bonus_dano > 0: texto_atributos += " [color=green](+" + str(bonus_dano) + ")[/color]"
	texto_atributos += " [color=gold]Nv." + str(nv_dano) + "/" + str(MAX_NIVEL_STAT) + "[/color]\n"
	
	var nv_armor = _nivel_carta("stat_armadura")
	texto_atributos += "Armadura: 0"
	if armadura > 0: texto_atributos += " [color=green](+" + str(armadura) + ")[/color]"
	texto_atributos += " [color=gold]Nv." + str(nv_armor) + "/" + str(MAX_NIVEL_STAT) + "[/color]\n"
	
	var nv_vel = _nivel_carta("stat_velocidad")
	var bonus_vel = SPEED - VELOCIDAD_BASE
	texto_atributos += "Agilidad: " + str(VELOCIDAD_BASE * 10)
	if bonus_vel > 0.01: texto_atributos += " [color=green](+" + str(snapped(bonus_vel * 10, 0.1)) + ")[/color]"
	texto_atributos += " [color=gold]Nv." + str(nv_vel) + "/" + str(MAX_NIVEL_STAT) + "[/color]\n"
	
	texto_atributos += "\n[b]--- MEJORAS DE COMBATE ---[/b]\n"
	
	var nv_proj = _nivel_carta("stat_proyectiles")
	if proyectiles_extra > 0: texto_atributos += "Proyectiles Extra: [color=green]+" + str(proyectiles_extra) + "[/color]"
	else: texto_atributos += "Proyectiles Extra: 0"
	texto_atributos += " [color=gold]Nv." + str(nv_proj) + "/" + str(MAX_NIVEL_STAT) + "[/color]\n"
	
	var nv_vel_disp = _nivel_carta("stat_vel_disparo")
	var bonus_vel_disparo = (velocidad_disparo - 1.0) * 100
	texto_atributos += "Vel. de Disparo: 100%"
	if bonus_vel_disparo > 0: texto_atributos += " [color=green](+" + str(bonus_vel_disparo) + "%)[/color]"
	texto_atributos += " [color=gold]Nv." + str(nv_vel_disp) + "/" + str(MAX_NIVEL_STAT) + "[/color]\n"
		
	var nv_area = _nivel_carta("stat_area")
	var bonus_area = (modificador_area - 1.0) * 100
	texto_atributos += "Area de Efecto: 100%"
	if bonus_area > 0: texto_atributos += " [color=green](+" + str(bonus_area) + "%)[/color]"
	texto_atributos += " [color=gold]Nv." + str(nv_area) + "/" + str(MAX_NIVEL_STAT) + "[/color]\n"
	
	var nv_duracion = _nivel_carta("stat_duracion")
	var bonus_duracion = (modificador_duracion - 1.0) * 100
	texto_atributos += "Duracion Estados: 100%"
	if bonus_duracion > 0: texto_atributos += " [color=green](+" + str(bonus_duracion) + "%)[/color]"
	texto_atributos += " [color=gold]Nv." + str(nv_duracion) + "/" + str(MAX_NIVEL_STAT) + "[/color]\n"
	
	texto_atributos += "\n[b]--- UTILIDAD Y RIESGO ---[/b]\n"
	
	var nv_regen = _nivel_carta("stat_recuperacion")
	if regeneracion_vida > 0: texto_atributos += "Regen. Pasiva: [color=green]+" + str(regeneracion_vida) + " HP/s[/color]"
	else: texto_atributos += "Regen. Pasiva: 0 HP/s"
	texto_atributos += " [color=gold]Nv." + str(nv_regen) + "/" + str(MAX_NIVEL_STAT) + "[/color]\n"
	
	var nv_luck = _nivel_carta("stat_luck")
	var bonus_suerte = (suerte - 1.0) * 100
	if bonus_suerte > 0: texto_atributos += "Suerte: [color=green]+" + str(bonus_suerte) + "%[/color]"
	else: texto_atributos += "Suerte: 0%"
	texto_atributos += " [color=gold]Nv." + str(nv_luck) + "/" + str(MAX_NIVEL_STAT) + "[/color]\n"
	
	var nv_xp = _nivel_carta("stat_xp")
	var bonus_xp = (multiplicador_xp - 1.0) * 100
	if bonus_xp > 0: texto_atributos += "Experiencia Extra: [color=green]+" + str(bonus_xp) + "%[/color]"
	else: texto_atributos += "Experiencia Extra: 0%"
	texto_atributos += " [color=gold]Nv." + str(nv_xp) + "/" + str(MAX_NIVEL_STAT) + "[/color]\n"
	
	var nv_oro = _nivel_carta("stat_oro")
	var bonus_oro = (multiplicador_oro - 1.0) * 100
	if bonus_oro > 0: texto_atributos += "Oro Extra: [color=green]+" + str(bonus_oro) + "%[/color]"
	else: texto_atributos += "Oro Extra: 0%"
	texto_atributos += " [color=gold]Nv." + str(nv_oro) + "/" + str(MAX_NIVEL_STAT) + "[/color]\n"
	
	var nv_maldicion = _nivel_carta("stat_maldicion")
	if maldicion > 0: texto_atributos += "Maldicion: [color=red]Enemigos pegan +" + str(maldicion * 100) + "%[/color]"
	else: texto_atributos += "Maldicion: 0%"
	texto_atributos += " [color=gold]Nv." + str(nv_maldicion) + "/" + str(MAX_NIVEL_STAT) + "[/color]\n"

	if texto_stats:
		texto_stats.text = texto_atributos
		
	var lista_habilidades = "[b]--- HABILIDADES ACTIVAS ---[/b]\n"
	if activas_equipadas.size() == 0:
		lista_habilidades += "- Vacio -\n"
	else:
		for habilidad in activas_equipadas:
			lista_habilidades += "- " + habilidad["nombre"] + " [color=gold]Nv." + str(habilidad["nivel"]) + "/" + str(habilidad["nivel_maximo"]) + "[/color]\n"
			
	lista_habilidades += "\n[b]--- ANILLOS (PASIVAS) ---[/b]\n"
	var tiene_pasivas = false
	for carta in mazo_habilidades:
		if carta["tipo"] == "pasiva" and carta["nivel"] > 0:
			lista_habilidades += "- " + carta["nombre"] + " [color=gold]Nv." + str(carta["nivel"]) + "/" + str(carta["nivel_maximo"]) + "[/color]\n"
			tiene_pasivas = true
	if not tiene_pasivas: lista_habilidades += "- Vacio -\n"
	
	if texto_habilidades:
		texto_habilidades.text = lista_habilidades
		
func morir():
	if esta_muerto:
		return
	esta_muerto = true
	
	set_physics_process(false)
	set_process(false)
	
	if humo_poder:
		humo_poder.emitting = false
	
	if anim: anim.play("morir/mixamo_com")
	
	if puntaje > Global.record_bajas:
		Global.guardar_record(puntaje)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	await get_tree().create_timer(2.5).timeout
	if not is_inside_tree(): return
	
	get_tree().paused = true
	
	if pantalla_derrota:
		pantalla_derrota.visible = true
		
	if texto_record:
		texto_record.text = "Nivel alcanzado: " + str(nivel) + "\nPuntos totales: " + str(puntaje)
	
# --- FUNCIONES DE SOPORTE ---
func activar_inmunidad_temporal(tiempo):
	es_invencible = true
	await get_tree().create_timer(tiempo).timeout
	if not is_inside_tree(): return
	es_invencible = false

func actualizar_ui_vida():
	if barra_vida: 
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida_actual
	
	if texto_vida:
		texto_vida.text = str(round(vida_actual)) + " / " + str(round(vida_maxima))

# --- BOTONES DEL MENÚ ---
func _on_btn_volver_pressed():
	alternar_pausa()

var _ajustes_pausa: Control
var _ajustes_overlay: CanvasLayer

func _on_btn_opciones_pressed():
	Global.desde_pausa = true
	if menu_pausa:
		menu_pausa.hide()
	var mm = $HUD/MinimapHUD
	if mm:
		mm.hide()
	_ajustes_pausa = load("res://menu_ajustes.tscn").instantiate()
	_ajustes_pausa.regresar_ajustes.connect(_on_ajustes_regresar)
	var cl = CanvasLayer.new()
	cl.name = "SettingsCanvasLayer"
	cl.layer = 2
	cl.add_child(_ajustes_pausa)
	get_tree().root.add_child(cl)
	_ajustes_overlay = cl

func _on_ajustes_regresar():
	_ajustes_pausa.queue_free()
	_ajustes_pausa = null
	if _ajustes_overlay:
		_ajustes_overlay.queue_free()
		_ajustes_overlay = null
	var mm = $HUD/MinimapHUD
	if mm:
		mm.show()
	alternar_pausa()

func _on_btn_salir_pressed():
	get_tree().paused = false 
	get_tree().change_scene_to_file("res://menu_principal.tscn")

func _on_boton_reiniciar_pressed(): get_tree().paused = false; get_tree().reload_current_scene()
func _on_boton_menu_pressed(): get_tree().paused = false; get_tree().change_scene_to_file("res://menu_principal.tscn")

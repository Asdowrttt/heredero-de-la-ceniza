extends CharacterBody3D

# --- CONSTANTES BASE (No cambian) ---
const VIDA_BASE = 100.0
const MAGIA_BASE = 12
const DANO_BASE = 50.0
const VELOCIDAD_BASE = 8.0 
const VENTANA_PARRY = 0.25 
const DASH_SPEED = 40.0
const DASH_DURATION = 0.25

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
var tiene_lagrima_roja = false
var tiene_mal_ojo = false
var tiene_abejorro = false

# --- HABILIDADES ACTIVAS ---
var activas_equipadas = [] 
var cooldowns_actuales = [0.0, 0.0, 0.0] 
var opciones_actuales = [] 

# --- NODOS DE INTERFAZ (UI) ---
@onready var menu_pausa = $HUD/MenuPausa
@onready var texto_stats = $HUD/MenuPausa/HBoxContainer/ColumnaStats/TextoStats
@onready var texto_habilidades = $HUD/MenuPausa/HBoxContainer/ColumnaHabilidades/TextoHabilidades
@onready var pantalla_nivel = $HUD/PantallaSubirNivel
@onready var barra_vida = $HUD/BarraVida
@onready var barra_xp = $HUD/BarraXP
@onready var texto_curaciones = $HUD/UI_Estus/TextoCuraciones
@onready var cooldown_estus = $HUD/UI_Estus/CooldownEstus
@onready var marcador_texto = $HUD/Marcador
@onready var pantalla_derrota = $HUD/PantallaDerrota
@onready var texto_record = $HUD/PantallaDerrota/VBoxContainer/TextoRecord
@onready var texto_municion = $HUD/UI_Magia/TextoMunicion 
@onready var cooldown_recarga = $HUD/UI_Magia/CooldownRecarga 
@onready var cooldown_dash = $HUD/UI_Dash/CooldownDash
@onready var slots_ui = [
	$HUD/CinturonActivas/Slot0,
	$HUD/CinturonActivas/Slot1,
	$HUD/CinturonActivas/Slot2
]

# --- NODOS VISUALES DEL JUGADOR ---
@onready var anim = $ModeloJugador/AnimationPlayer
@onready var escudo_visual = $EscudoVisual
@onready var brillo_dash = $BrilloDash
@onready var punto_disparo = $ModeloJugador/Skeleton3D/BoneAttachment3D/PuntoDisparo # Asumiendo que metiste el PuntoDisparo al hueso de la mano

# --- ESCENAS EXTERNAS ---
var jefe_scene = preload("res://jefe.tscn")
var flecha_scene = preload("res://flechadealma.tscn")

# --- DICCIONARIO DE CARTAS (TIENDA) ---
var mazo_habilidades = [
	{"id": "masa_alma", "nombre": "Masa de Alma", "desc": "Orbes automáticos. Cooldown: 12s.", "tipo": "activa", "cooldown": 12.0, "adquirida": false},
	{"id": "fuerza", "nombre": "Milagro: Fuerza", "desc": "Onda expansiva que empuja enemigos. Cooldown: 18s.", "tipo": "activa", "cooldown": 18.0, "adquirida": false},
	{"id": "poder_interior", "nombre": "Poder Interior", "desc": "+50% daño por 8s, drena vida. Cooldown: 25s.", "tipo": "activa", "cooldown": 25.0, "adquirida": false},
	{"id": "lagrima_roja", "nombre": "Lágrima Roja", "desc": "Daño x1.5 cuando tienes < 20% de vida.", "tipo": "pasiva", "adquirida": false},
	{"id": "abejorro", "nombre": "Anillo Abejorro", "desc": "Tu Parry perfecto inflige un ligero daño.", "tipo": "pasiva", "adquirida": false},
	{"id": "mal_ojo", "nombre": "Ojo del Mal", "desc": "Recuperas 2 de vida por cada baja.", "tipo": "pasiva", "adquirida": false},
	{"id": "stat_vida", "nombre": "Vitalidad de Hierro", "desc": "+10 de Vida Máxima.", "tipo": "estadistica", "adquirida": false},
	{"id": "stat_magia", "nombre": "Mente Profunda", "desc": "+1 de Munición Máxima.", "tipo": "estadistica", "adquirida": false},
	{"id": "stat_velocidad", "nombre": "Anillo de Cloranthy", "desc": "+4% velocidad de movimiento.", "tipo": "estadistica", "adquirida": false},
	{"id": "stat_armadura", "nombre": "Anillo de Acero", "desc": "Reduce en 1 punto el daño recibido.", "tipo": "estadistica", "adquirida": false},
	{"id": "stat_recuperacion", "nombre": "Princesa del Sol", "desc": "Regenera salud lentamente.", "tipo": "estadistica", "adquirida": false},
	{"id": "stat_fuerza", "nombre": "Fuerza Cruda", "desc": "+5 de daño base a tus hechizos.", "tipo": "estadistica", "adquirida": false},
	{"id": "stat_vel_disparo", "nombre": "Anillo del Sabio", "desc": "+8% velocidad de proyectiles.", "tipo": "estadistica", "adquirida": false},
	{"id": "stat_area", "nombre": "Sello de Ampliación", "desc": "+10% área de efecto.", "tipo": "estadistica", "adquirida": false},
	{"id": "stat_duracion", "nombre": "Anillo de Lingote", "desc": "+15% de duración para estados.", "tipo": "estadistica", "adquirida": false},
	{"id": "stat_proyectiles", "nombre": "Disparo Dividido", "desc": "+1 proyectil (reduce daño un 30%).", "tipo": "estadistica", "adquirida": false},
	{"id": "stat_luck", "nombre": "Serpiente Dorada", "desc": "+5% de Suerte.", "tipo": "estadistica", "adquirida": false},
	{"id": "stat_xp", "nombre": "Serpiente Plateada", "desc": "Ganas +10% más experiencia.", "tipo": "estadistica", "adquirida": false},
	{"id": "stat_oro", "nombre": "Moneda de Oro", "desc": "Ganas +15% más oro.", "tipo": "estadistica", "adquirida": false},
	{"id": "stat_maldicion", "nombre": "Ojo de la Muerte", "desc": "Enemigos pegan +50%, doble de puntos.", "tipo": "estadistica", "adquirida": false},
	{"id": "stat_revive", "nombre": "Anillo de Sacrificio", "desc": "Revives al 15% de vida una sola vez.", "tipo": "estadistica", "adquirida": false}
]

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_dashing = false
var can_dash = true
var dash_direction = Vector3.ZERO

func _ready():
	if barra_vida: barra_vida.max_value = vida_maxima; barra_vida.value = vida_actual
	if barra_xp: barra_xp.max_value = xp_necesaria; barra_xp.value = xp_actual
	actualizar_texto_curaciones()
	if has_node("HUD/UI_Magia"): actualizar_ui_magia()
	
	for slot in slots_ui:
		if slot: slot.visible = false

func _physics_process(delta):
	# 1. ESCUDO CONTRA EL MENÚ DE PAUSA
	if get_tree().paused: 
		return
	
	# 2. GRAVEDAD
	if not is_on_floor(): 
		velocity.y -= gravity * delta

	# 3. EFECTO PRINCESA DEL SOL (Regeneración pasiva)
	if regeneracion_vida > 0.0 and vida_actual < vida_maxima:
		vida_actual = min(vida_actual + (regeneracion_vida * delta), vida_maxima)
		if barra_vida: barra_vida.value = vida_actual

	# 4. EFECTO LÁGRIMA ROJA (Modo supervivencia x1.5 de daño)
	if tiene_lagrima_roja:
		if vida_actual <= (vida_maxima * 0.2):
			multiplicador_dano = 1.5 
		else:
			multiplicador_dano = 1.0

	# 5. COOLDOWNS DE ACTIVAS Y ANIMACIÓN DE LA UI
	for i in range(activas_equipadas.size()):
		if cooldowns_actuales[i] > 0:
			cooldowns_actuales[i] -= delta
			var cooldown_max = activas_equipadas[i]["cooldown"]
			var porcentaje_listo = 100.0 - ((cooldowns_actuales[i] / cooldown_max) * 100.0)
			if slots_ui[i] and slots_ui[i].has_node("ProgressBar"):
				slots_ui[i].get_node("ProgressBar").value = porcentaje_listo
		else:
			if slots_ui[i] and slots_ui[i].has_node("ProgressBar"):
				slots_ui[i].get_node("ProgressBar").value = 100

	# 6. APUNTADO
	aim_at_mouse()
	
	# 7. PARRY / BLOQUEO
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

	# 8. INPUTS DE MOVIMIENTO BASE
	var current_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# 9. ESQUIVE (DASH)
	if Input.is_action_just_pressed("dash") and can_dash and current_input != Vector2.ZERO and not esta_bloqueando:
		ejecutar_dash(current_input)

	# 10. ACCIONES BÁSICAS
	if Input.is_action_just_pressed("disparar") and not esta_bloqueando and not is_dashing and municion_actual > 0 and not esta_recargando:
		disparar()

	if Input.is_action_just_pressed("recargar") and not esta_recargando and municion_actual < municion_maxima:
		empezar_recarga()
		
	if Input.is_action_just_pressed("curar") and not esta_bloqueando and not is_dashing:
		usar_curacion()

	# 11. LANZAR HABILIDADES ACTIVAS
	if Input.is_action_just_pressed("habilidad_1") and activas_equipadas.size() > 0:
		intentar_usar_activa(0)
	if Input.is_action_just_pressed("habilidad_2") and activas_equipadas.size() > 1:
		intentar_usar_activa(1)
	if Input.is_action_just_pressed("habilidad_3") and activas_equipadas.size() > 2:
		intentar_usar_activa(2)

# 12. APLICACIÓN DE VELOCIDAD FÍSICA
	if is_dashing:
		velocity.x = dash_direction.x * DASH_SPEED
		velocity.z = dash_direction.z * DASH_SPEED
	else:
		var dir = Vector3(current_input.x, 0, current_input.y).normalized()
		
		# Ya quitamos el freno. Ahora puedes correr mientras disparas. 
		# Solo vas a caminar a la mitad de velocidad si levantas el escudo.
		var vel = SPEED / 2.0 if esta_bloqueando else SPEED 
		
		if dir: 
			velocity.x = dir.x * vel
			velocity.z = dir.z * vel
		else: 
			velocity.x = move_toward(velocity.x, 0, vel)
			velocity.z = move_toward(velocity.z, 0, vel)

	# =================================================================
	# CONTROLADOR DE ANIMACIONES CON CONDICIONES DE PRIORIDAD
	# =================================================================
	if anim:
		if anim.current_animation == "morir/mixamo_com":
			pass 
		elif anim.current_animation == "ataque/mixamo_com":
			pass 
		elif is_dashing:
			pass 
		elif esta_bloqueando:
			# LA SOLUCIÓN DEL ESCUDO:
			# assigned_animation recuerda qué animación pediste, aunque ya haya terminado de moverse.
			# Así levanta el brazo una vez y se queda congelado protegiéndose, sin reiniciarse.
			if anim.assigned_animation != "bloqueo/mixamo_com":
				anim.play("bloqueo/mixamo_com")
		elif velocity.length() > 0.2:
			if anim.current_animation != "correr/mixamo_com":
				anim.play("correr/mixamo_com")
		else:
			if anim.current_animation != "idle":
				anim.play("idle")
	# =================================================================

	move_and_slide()

# --- FUNCIONES DE COMBATE ---

func disparar():
	if not puede_disparar:
		return
		
	puede_disparar = false
	
	if anim: anim.play("ataque/mixamo_com", -1, 1.5)
	
	municion_actual -= 1
	actualizar_ui_magia()
	if has_node("SonidoDisparo"): $SonidoDisparo.play()
	
	# 1. CÁLCULO DE DAÑO BÁSICO
	var dano_base_flecha = daño_ataque
	if proyectiles_extra > 0:
		dano_base_flecha *= 0.70 
		
	var dano_total_calculado = dano_base_flecha * multiplicador_dano

	# 2. BUCLE DE ESCOPETA (Proyectiles Extra)
	for i in range(proyectiles_extra + 1):
		var flecha = flecha_scene.instantiate()
		get_tree().current_scene.add_child(flecha)
		
		if punto_disparo:
			flecha.global_transform = punto_disparo.global_transform
		else:
			flecha.global_transform = global_transform
		
		if i > 0:
			var dispersion = randf_range(-0.2, 0.2) 
			flecha.rotate_y(dispersion)
		
		# 3. EL ESLABÓN PERDIDO: INYECTAR LAS STATS A LA MAGIA
		if "dano" in flecha: flecha.dano = dano_total_calculado
		elif "cantidad_dano" in flecha: flecha.cantidad_dano = dano_total_calculado
			
		if "velocidad" in flecha: flecha.velocidad *= velocidad_disparo
		elif "speed" in flecha: flecha.speed *= velocidad_disparo
			
		# INYECTAR ÁREA Y DURACIÓN (Para cuando hagas granadas o veneno)
		if "area" in flecha: flecha.area *= modificador_area
		if "escala_explosion" in flecha: flecha.escala_explosion *= modificador_area
		if "duracion" in flecha: flecha.duracion *= modificador_duracion

	if municion_actual <= 0: 
		empezar_recarga()
		
	# 4. EL COOLDOWN DE DISPARO AFECTADO POR TU ESTADÍSTICA
	# Entre más "Velocidad de Disparo" compres, menos tiempo esperas para volver a tirar.
	var tiempo_espera = 0.6 / velocidad_disparo 
	await get_tree().create_timer(tiempo_espera).timeout
	puede_disparar = true

func empezar_recarga():
	esta_recargando = true
	if cooldown_recarga:
		cooldown_recarga.max_value = 100; cooldown_recarga.value = 100
		var tween = create_tween()
		tween.tween_property(cooldown_recarga, "value", 0.0, tiempo_recarga)
	await get_tree().create_timer(tiempo_recarga).timeout
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
	is_dashing = false; es_invencible = false
	if brillo_dash: brillo_dash.emitting = false
	if cooldown_dash:
		cooldown_dash.max_value = 100; cooldown_dash.value = 100
		var t = create_tween()
		t.tween_property(cooldown_dash, "value", 0.0, 2.0)
	await get_tree().create_timer(2.0).timeout
	can_dash = true

func aim_at_mouse():
	var cam = get_viewport().get_camera_3d()
	var ray = cam.project_ray_normal(get_viewport().get_mouse_position())
	var inter = Plane(Vector3.UP, global_position).intersects_ray(cam.project_ray_origin(get_viewport().get_mouse_position()), ray)
	if inter: look_at(Vector3(inter.x, global_position.y, inter.z), Vector3.UP)

func recibir_dano_jugador(cantidad, atacante = null):
	if is_dashing or es_invencible or esta_bloqueando:
		return 

	var dano_enemigo = cantidad * (1.0 + maldicion)
	var dano_final = dano_enemigo - armadura
	dano_final = max(dano_final, 1.0) 
	
	vida_actual -= dano_final
	if barra_vida: barra_vida.value = vida_actual
	
	if vida_actual <= 0:
		if revivires_actuales > 0:
			revivires_actuales -= 1
			vida_actual = vida_maxima * 0.15
			if barra_vida: barra_vida.value = vida_actual
			print("🛡️ ¡ANILLO DE SACRIFICIO ROTO! Tienes 2 segundos de inmunidad.")
			activar_inmunidad_temporal(2.0) 
			return 
			
		morir()

# --- MARCADOR Y ESCALAMIENTO ---
func sumar_punto():
	puntaje += 1
	if tiene_mal_ojo and vida_actual < vida_maxima:
		vida_actual = min(vida_actual + 2.0, vida_maxima)
		if barra_vida: barra_vida.value = vida_actual
		print("👁️ Vampirismo: Recuperaste 2 de vida.")
		
	if marcador_texto: 
		marcador_texto.text = "Bajas: " + str(puntaje)
	
	if puntaje % 5 == 0:
		var generador = get_tree().get_first_node_in_group("generador")
		if generador != null:
			generador.aumentar_dificultad()
			
	if puntaje == 30: 
		invocar_jefe(true)
	elif puntaje > 30 and puntaje % 15 == 0: 
		invocar_jefe(false)

func invocar_jefe(es_principal):
	var jefe = jefe_scene.instantiate()
	jefe.es_jefe_principal = es_principal
	jefe.vida_jefe = 1500.0 if es_principal else 400.0
	get_tree().current_scene.add_child(jefe)
	var cam = get_viewport().get_camera_3d()
	if cam and cam.has_method("aplicar_temblor"): cam.aplicar_temblor(0.5 if es_principal else 0.2, 0.8 if es_principal else 0.4)
	var gen = get_tree().get_first_node_in_group("generador")
	jefe.global_position = gen.global_position if gen else Vector3(0, 2, 0)
	if es_principal and has_node("HUD/BarraJefe"):
		var barra = get_node("HUD/BarraJefe")
		barra.max_value = jefe.vida_jefe
		barra.value = jefe.vida_jefe
		barra.visible = true
		jefe.barra_ui = barra

func usar_curacion():
	if curaciones_actuales > 0 and vida_actual < vida_maxima and not en_cooldown_curacion:
		curaciones_actuales -= 1
		vida_actual = min(vida_actual + cantidad_curacion, vida_maxima)
		if barra_vida: barra_vida.value = vida_actual
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
		if carta["adquirida"]: 
			continue
			
		if carta["tipo"] == "activa" and activas_equipadas.size() >= 3:
			continue
			
		disponibles.append(carta)
		
	disponibles.shuffle()
	
	for i in range(min(3, disponibles.size())):
		opciones_actuales.append(disponibles[i])
		
	if opciones_actuales.size() > 0:
		$HUD/PantallaSubirNivel/ContenedorCartas/Carta1/TituloCarta.text = opciones_actuales[0]["nombre"]
		$HUD/PantallaSubirNivel/ContenedorCartas/Carta1/DescripcionCarta.text = opciones_actuales[0]["desc"]
		$HUD/PantallaSubirNivel/ContenedorCartas/Carta1.visible = true
	else:
		$HUD/PantallaSubirNivel/ContenedorCartas/Carta1.visible = false
		
	if opciones_actuales.size() > 1:
		$HUD/PantallaSubirNivel/ContenedorCartas/Carta2/TituloCarta.text = opciones_actuales[1]["nombre"]
		$HUD/PantallaSubirNivel/ContenedorCartas/Carta2/DescripcionCarta.text = opciones_actuales[1]["desc"]
		$HUD/PantallaSubirNivel/ContenedorCartas/Carta2.visible = true
	else:
		$HUD/PantallaSubirNivel/ContenedorCartas/Carta2.visible = false
		
	if opciones_actuales.size() > 2:
		$HUD/PantallaSubirNivel/ContenedorCartas/Carta3/TituloCarta.text = opciones_actuales[2]["nombre"]
		$HUD/PantallaSubirNivel/ContenedorCartas/Carta3/DescripcionCarta.text = opciones_actuales[2]["desc"]
		$HUD/PantallaSubirNivel/ContenedorCartas/Carta3.visible = true
	else:
		$HUD/PantallaSubirNivel/ContenedorCartas/Carta3.visible = false

func _input(event):
	if event.is_action_pressed("pausar"):
		print("🚨 TECLA ESCAPE DETECTADA 🚨") 
		if (pantalla_derrota and pantalla_derrota.visible) or (pantalla_nivel and pantalla_nivel.visible):
			print("⚠️ Pausa bloqueada porque hay otro menú abierto.")
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
	if carta_elegida["tipo"] != "estadistica":
		carta_elegida["adquirida"] = true 
	
	print("🔥 ADQUIRISTE: ", carta_elegida["nombre"])
	
	match carta_elegida["id"]:
		"stat_vida":
			vida_maxima += 10.0
			vida_actual += 10.0
			if barra_vida: barra_vida.max_value = vida_maxima; barra_vida.value = vida_actual
		"stat_magia":
			municion_maxima += 1
			municion_actual += 1
			actualizar_ui_magia()
		"stat_velocidad":
			SPEED += (VELOCIDAD_BASE * 0.04)
		"stat_armadura":
			armadura += 1.0
		"stat_recuperacion":
			regeneracion_vida += 0.25
		"stat_fuerza":
			daño_ataque += 5.0
		"stat_vel_disparo":
			velocidad_disparo += 0.08
		"stat_area":
			modificador_area += 0.10
		"stat_duracion":
			modificador_duracion += 0.15
		"stat_proyectiles":
			proyectiles_extra += 1
		"stat_luck":
			suerte += 0.05
		"stat_xp":
			multiplicador_xp += 0.10
		"stat_oro":
			multiplicador_oro += 0.15
		"stat_maldicion":
			maldicion += 0.50
		"stat_revive":
			revivires_actuales += 1
			
		"lagrima_roja": tiene_lagrima_roja = true
		"abejorro": tiene_abejorro = true
		"mal_ojo": tiene_mal_ojo = true
		"masa_alma", "fuerza", "poder_interior":
			activas_equipadas.append(carta_elegida)
			var idx = activas_equipadas.size() - 1
			if slots_ui[idx]: slots_ui[idx].visible = true; slots_ui[idx].get_node("ProgressBar").value = 100

	pantalla_nivel.visible = false
	get_tree().paused = false

func intentar_usar_activa(slot):
	if cooldowns_actuales[slot] > 0:
		print("Habilidad en recarga! Faltan: ", step_decimals(cooldowns_actuales[slot]), "s")
		return
		
	var habilidad = activas_equipadas[slot]
	print("Activando: ", habilidad["nombre"])
	cooldowns_actuales[slot] = habilidad["cooldown"]
	
	if habilidad["id"] == "fuerza":
		pass
	elif habilidad["id"] == "masa_alma":
		pass

# --- FUNCIONES DE LA PANTALLA DE ESTADO ---
func alternar_pausa():
	var nuevo_estado = not get_tree().paused
	get_tree().paused = nuevo_estado
	
	if menu_pausa:
		menu_pausa.visible = nuevo_estado
		if nuevo_estado:
			actualizar_pantalla_estado() 
		
	if nuevo_estado:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 

func actualizar_pantalla_estado():
	# ==============================
	# 1. ESTADÍSTICAS DEL JUGADOR
	# ==============================
	var texto_atributos = "[b]--- ATRIBUTOS PRINCIPALES ---[/b]\n\n"
	
	# Vida
	var bonus_vida = vida_maxima - VIDA_BASE
	texto_atributos += "❤️ Vitalidad: " + str(VIDA_BASE)
	if bonus_vida > 0: texto_atributos += " [color=green](+" + str(bonus_vida) + ")[/color]"
	texto_atributos += "\n"
	
	# Magia (Munición Máxima)
	var bonus_magia = municion_maxima - MAGIA_BASE
	texto_atributos += "🔵 Mente (Magia): " + str(MAGIA_BASE)
	if bonus_magia > 0: texto_atributos += " [color=green](+" + str(bonus_magia) + ")[/color]"
	texto_atributos += "\n"
	
	# Daño
	var bonus_dano = daño_ataque - DANO_BASE
	texto_atributos += "⚔️ Fuerza (Daño Base): " + str(DANO_BASE)
	if bonus_dano > 0: texto_atributos += " [color=green](+" + str(bonus_dano) + ")[/color]"
	texto_atributos += "\n"
	
	# Armadura
	texto_atributos += "🛡️ Armadura: 0"
	if armadura > 0: texto_atributos += " [color=green](+" + str(armadura) + ")[/color]"
	texto_atributos += "\n"
	
	# Velocidad
	var bonus_vel = SPEED - VELOCIDAD_BASE
	texto_atributos += "👟 Agilidad: " + str(VELOCIDAD_BASE * 10)
	if bonus_vel > 0.01: texto_atributos += " [color=green](+" + str(snapped(bonus_vel * 10, 0.1)) + ")[/color]"
	texto_atributos += "\n"
	
	texto_atributos += "\n[b]--- MEJORAS DE COMBATE ---[/b]\n"
	
	if proyectiles_extra > 0: texto_atributos += "🏹 Proyectiles Extra: [color=green]+" + str(proyectiles_extra) + "[/color]\n"
	else: texto_atributos += "🏹 Proyectiles Extra: 0\n"
		
	var bonus_vel_disparo = (velocidad_disparo - 1.0) * 100
	texto_atributos += "💨 Vel. de Disparo: 100%"
	if bonus_vel_disparo > 0: texto_atributos += " [color=green](+" + str(bonus_vel_disparo) + "%)[/color]"
	texto_atributos += "\n"
		
	var bonus_area = (modificador_area - 1.0) * 100
	texto_atributos += "💥 Área de Efecto: 100%"
	if bonus_area > 0: texto_atributos += " [color=green](+" + str(bonus_area) + "%)[/color]"
	texto_atributos += "\n"
		
	var bonus_duracion = (modificador_duracion - 1.0) * 100
	texto_atributos += "⏳ Duración Estados: 100%"
	if bonus_duracion > 0: texto_atributos += " [color=green](+" + str(bonus_duracion) + "%)[/color]"
	texto_atributos += "\n"
	
	texto_atributos += "\n[b]--- UTILIDAD Y RIESGO ---[/b]\n"
	
	if regeneracion_vida > 0: texto_atributos += "🩸 Regen. Pasiva: [color=green]+" + str(regeneracion_vida) + " HP/s[/color]\n"
	else: texto_atributos += "🩸 Regen. Pasiva: 0 HP/s\n"
	
	var bonus_suerte = (suerte - 1.0) * 100
	if bonus_suerte > 0: texto_atributos += "✨ Suerte: [color=green]+" + str(bonus_suerte) + "%[/color]\n"
	else: texto_atributos += "✨ Suerte: 0%\n"
	
	var bonus_xp = (multiplicador_xp - 1.0) * 100
	if bonus_xp > 0: texto_atributos += "🧠 Experiencia Extra: [color=green]+" + str(bonus_xp) + "%[/color]\n"
	else: texto_atributos += "🧠 Experiencia Extra: 0%\n"
	
	var bonus_oro = (multiplicador_oro - 1.0) * 100
	if bonus_oro > 0: texto_atributos += "💰 Oro Extra: [color=green]+" + str(bonus_oro) + "%[/color]\n"
	else: texto_atributos += "💰 Oro Extra: 0%\n"
	
	if maldicion > 0: texto_atributos += "💀 Maldición: [color=red]Enemigos pegan +" + str(maldicion * 100) + "%[/color]\n"
	else: texto_atributos += "💀 Maldición: 0%\n"

	if texto_stats:
		texto_stats.text = texto_atributos
		
	# ==============================
	# 2. LISTA DE CARTAS / ANILLOS
	# ==============================
	var lista_habilidades = "[b]--- HABILIDADES ACTIVAS ---[/b]\n"
	if activas_equipadas.size() == 0:
		lista_habilidades += "- Vacío -\n"
	else:
		for habilidad in activas_equipadas:
			lista_habilidades += "- " + habilidad["nombre"] + "\n"
			
	lista_habilidades += "\n[b]--- ANILLOS (PASIVAS) ---[/b]\n"
	var tiene_pasivas = false
	if tiene_lagrima_roja: lista_habilidades += "- Lágrima Roja\n"; tiene_pasivas = true
	if tiene_mal_ojo: lista_habilidades += "- Ojo del Mal\n"; tiene_pasivas = true
	if tiene_abejorro: lista_habilidades += "- Anillo del Abejorro\n"; tiene_pasivas = true
	if revivires_actuales > 0: lista_habilidades += "- Anillo de Sacrificio (" + str(revivires_actuales) + ")\n"; tiene_pasivas = true
	if not tiene_pasivas: lista_habilidades += "- Vacío -\n"
	
	if texto_habilidades:
		texto_habilidades.text = lista_habilidades
		
func morir():
	print("💀 YOU DIED")
	
	if anim: anim.play("morir/mixamo_com")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	await get_tree().create_timer(2.5).timeout
	
	get_tree().paused = true
	
	if pantalla_derrota:
		pantalla_derrota.visible = true
		
	if texto_record:
		texto_record.text = "Nivel alcanzado: " + str(nivel) + "\nPuntos totales: " + str(puntaje)
	
# --- FUNCIONES DE SOPORTE ---
func activar_inmunidad_temporal(tiempo):
	es_invencible = true
	await get_tree().create_timer(tiempo).timeout
	es_invencible = false

# --- BOTONES DEL MENÚ ---
func _on_btn_volver_pressed():
	alternar_pausa()

func _on_btn_opciones_pressed():
	print("Abriendo configuración...")

func _on_btn_salir_pressed():
	get_tree().paused = false 
	get_tree().change_scene_to_file("res://menu_principal.tscn")

func _on_boton_reiniciar_pressed(): get_tree().paused = false; get_tree().reload_current_scene()
func _on_boton_menu_pressed(): get_tree().paused = false; get_tree().change_scene_to_file("res://menu_principal.tscn")

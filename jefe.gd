extends CharacterBody3D

# --- ESTADÍSTICAS DEL JEFE ---
var vida_jefe = 1500.0
var velocidad_normal = 5.0
var velocidad_rafaga = 35.0
var dano_jefe = 45 
var barra_ui = null
var estado = "persiguiendo" 
var jugador = null
var golpes_dados = 0
var es_jefe_principal = true 

# --- Control para cancelar ataques fantasma ---
var ataque_id = 0 

@onready var barra_cabeza = $MiniPantalla/BarraVidaJefe
@onready var caja_golpe = $CajaGolpe

func _ready():
	jugador = get_tree().get_first_node_in_group("jugador")
	iniciar_ciclo_ataque()
	
	if not es_jefe_principal:
		if barra_cabeza != null:
			barra_cabeza.max_value = vida_jefe
			barra_cabeza.value = vida_jefe
			barra_cabeza.visible = true
	else:
		if barra_cabeza != null:
			barra_cabeza.visible = false

func _physics_process(_delta):
	# ESCUDO 1: Validamos que el jugador siga existiendo antes de hacer cualquier cosa
	if not is_instance_valid(jugador): return 
	
	if estado == "aturdido":
		return
		
	# Comportamiento según su estado actual
	if estado == "persiguiendo":
		var direccion = (jugador.global_position - global_position).normalized()
		velocity = direccion * velocidad_normal
		move_and_slide()
		
	elif estado == "rafaga":
		move_and_slide()

# --- LA MÁQUINA DE ATAQUES BLINDADA ---
func iniciar_ciclo_ataque():
	ataque_id += 1 # Le damos un ID nuevo a este ciclo
	var mi_id = ataque_id # Guardamos el ID en este ataque específico
	
	while vida_jefe > 0:
		# Si el ID cambió (porque sufrió un parry), este ataque se autodestruye
		if ataque_id != mi_id: return 
		
		# 1. Te persigue normal por 3 segundos
		estado = "persiguiendo"
		await get_tree().create_timer(3.0).timeout 
		if ataque_id != mi_id: return 
		
		# 2. Se detiene a prepararse (Telegrafiado)
		estado = "preparando"
		velocity = Vector3.ZERO
		await get_tree().create_timer(0.6).timeout 
		if ataque_id != mi_id: return 
		
		# 3. ¡Desata la ráfaga de 3 golpes!
		golpes_dados = 0
		while golpes_dados < 3:
			# ESCUDO 2: En plena ráfaga puede que hayas reiniciado el juego, revisamos si sigues vivo
			if not is_instance_valid(jugador): return 
			
			estado = "rafaga"
			var direccion_ataque = (jugador.global_position - global_position).normalized()
			velocity = direccion_ataque * velocidad_rafaga
			
			await get_tree().create_timer(0.2).timeout 
			if ataque_id != mi_id: return 
			
			estado = "preparando"
			velocity = Vector3.ZERO
			await get_tree().create_timer(0.3).timeout 
			if ataque_id != mi_id: return 
			
			golpes_dados += 1
			
		# 4. Termina la ráfaga, vuelve a perseguir
		estado = "persiguiendo"

# --- RECIBIR DAÑO DEL JUGADOR ---
# --- RECIBIR DAÑO DEL JUGADOR ---
func recibir_dano(cantidad = 50.0):
	print("🚨 ¡LA FLECHA SÍ ME TOCÓ! Vida antes del golpe: ", vida_jefe)
	
	if vida_jefe <= 0: return 
	
	vida_jefe -= cantidad
	
	print("🚨 Vida después del golpe: ", vida_jefe)
	
	var camara = get_viewport().get_camera_3d()
	if camara != null and camara.has_method("aplicar_temblor"):
		camara.aplicar_temblor(0.05, 0.1)
		
	if es_jefe_principal and barra_ui != null:
		barra_ui.value = vida_jefe
		print("✅ La barra UI gigante del jefe se actualizó.")
	elif not es_jefe_principal and barra_cabeza != null:
		barra_cabeza.value = vida_jefe
	
	if vida_jefe <= 0:
		print("💀 EL JEFE HA SIDO DERROTADO")
		morir_con_estilo()
		
func morir_con_estilo():
	ataque_id += 1 # Cancelamos cualquier ataque que estuviera haciendo al morir
	$CajaGolpe.queue_free()
	velocity = Vector3.ZERO
	estado = "muerto" 
	
	if barra_ui != null:
		barra_ui.visible = false
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 1.5)
	await tween.finished

	if is_instance_valid(jugador):
		jugador.sumar_punto()
		
		# Si es el jefe grande da 150 de XP, si es el élite da 40
		if es_jefe_principal:
			jugador.ganar_experiencia(150.0)
		else:
			jugador.ganar_experiencia(40.0)
			
	queue_free()

func _on_caja_golpe_body_entered(body):
	if body.is_in_group("jugador"):
		body.recibir_dano_jugador(dano_jefe, self)
		
# --- EL PARRY PERFECTO ---
func sufrir_parry():
	ataque_id += 1 # ¡ESTO MATA EL CICLO DE ATAQUE ANTERIOR!
	estado = "aturdido"
	velocity = Vector3.ZERO 
	
	$CajaGolpe.monitoring = false 
	
	# Lo dejamos babeando por 2.5 segundos
	await get_tree().create_timer(2.5).timeout 
	
	# Si no lo mataste mientras estaba aturdido y el juego sigue activo, se recupera
	if vida_jefe > 0:
		$CajaGolpe.monitoring = true
		estado = "persiguiendo"
		iniciar_ciclo_ataque() # Arranca un ciclo de ataque nuevecito

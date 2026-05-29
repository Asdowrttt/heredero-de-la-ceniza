extends CharacterBody3D

# --- ESTADÍSTICAS DEL JEFE ---
var vida_jefe = 1500.0
var velocidad_normal = 5.0
var velocidad_rafaga = 15.0
var dano_jefe = 45 
var barra_ui = null
var estado = "persiguiendo" 
var jugador = null
var golpes_dados = 0
var es_jefe_principal = true 
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# --- Control para cancelar ataques fantasma ---
var ataque_id = 0
var _muerto = false
var _golpe_cooldown = 0.0

@onready var anim: AnimationPlayer = $Mutant/AnimationPlayer
@onready var barra_cabeza = $MiniPantalla/BarraVidaJefe
@onready var caja_golpe = $CajaGolpe

var GolpeVisual = preload("res://golpe_visual.tscn")
var Impacto = preload("res://impacto.tscn")

func _ready():
	add_to_group("enemies")
	add_to_group("bosses")
	jugador = get_tree().get_first_node_in_group("jugador")
	
	scale = Vector3(2.5, 2.5, 2.5)
	
	estado = "preparando"
	velocity = Vector3.ZERO
	if anim:
		anim.play("Mutant Roaring/mixamo_com")
		await anim.animation_finished
	
	iniciar_ciclo_ataque()
	
	if not es_jefe_principal:
		if barra_cabeza != null:
			barra_cabeza.max_value = vida_jefe
			barra_cabeza.value = vida_jefe
			barra_cabeza.visible = true
	else:
		if barra_cabeza != null:
			barra_cabeza.visible = false

func _physics_process(delta):
	if not is_instance_valid(jugador): return 
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if _golpe_cooldown > 0:
		_golpe_cooldown -= delta
	
	match estado:
		"aturdido", "muerto":
			return
			
		"preparando":
			move_and_slide()
			
		"persiguiendo":
			var direccion = global_position.direction_to(jugador.global_position)
			direccion.y = 0
			velocity = direccion * velocidad_normal
			var mirada = Vector3(jugador.global_position.x, global_position.y, jugador.global_position.z)
			if global_position.distance_to(mirada) > 0.1:
				look_at(mirada, Vector3.UP)
			move_and_slide()
			if anim and anim.current_animation != "Mutant Run/mixamo_com":
				anim.play("Mutant Run/mixamo_com")
			
		"rafaga":
			var direccion = global_position.direction_to(jugador.global_position)
			direccion.y = 0
			velocity = direccion * velocidad_rafaga
			var mirada = Vector3(jugador.global_position.x, global_position.y, jugador.global_position.z)
			if global_position.distance_to(mirada) > 0.1:
				look_at(mirada, Vector3.UP)
			move_and_slide()
			
			if _golpe_cooldown <= 0:
				var dist = global_position.distance_to(jugador.global_position)
				var golpeo = false
				if dist < 3.0:
					golpeo = true
				elif caja_golpe.has_overlapping_bodies():
					var cuerpos = caja_golpe.get_overlapping_bodies()
					for cuerpo in cuerpos:
						if cuerpo.is_in_group("jugador"):
							golpeo = true
							break
				if golpeo:
					jugador.recibir_dano_jugador(dano_jefe, self)
					var imp = Impacto.instantiate()
					imp.position = jugador.global_position
					get_tree().root.add_child(imp)
					get_tree().create_timer(0.5).timeout.connect(func():
						if is_instance_valid(imp): imp.queue_free()
					)
					_golpe_cooldown = 1.0

# --- LA MÁQUINA DE ATAQUES BLINDADA ---
func iniciar_ciclo_ataque():
	ataque_id += 1 # Le damos un ID nuevo a este ciclo
	var mi_id = ataque_id # Guardamos el ID en este ataque específico
	
	while vida_jefe > 0:
		# Si el ID cambió (porque sufrió un parry), este ataque se autodestruye
		if ataque_id != mi_id: return 
		
		# 1. Te persigue normal por 4 segundos
		estado = "persiguiendo"
		if anim: anim.play("Mutant Run/mixamo_com")
		await get_tree().create_timer(4.0).timeout 
		if ataque_id != mi_id: return 
		
		# 2. Se detiene a prepararse (Telegrafiado)
		estado = "preparando"
		velocity = Vector3.ZERO
		if anim: anim.play("Mutant Roaring/mixamo_com")
		await get_tree().create_timer(0.6).timeout 
		if ataque_id != mi_id: return 
		
		# 3. ¡Desata la ráfaga de 3 golpes!
		golpes_dados = 0
		while golpes_dados < 3:
			if not is_instance_valid(jugador): return 
			
			estado = "rafaga"
			var gv = GolpeVisual.instantiate()
			add_child(gv)
			gv.position = Vector3(0, 1.5, -3)
			gv.emitting = true
			get_tree().create_timer(0.6).timeout.connect(func():
				if is_instance_valid(gv): gv.queue_free()
			)
			if anim: anim.play("Mutant Jump Attack/mixamo_com")
			await get_tree().create_timer(0.5).timeout
			if ataque_id != mi_id: return 
			
			estado = "preparando"
			velocity = Vector3.ZERO
			await get_tree().create_timer(0.6).timeout 
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
	if _muerto:
		return
	_muerto = true
	ataque_id += 1
	if anim: anim.play("Mutant Dying/mixamo_com")
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
	if anim: anim.stop()
	
	$CajaGolpe.monitoring = false 
	
	# Lo dejamos babeando por 2.5 segundos
	await get_tree().create_timer(2.5).timeout 
	
	# Si no lo mataste mientras estaba aturdido y el juego sigue activo, se recupera
	if vida_jefe > 0:
		$CajaGolpe.monitoring = true
		estado = "persiguiendo"
		iniciar_ciclo_ataque() # Arranca un ciclo de ataque nuevecito

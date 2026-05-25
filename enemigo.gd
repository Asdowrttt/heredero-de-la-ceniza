extends CharacterBody3D

const SPEED = 4.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var vida_enemigo = 100.0
@onready var barra_vida = $MiniPantalla/BarraVidaEnemigo
@onready var anim: AnimationPlayer = $Idle/AnimationPlayer


var explosion_scene = preload("res://explosion.tscn")
var jugador_en_zona = false
var tiempo_ataque = 0.0
var cadencia_ataque = 1.5 
var esta_atacando = false 

var jugador = null

func _ready():
	jugador = get_tree().get_first_node_in_group("jugador")
	anim.play("correr/mixamo_com") # Que arranque agresivo desde el inicio

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if jugador != null:
		# 1. SIEMPRE CALCULAR DIRECCIÓN Y NUNCA FRENAR
		var direccion = global_position.direction_to(jugador.global_position)
		direccion.y = 0 
		direccion = direccion.normalized()
		
		var look_target = Vector3(jugador.global_position.x, global_position.y, jugador.global_position.z)
		if global_position.distance_to(look_target) > 0.1:
			look_at(look_target, Vector3.UP)

		# Siempre le aplicamos la velocidad, esté atacando o no (efecto de embestida)
		velocity.x = direccion.x * SPEED
		velocity.z = direccion.z * SPEED

		# 2. LÓGICA DE ANIMACIONES Y ATAQUE
		if jugador_en_zona:
			tiempo_ataque += delta 
			
			# Si ya se cargó el golpe y no está a medio ataque, lo suelta
			if tiempo_ataque >= cadencia_ataque and not esta_atacando:
				soltar_madrazo()
			elif not esta_atacando:
				# Si está esperando el cooldown, sigue reproduciendo la animación de correr
				anim.play("correr/mixamo_com")
		else:
			# Si te alejas de su zona, simplemente sigue corriendo
			if not esta_atacando:
				anim.play("correr/mixamo_com", 0.3)

	move_and_slide()

# --- LA MAGIA DE LA SINCRONIZACIÓN ---	
func soltar_madrazo():
	esta_atacando = true
	tiempo_ataque = 0.0 
	
	# El 0.2 hace que combine la inercia de correr con el inicio del golpe
	anim.play("ataque/mixamo_com", 0.2) 
	
	await get_tree().create_timer(0.5).timeout
	
	if jugador_en_zona and is_instance_valid(jugador):
		jugador.recibir_dano_jugador(20) 
		
	await get_tree().create_timer(0.5).timeout
	esta_atacando = false

func recibir_dano(cantidad = 50.0):
	if vida_enemigo <= 0: return 
	vida_enemigo -= cantidad
	barra_vida.value = vida_enemigo
	
	if vida_enemigo <= 0:
		if is_instance_valid(jugador):
			jugador.sumar_punto()          
			jugador.ganar_experiencia(10.0) 
			
		var nueva_explosion = explosion_scene.instantiate()
		nueva_explosion.global_position = global_position
		get_tree().current_scene.add_child(nueva_explosion)
		queue_free()

func _on_zona_ataque_body_entered(body):
	if body.is_in_group("jugador"):
		jugador_en_zona = true
		# Opcional: si quieres que te pegue de inmediato al tocarte, descomenta esto:
		# tiempo_ataque = cadencia_ataque 

func _on_zona_ataque_body_exited(body):
	if body.is_in_group("jugador"):
		jugador_en_zona = false

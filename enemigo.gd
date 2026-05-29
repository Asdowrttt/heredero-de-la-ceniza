extends CharacterBody3D

const SPEED_BASE = 4.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var tipo = "basic"
var vida_enemigo = 100.0
var vida_maxima = 100.0
var vida_ghost = 100.0
var velocidad_ghost = 2.0
var speed = 4.0
var cadencia_ataque = 0.7
var dano_ataque = 20
var armadura_extra = 0.0

@onready var barra_vida = $MiniPantalla/BarraVidaEnemigo
@onready var barra_ghost: ProgressBar
@onready var anim: AnimationPlayer = $Idle/AnimationPlayer

var explosion_scene = preload("res://explosion.tscn")
var jugador_en_zona = false
var tiempo_ataque = 0.0
var esta_atacando = false
@onready var etiqueta_vida: Label = $MiniPantalla/EtiquetaVida

var jugador = null

func set_tipo(t: String):
	tipo = t
	match t:
		"basic":
			vida_enemigo = 100.0
			vida_maxima = 100.0
			speed = 4.0
			cadencia_ataque = 0.7
			dano_ataque = 20
			armadura_extra = 0.0
			scale = Vector3.ONE
		"shield":
			vida_enemigo = 200.0
			vida_maxima = 200.0
			speed = 3.5
			cadencia_ataque = 0.5
			dano_ataque = 15
			armadura_extra = 0.6
			scale = Vector3.ONE
		"elite":
			vida_enemigo = 500.0
			vida_maxima = 500.0
			speed = 5.0
			cadencia_ataque = 0.4
			dano_ataque = 40
			armadura_extra = 0.3
			scale = Vector3(1.5, 1.5, 1.5)
	if barra_vida:
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida_enemigo
	if barra_ghost:
		barra_ghost.max_value = vida_maxima
		barra_ghost.value = vida_enemigo

func _ready():
	add_to_group("enemies")
	jugador = get_tree().get_first_node_in_group("jugador")
	anim.play("correr/mixamo_com")
	
	_crear_barra_ghost()
	_estilizar_barras_ds()
	
	vida_ghost = vida_enemigo
	barra_vida.max_value = vida_maxima
	barra_vida.value = vida_enemigo
	
	if barra_ghost:
		barra_ghost.max_value = vida_maxima
		barra_ghost.value = vida_enemigo
	
	_actualizar_label_vida()
	
	# Color tint per type
	var tint = _tint_color()
	if tint:
		var meshes = find_children("*", "MeshInstance3D", true)
		for m in meshes:
			if m.material_override and m.material_override is StandardMaterial3D:
				var mat = m.material_override.duplicate()
				mat.albedo_color = mat.albedo_color.lerp(tint, 0.35)
				m.material_override = mat

func _tint_color() -> Color:
	match tipo:
		"shield": return Color(0.3, 0.25, 0.4)
		"elite": return Color(0.5, 0.15, 0.1)
		_: return Color.WHITE

func _crear_barra_ghost():
	if $MiniPantalla.has_node("BarraGhost"):
		barra_ghost = $MiniPantalla/BarraGhost
		return
	
	barra_ghost = ProgressBar.new()
	barra_ghost.name = "BarraGhost"
	barra_ghost.anchors_preset = Control.PRESET_FULL_RECT
	barra_ghost.offset_left = 0.0
	barra_ghost.offset_top = 0.0
	barra_ghost.offset_right = 200.0
	barra_ghost.offset_bottom = 30.0
	barra_ghost.show_percentage = false
	barra_ghost.z_index = -1
	
	$MiniPantalla.add_child(barra_ghost)
	
	if barra_vida:
		barra_ghost.move_to_front()
		barra_vida.move_to_front()

func _estilizar_barras_ds():
	var estilo_fondo = StyleBoxFlat.new()
	estilo_fondo.bg_color = Color(0.06, 0.04, 0.04, 1)
	estilo_fondo.border_color = Color(0.25, 0.18, 0.1, 1)
	estilo_fondo.set_border_width_all(2)
	estilo_fondo.set_content_margin_all(1)
	
	var estilo_fill_vida = StyleBoxFlat.new()
	estilo_fill_vida.bg_color = Color(0.55, 0.08, 0.06, 1)
	estilo_fill_vida.set_content_margin_all(0)
	
	var estilo_fill_ghost = StyleBoxFlat.new()
	estilo_fill_ghost.bg_color = Color(0.25, 0.15, 0.12, 1)
	estilo_fill_ghost.set_content_margin_all(0)
	
	if barra_vida:
		barra_vida.add_theme_stylebox_override("background", estilo_fondo)
		barra_vida.add_theme_stylebox_override("fill", estilo_fill_vida)
		barra_vida.custom_minimum_size.y = 14.0
	
	if barra_ghost:
		barra_ghost.add_theme_stylebox_override("background", estilo_fondo)
		barra_ghost.add_theme_stylebox_override("fill", estilo_fill_ghost)

func _actualizar_label_vida():
	if etiqueta_vida:
		var txt = str(ceili(vida_enemigo)) + "/" + str(vida_maxima)
		if etiqueta_vida.text != txt:
			etiqueta_vida.text = txt

func _process(delta):
	if etiqueta_vida:
		_actualizar_label_vida()
	if barra_ghost and vida_ghost > vida_enemigo:
		vida_ghost = lerp(vida_ghost, vida_enemigo, delta * velocidad_ghost)
		if abs(vida_ghost - vida_enemigo) < 0.1:
			vida_ghost = vida_enemigo
		barra_ghost.value = vida_ghost

var _vault_cooldown = 0.0

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	_vault_cooldown = max(0, _vault_cooldown - delta)

	if jugador != null:
		var direccion = global_position.direction_to(jugador.global_position)
		direccion.y = 0
		direccion = direccion.normalized()

		var look_target = Vector3(jugador.global_position.x, global_position.y, jugador.global_position.z)
		if global_position.distance_to(look_target) > 0.1:
			look_at(look_target, Vector3.UP)

		var separacion = Vector3.ZERO
		for e in get_tree().get_nodes_in_group("enemies"):
			if e == self or not is_instance_valid(e):
				continue
			var dist = global_position.distance_squared_to(e.global_position)
			if dist < 9.0 and dist > 0.01:
				separacion += (global_position - e.global_position).normalized() * (1.0 - dist / 9.0)

		var move_dir = direccion + separacion * 2.0
		move_dir = move_dir.normalized()

		if tipo == "shield" and global_position.distance_to(jugador.global_position) < 8.0:
			velocity.x = move_dir.x * speed * 0.6
			velocity.z = move_dir.z * speed * 0.6
		else:
			velocity.x = move_dir.x * speed
			velocity.z = move_dir.z * speed

		if jugador_en_zona:
			tiempo_ataque += delta
			if tiempo_ataque >= cadencia_ataque and not esta_atacando:
				soltar_madrazo()

	if not _step_up() and is_on_floor() and _vault_cooldown <= 0 and velocity.length_squared() > 1.0:
		var ahead = Vector3(velocity.x, 0, velocity.z).normalized() * 0.3
		if test_move(global_transform, ahead):
			_vault_cooldown = 1.0
			velocity.y = 10.0

	move_and_slide()

func soltar_madrazo():
	esta_atacando = true
	tiempo_ataque = 0.0

	if anim.has_animation("ataque/mixamo_com"):
		anim.play("ataque/mixamo_com")
		var attack_len = anim.get_animation("ataque/mixamo_com").length
		var impact_time = max(0.15, attack_len * 0.15)
		await get_tree().create_timer(impact_time).timeout
	else:
		await get_tree().create_timer(0.15).timeout

	if jugador_en_zona and is_instance_valid(jugador):
		jugador.recibir_dano_jugador(dano_ataque)

	await get_tree().create_timer(0.2).timeout
	anim.play("correr/mixamo_com")
	esta_atacando = false

func recibir_dano(cantidad = 50.0):
	if vida_enemigo <= 0 or not is_inside_tree():
		return
	var dano_final = cantidad * (1.0 - armadura_extra)
	vida_enemigo -= dano_final
	if barra_vida and is_instance_valid(barra_vida):
		barra_vida.value = vida_enemigo
	
	_actualizar_label_vida()
	
	if vida_ghost < vida_enemigo:
		vida_ghost = vida_enemigo

	if vida_enemigo <= 0:
		if barra_ghost and is_instance_valid(barra_ghost):
			barra_ghost.queue_free()
		if is_instance_valid(jugador):
			jugador.sumar_punto()
			jugador.ganar_experiencia(10.0)

		var nueva_explosion = explosion_scene.instantiate()
		nueva_explosion.global_position = global_position
		if is_inside_tree():
			get_tree().current_scene.add_child(nueva_explosion)
		queue_free()

func _on_zona_ataque_body_entered(body):
	if body.is_in_group("jugador"):
		jugador_en_zona = true

func _on_zona_ataque_body_exited(body):
	if body.is_in_group("jugador"):
		jugador_en_zona = false

func _step_up() -> bool:
	if not is_on_floor() or velocity.length_squared() < 1.0:
		return false
	var ahead = Vector3(velocity.x, 0, velocity.z).normalized() * 0.3

	if not test_move(global_transform, ahead):
		return false

	for sh in [0.5, 1.5, 3.0, 5.0]:
		if not test_move(global_transform, Vector3(0, sh, 0)):
			var xform = global_transform
			xform.origin.y += sh
			if not test_move(xform, ahead):
				global_position.y += sh
				return true
	return false

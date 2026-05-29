extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var dist_ideal = 12.0
var dist_huida = 6.0
var cadencia_disparo = 2.0

var vida = 80.0
var vida_maxima = 80.0
var speed = 3.0
var dano_proyectil = 15.0
var vida_ghost = 80.0

var jugador = null
var tiempo_ultimo_disparo = 0.0
var esta_atacando = false
var esta_muerto = false

@onready var anim_player: AnimationPlayer = $Magician/AnimationPlayer
@onready var punto_disparo: Marker3D = $PuntoDisparo
@onready var barra_vida = $MiniPantalla/BarraVidaEnemigo
@onready var etiqueta_vida: Label = $MiniPantalla/EtiquetaVida
var barra_ghost: ProgressBar

var proyectil_scene = preload("res://magia_enemiga.tscn")
var explosion_scene = preload("res://explosion.tscn")

func _ready():
	add_to_group("enemies")
	jugador = get_tree().get_first_node_in_group("jugador")
	_crear_barra_ghost()
	_estilizar_barras_ds()
	vida_ghost = vida_maxima
	barra_vida.max_value = vida_maxima
	barra_vida.value = vida_maxima
	if barra_ghost:
		barra_ghost.max_value = vida_maxima
		barra_ghost.value = vida_maxima
	anim_player.play("Armature_001|Idle")
	_tint_morado()
	_actualizar_label_vida()

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
		etiqueta_vida.text = str(ceili(vida)) + "/" + str(vida_maxima)

func _process(delta):
	if barra_ghost and vida_ghost > vida:
		vida_ghost = lerp(vida_ghost, vida, delta * 2.0)
		if abs(vida_ghost - vida) < 0.1:
			vida_ghost = vida
		barra_ghost.value = vida_ghost
	if etiqueta_vida:
		var txt = str(ceili(vida)) + "/" + str(vida_maxima)
		if etiqueta_vida.text != txt:
			etiqueta_vida.text = txt

func _physics_process(delta):
	if esta_muerto:
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
	if jugador == null or not is_instance_valid(jugador):
		move_and_slide()
		if is_on_floor():
			global_position.y += 0.25
		return
	var dir = global_position.direction_to(jugador.global_position)
	dir.y = 0
	var dist = global_position.distance_to(jugador.global_position)
	var look_target = Vector3(jugador.global_position.x, global_position.y, jugador.global_position.z)
	if dist > 0.1:
		look_at(look_target, Vector3.UP)
	var separacion = Vector3.ZERO
	for e in get_tree().get_nodes_in_group("enemies"):
		if e == self or not is_instance_valid(e):
			continue
		var d2 = global_position.distance_squared_to(e.global_position)
		if d2 < 9.0 and d2 > 0.01:
			separacion += (global_position - e.global_position).normalized() * (1.0 - d2 / 9.0)

	var move_dir = dir + separacion * 2.0
	move_dir = move_dir.normalized()

	if dist < dist_huida:
		velocity = -move_dir * speed
	elif dist > dist_ideal + 3.0:
		velocity = move_dir * speed
	else:
		velocity = Vector3.ZERO
		if dist < dist_ideal + 1.0:
			var strafe = global_transform.basis.x * (1.0 if randf() > 0.5 else -1.0)
			velocity = strafe * speed * 0.3
	tiempo_ultimo_disparo += delta
	if dist < 22.0 and tiempo_ultimo_disparo >= cadencia_disparo and not esta_atacando:
		_disparar()
	move_and_slide()
	if is_on_floor():
		global_position.y += 0.25

func _disparar():
	esta_atacando = true
	tiempo_ultimo_disparo = 0.0
	if anim_player.has_animation("Armature_001|MagicianShootSpell"):
		anim_player.play("Armature_001|MagicianShootSpell")
	await get_tree().create_timer(0.3).timeout
	if not is_inside_tree() or esta_muerto:
		return
	var proy = proyectil_scene.instantiate()
	get_tree().current_scene.add_child(proy)
	if punto_disparo:
		proy.global_transform = Transform3D(global_transform.basis, punto_disparo.global_position)
	else:
		var spawn_pos = global_position + Vector3(0, 1.2, 0) + (-global_transform.basis.z * 1.5)
		proy.global_transform = Transform3D(global_transform.basis, spawn_pos)
	if "dano" in proy:
		proy.dano = dano_proyectil
	await get_tree().create_timer(0.5).timeout
	if not is_inside_tree() or esta_muerto:
		return
	anim_player.play("Armature_001|Idle")
	esta_atacando = false

func recibir_dano(cantidad = 50.0):
	if vida <= 0 or not is_inside_tree():
		return
	vida -= cantidad
	if barra_vida and is_instance_valid(barra_vida):
		barra_vida.value = vida
	_actualizar_label_vida()
	if vida_ghost < vida:
		vida_ghost = vida
	if vida <= 0:
		_morir()

func _morir():
	esta_muerto = true
	if barra_ghost and is_instance_valid(barra_ghost):
		barra_ghost.queue_free()
	if is_instance_valid(jugador):
		jugador.sumar_punto()
		jugador.ganar_experiencia(15.0)
	anim_player.play("Armature_001|Idle")
	await get_tree().create_timer(0.2).timeout
	if not is_inside_tree():
		return
	var nueva_explosion = explosion_scene.instantiate()
	nueva_explosion.global_position = global_position
	get_tree().current_scene.add_child(nueva_explosion)
	queue_free()

func _tint_morado():
	var meshes = find_children("*", "MeshInstance3D", true)
	for m in meshes:
		if m.material_override and m.material_override is StandardMaterial3D:
			var mat = m.material_override.duplicate()
			mat.albedo_color = mat.albedo_color.lerp(Color(0.4, 0.15, 0.55), 0.4)
			m.material_override = mat

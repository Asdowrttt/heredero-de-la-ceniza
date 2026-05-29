extends Node3D

signal phase_changed(phase: int)
signal climax_started()

const TOTAL_TIME = 900.0

var enemigo_scene = preload("res://enemigo.tscn")
var enemigo_mago_scene = preload("res://enemigo_mago.tscn")
var jefe_scene = preload("res://jefe.tscn")
var explosion_scene = preload("res://explosion.tscn")

var game_time = 0.0
var current_phase = 1
var climax_triggered = false

@onready var spawn_timer = $SpawnTimer
var _timer_label: Label = null
var _announce_label: Label = null
var _arena_walls: Array[StaticBody3D] = []

func _ready():
	add_to_group("director")
	spawn_timer.timeout.connect(_on_spawn)
	_apply_phase_settings()
	await get_tree().process_frame
	_setup_ui()

func _setup_ui():
	var jugador = get_tree().get_first_node_in_group("jugador")
	if not jugador or not jugador.has_node("HUD"):
		return
	var hud = jugador.get_node("HUD")

	var tl = Label.new()
	tl.name = "TimerLabel"
	tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tl.add_theme_font_size_override("font_size", 36)
	tl.add_theme_color_override("font_color", Color(0.85, 0.8, 0.6))
	tl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	tl.add_theme_constant_override("shadow_offset_x", 2)
	tl.add_theme_constant_override("shadow_offset_y", 2)
	tl.size = Vector2(140, 40)
	tl.anchors_preset = Control.PRESET_TOP_WIDE
	tl.offset_top = 20
	hud.add_child(tl)
	_timer_label = tl

	var al = Label.new()
	al.name = "AnnounceLabel"
	al.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	al.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	al.add_theme_font_size_override("font_size", 44)
	al.add_theme_color_override("font_color", Color(0.8, 0.7, 0.4))
	al.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	al.add_theme_constant_override("shadow_offset_x", 3)
	al.add_theme_constant_override("shadow_offset_y", 3)
	al.size = Vector2(500, 60)
	al.anchors_preset = Control.PRESET_CENTER
	al.offset_top = -30
	hud.add_child(al)
	_announce_label = al

func _process(delta):
	if climax_triggered:
		return

	game_time += delta

	var new_phase = _calc_phase()
	if new_phase != current_phase:
		current_phase = new_phase
		phase_changed.emit(current_phase)
		_apply_phase_settings()
		_announce_phase()

	if _timer_label:
		var t = _time_string()
		if _timer_label.text != t:
			_timer_label.text = t
		if game_time > 600.0:
			_timer_label.add_theme_color_override("font_color", Color(0.9, 0.5, 0.2))
		elif game_time > 300.0:
			_timer_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.3))
		else:
			_timer_label.add_theme_color_override("font_color", Color(0.85, 0.8, 0.6))

	if game_time >= TOTAL_TIME and not climax_triggered:
		_trigger_climax()

func _time_string() -> String:
	var remaining = max(0, TOTAL_TIME - game_time)
	var m = int(remaining) / 60
	var s = int(remaining) % 60
	return "%02d:%02d" % [m, s]

func _calc_phase() -> int:
	if game_time < 300.0:
		return 1
	elif game_time < 600.0:
		return 2
	else:
		return 3

func _apply_phase_settings():
	match current_phase:
		1:
			spawn_timer.wait_time = 2.0
		2:
			spawn_timer.wait_time = 1.0
		3:
			spawn_timer.wait_time = 0.5

func _announce_phase():
	var texts = {
		1: "FASE 1: RECONOCIMIENTO",
		2: "FASE 2: LA HORDA",
		3: "FASE 3: EL ENJAMBRE"
	}
	_show_announcement(texts.get(current_phase, ""), Color(0.8, 0.7, 0.4))

func _show_announcement(text: String, color: Color = Color(0.8, 0.7, 0.4)):
	if not _announce_label:
		return
	_announce_label.text = text
	_announce_label.add_theme_color_override("font_color", color)
	_announce_label.visible = true
	_announce_label.modulate = Color(1, 1, 1, 1)
	var tween = create_tween()
	tween.tween_property(_announce_label, "modulate", Color(1, 1, 1, 0), 2.5)
	await tween.finished
	if is_instance_valid(_announce_label):
		_announce_label.visible = false

func _on_spawn():
	if climax_triggered:
		return
	var jugador = get_tree().get_first_node_in_group("jugador")
	if not jugador or not is_instance_valid(jugador) or not jugador.is_inside_tree():
		return

	var types = _get_spawn_types()
	for type in types:
		_spawn_single(type, jugador)

func _get_spawn_types() -> Array:
	match current_phase:
		1:
			if randf() < 0.35:
				return ["mage"]
			return ["basic"]
		2:
			var r = randf()
			if r < 0.15:
				return ["mage"]
			elif r < 0.50:
				return ["shield"]
			elif r < 0.65:
				return ["mage", "basic"]
			return ["basic"]
		3:
			var count = 1 if randf() < 0.5 else 2
			var result = []
			for _i in range(count):
				var r = randf()
				if r < 0.15:
					result.append("mage")
				elif r < 0.35:
					result.append("elite")
				elif r < 0.55:
					result.append("shield")
				else:
					result.append("basic")
			return result
	return ["basic"]

func _spawn_single(type: String, jugador):
	var pos = _posicion_libre(jugador.global_position)
	if pos == Vector3.ZERO:
		return

	if type == "mage":
		var enemy = enemigo_mago_scene.instantiate()
		enemy.global_position = pos
		add_child(enemy)
		return
	var enemy = enemigo_scene.instantiate()
	enemy.global_position = pos
	if enemy.has_method("set_tipo"):
		enemy.set_tipo(type)
	add_child(enemy)

func _posicion_libre(centro: Vector3) -> Vector3:
	for _intento in 10:
		var angle = randf_range(0, TAU)
		var radius = randf_range(25, 38)
		var pos = centro + Vector3(cos(angle), 0, sin(angle)) * radius
		pos.y = 2.0
		pos.x = clamp(pos.x, -68, 68)
		pos.z = clamp(pos.z, -68, 68)

		var libre = true
		for e in get_tree().get_nodes_in_group("enemies"):
			if not is_instance_valid(e):
				continue
			if e.global_position.distance_squared_to(pos) < 25.0:
				libre = false
				break
		if libre:
			return pos
	return Vector3.ZERO

func _trigger_climax():
	climax_triggered = true
	spawn_timer.stop()
	climax_started.emit()

	_show_announcement("¡EL JEFE HA LLEGADO!", Color(0.9, 0.3, 0.15))

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		var expl = explosion_scene.instantiate()
		expl.global_position = enemy.global_position
		get_tree().current_scene.add_child(expl)
		enemy.queue_free()

	_lock_arena()

	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		var cam = jugador.get_viewport().get_camera_3d()
		if cam and cam.has_method("aplicar_temblor"):
			cam.aplicar_temblor(0.5, 0.8)

		if jugador.has_node("HUD"):
			var overlay = ColorRect.new()
			overlay.name = "ClimaxOverlay"
			overlay.color = Color(0, 0, 0, 0)
			overlay.size = Vector2(2000, 2000)
			overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
			jugador.get_node("HUD").add_child(overlay)
			var tween = create_tween()
			tween.tween_property(overlay, "color", Color(0, 0, 0, 0.35), 2.0)

	await get_tree().create_timer(1.5).timeout

	var jefe = jefe_scene.instantiate()
	jefe.es_jefe_principal = true
	jefe.vida_jefe = 1500.0
	get_tree().current_scene.add_child(jefe)
	jefe.global_position = Vector3(0, 2, 0)

	if jugador:
		if jugador.has_node("HUD/BarraJefe"):
			var barra = jugador.get_node("HUD/BarraJefe")
			barra.max_value = jefe.vida_jefe
			barra.value = jefe.vida_jefe
			barra.visible = true
			jefe.barra_ui = barra

func _lock_arena():
	var exits = [
		{"pos": Vector3(0, 2.5, -30), "size": Vector3(8, 6, 1)},
		{"pos": Vector3(-30, 2.5, 29), "size": Vector3(4, 6, 1)},
		{"pos": Vector3(29, 2.5, 0), "size": Vector3(1, 6, 12)},
		{"pos": Vector3(-29, 2.5, 0), "size": Vector3(1, 6, 12)},
	]
	for exit in exits:
		var wall = StaticBody3D.new()
		wall.position = exit["pos"]
		var col = CollisionShape3D.new()
		col.shape = BoxShape3D.new()
		col.shape.size = exit["size"]
		wall.add_child(col)
		get_tree().current_scene.add_child(wall)
		_arena_walls.append(wall)

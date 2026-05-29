extends Control

var full_map := false
var radar_radius := 35.0
var _world_bounds: Rect2
var _player_pos := Vector2.ZERO
var _player_forward := Vector2(0, -1)
var _enemy_positions: Array[Vector2] = []
var _boss_positions: Array[Vector2] = []
var _walls: Array[Rect2] = []
var _towers: Array[Rect2] = []
var _pillars: Array[Rect2] = []
var _has_data := false

func _ready():
	var world = get_tree().current_scene
	if not world:
		return
	var arena = world.find_child("Arena", true, false)
	if not arena:
		return
	var first = true
	for child in arena.get_children():
		if child is CSGBox3D:
			var p = child.global_position
			var h = child.size / 2.0
			var r = Rect2(p.x - h.x, p.z - h.z, child.size.x, child.size.z)
			if first:
				_world_bounds = r
				first = false
			else:
				_world_bounds = _world_bounds.merge(r)
			var n = child.name.to_lower()
			if "tower" in n or "wall" in n or "divider" in n or "battlement" in n:
				_walls.append(r)
			elif "pillar" in n:
				_pillars.append(r)
			elif "tower" in n or "base" in n:
				_towers.append(r)
	_has_data = true

func _process(_delta):
	if not _has_data:
		return
	var world = get_tree().current_scene
	if not world:
		return
	var player = world.find_child("Jugador", true, false)
	if player:
		_player_pos = Vector2(player.global_position.x, player.global_position.z)
		var fwd = -player.global_transform.basis.z
		_player_forward = Vector2(fwd.x, fwd.z).normalized()
	var enemies = get_tree().get_nodes_in_group("enemies")
	_enemy_positions.clear()
	for e in enemies:
		if is_instance_valid(e) and not e.is_in_group("bosses"):
			_enemy_positions.append(Vector2(e.global_position.x, e.global_position.z))
	var bosses = get_tree().get_nodes_in_group("bosses")
	_boss_positions.clear()
	for b in bosses:
		if is_instance_valid(b):
			_boss_positions.append(Vector2(b.global_position.x, b.global_position.z))
	queue_redraw()

func _draw():
	if not _has_data:
		return
	var csize = size
	if csize.x <= 0 or csize.y <= 0:
		csize = Vector2(200, 200)
	
	if full_map:
		_draw_full(csize)
	else:
		_draw_radar(csize)

func _draw_full(csize: Vector2):
	var scl = csize / _world_bounds.size
	draw_rect(Rect2(Vector2(), csize), Color(0.06, 0.05, 0.04))
	var bw = _world_bounds.position
	for r in _walls:
		draw_rect(Rect2((r.position - bw) * scl, r.size * scl), Color(0.45, 0.38, 0.32), true)
	for r in _towers:
		draw_rect(Rect2((r.position - bw) * scl, r.size * scl), Color(0.35, 0.2, 0.15), true)
	for r in _pillars:
		draw_rect(Rect2((r.position - bw) * scl, r.size * scl), Color(0.25, 0.22, 0.18), true)
	var pl = (_player_pos - bw) * scl
	draw_circle(pl, max(3.0, 4.0 * min(scl.x, scl.y)), Color(0.3, 0.9, 1.0))
	for epos in _enemy_positions:
		draw_circle((epos - bw) * scl, max(2.0, 2.5 * min(scl.x, scl.y)), Color(0.95, 0.15, 0.1))
	for bpos in _boss_positions:
		draw_circle((bpos - bw) * scl, max(3.0, 4.0 * min(scl.x, scl.y)), Color(1.0, 0.7, 0.1))

func _draw_radar(csize: Vector2):
	var center = csize / 2.0
	var radius = min(csize.x, csize.y) / 2.0 - 6.0
	if radius < 10:
		return
	
	# Background
	draw_circle(center, radius, Color(0.05, 0.04, 0.03))
	draw_circle(center, radius, Color(0.1, 0.08, 0.05), false, 2.0)
	
	# Inner ring at half radius
	draw_arc(center, radius * 0.5, 0, TAU, 48, Color(0.15, 0.12, 0.08), 1.0, true)
	
	# Cross lines
	draw_line(Vector2(center.x - radius, center.y), Vector2(center.x + radius, center.y), Color(0.12, 0.1, 0.06), 1.0)
	draw_line(Vector2(center.x, center.y - radius), Vector2(center.x, center.y + radius), Color(0.12, 0.1, 0.06), 1.0)
	
	var zoom = radius / radar_radius
	
	# Draw walls within range
	for r in _walls:
		var rel = Vector2(
			(r.position.x + r.size.x / 2.0) - _player_pos.x,
			(r.position.y + r.size.y / 2.0) - _player_pos.y
		)
		if rel.length() > radar_radius + max(r.size.x, r.size.y) * 0.5:
			continue
		var screen_r = Rect2(
			center + (Vector2(r.position.x, r.position.y) - _player_pos) * zoom,
			r.size * zoom
		)
		if screen_r.position.x + screen_r.size.x < 0 or screen_r.position.x > csize.x:
			continue
		if screen_r.position.y + screen_r.size.y < 0 or screen_r.position.y > csize.y:
			continue
		draw_rect(screen_r, Color(0.5, 0.42, 0.35), true)
	
	for r in _pillars:
		var rel = Vector2(
			(r.position.x + r.size.x / 2.0) - _player_pos.x,
			(r.position.y + r.size.y / 2.0) - _player_pos.y
		)
		if rel.length() > radar_radius + max(r.size.x, r.size.y) * 0.5:
			continue
		var screen_r = Rect2(
			center + (Vector2(r.position.x, r.position.y) - _player_pos) * zoom,
			r.size * zoom
		)
		draw_rect(screen_r, Color(0.3, 0.25, 0.2), true)
	
	# Draw enemies
	for epos in _enemy_positions:
		var rel = epos - _player_pos
		if rel.length() > radar_radius:
			continue
		var spos = center + rel * zoom
		draw_circle(spos, max(2.0, 3.0 * zoom), Color(0.95, 0.15, 0.1))
	for bpos in _boss_positions:
		var rel = bpos - _player_pos
		if rel.length() > radar_radius:
			continue
		var spos = center + rel * zoom
		draw_circle(spos, max(3.0, 4.5 * zoom), Color(1.0, 0.7, 0.1))
	
	# Player at center (diamond shape)
	var ps := 4.0
	draw_line(Vector2(center.x, center.y - ps), Vector2(center.x + ps, center.y), Color(0.3, 0.9, 1.0), 2.0)
	draw_line(Vector2(center.x + ps, center.y), Vector2(center.x, center.y + ps), Color(0.3, 0.9, 1.0), 2.0)
	draw_line(Vector2(center.x, center.y + ps), Vector2(center.x - ps, center.y), Color(0.3, 0.9, 1.0), 2.0)
	draw_line(Vector2(center.x - ps, center.y), Vector2(center.x, center.y - ps), Color(0.3, 0.9, 1.0), 2.0)
	
	# Direction indicator
	var dir_end = center + _player_forward * radius * 0.35
	draw_line(center, dir_end, Color(0.3, 0.9, 1.0, 0.6), 1.5)

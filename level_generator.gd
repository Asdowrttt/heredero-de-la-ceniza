extends Node3D

var _m_floor: StandardMaterial3D
var _m_wall: StandardMaterial3D
var _m_pillar: StandardMaterial3D
var _m_marble: StandardMaterial3D
var _m_altar: StandardMaterial3D
var _m_tomb: StandardMaterial3D
var _m_trim: StandardMaterial3D

func _ready():
	_make_materials()
	_cathedral()
	_crypt()
	_ruins()
	_grand_stair()
	_overlook()
	_paths()
	_lights()
	_atmo()

func _make_materials():
	_m_floor = StandardMaterial3D.new()
	_m_floor.albedo_color = Color(0.10, 0.09, 0.08); _m_floor.roughness = 0.95
	_m_wall = StandardMaterial3D.new()
	_m_wall.albedo_color = Color(0.16, 0.14, 0.12); _m_wall.roughness = 0.85
	_m_pillar = StandardMaterial3D.new()
	_m_pillar.albedo_color = Color(0.13, 0.12, 0.11); _m_pillar.roughness = 0.9
	_m_marble = StandardMaterial3D.new()
	_m_marble.albedo_color = Color(0.26, 0.24, 0.21); _m_marble.roughness = 0.5; _m_marble.metallic = 0.15
	_m_altar = StandardMaterial3D.new()
	_m_altar.albedo_color = Color(0.20, 0.16, 0.12); _m_altar.roughness = 0.4; _m_altar.metallic = 0.3
	_m_tomb = StandardMaterial3D.new()
	_m_tomb.albedo_color = Color(0.17, 0.15, 0.13); _m_tomb.roughness = 0.75
	_m_trim = StandardMaterial3D.new()
	_m_trim.albedo_color = Color(0.22, 0.20, 0.17); _m_trim.roughness = 0.6; _m_trim.metallic = 0.2

func _step(pos: Vector3, s: Vector3, mat: Material) -> StaticBody3D:
	var b = StaticBody3D.new(); b.position = pos
	var c = CollisionShape3D.new(); c.shape = BoxShape3D.new(); c.shape.size = s; b.add_child(c)
	var m = MeshInstance3D.new(); m.mesh = BoxMesh.new(); m.mesh.size = s; m.material_override = mat; b.add_child(m)
	add_child(b); return b

func _csg(s: Vector3, p: Vector3, m: Material, col: bool = true) -> CSGBox3D:
	var b = CSGBox3D.new(); b.size = s; b.position = p; b.material = m; b.use_collision = col
	add_child(b); return b

func _sn(start: Vector3, n: int, h: float, d: float, mat: Material, dx: float = 0.0, desc: bool = false):
	var dir = -1.0 if desc else 1.0
	for i in range(n):
		var y = start.y + (i + 0.5) * h * dir
		var z = start.z - (i + 0.5) * d
		_step(Vector3(dx, y, z), Vector3(3.0, h, d), mat)

func _se(start: Vector3, n: int, h: float, d: float, mat: Material, dz: float = 0.0):
	for i in range(n):
		var y = start.y + (i + 0.5) * h
		var x = start.x + (i + 0.5) * d
		_step(Vector3(x, y, dz), Vector3(d, h, 3.0), mat)

# ════════════════════════════════
# CATHEDRAL — north: z=-33 to -60
# ════════════════════════════════
func _cathedral():
	var w=_m_wall; var p=_m_pillar; var m=_m_marble; var a=_m_altar; var t=_m_trim
	
	# Floor
	_step(Vector3(0,0.65,-46), Vector3(24,0.3,28), m)
	
	# Flat path through north wall gap (no stairs)
	_step(Vector3(0,0.5,-30), Vector3(6,0.1,8), _m_floor)
	
	# Side walls with window gaps
	for z in [-38,-44,-50,-56]:
		_csg(Vector3(5,6.0,0.4), Vector3(-10,3.5,z), w)
		_csg(Vector3(5,6.0,0.4), Vector3(10,3.5,z), w)
		var dark = StandardMaterial3D.new()
		dark.albedo_color = Color(0.02,0.01,0.02)
		dark.emission_enabled=true; dark.emission=Color(0.05,0.02,0.1)
		_csg(Vector3(3,2.5,0.1), Vector3(-10,3.5,z), dark)
		_csg(Vector3(3,2.5,0.1), Vector3(10,3.5,z), dark)
	
	# Back wall
	var glass = StandardMaterial3D.new()
	glass.albedo_color=Color(0.05,0.02,0.08); glass.emission_enabled=true
	glass.emission=Color(0.08,0.03,0.12); glass.emission_energy_multiplier=0.5
	_csg(Vector3(18,7.0,0.3), Vector3(0,4.0,-60), w)
	_csg(Vector3(10,4.0,0.2), Vector3(0,4.5,-60.1), glass)
	for x in [-8,-4,4,8]:
		_csg(Vector3(0.6,7.0,0.5), Vector3(x,4.0,-59.8), t)
	
	# Columns
	for x in [-7,7]:
		for z in [-36,-42,-48,-54]:
			_step(Vector3(x,0.9,z), Vector3(1.4,0.4,1.4), t)
			_csg(Vector3(0.9,6.5,0.9), Vector3(x,4.35,z), p)
			_csg(Vector3(0.25,0.2,14), Vector3(x,8.0,z), p)
	
	# Altar
	_step(Vector3(0,1.25,-58), Vector3(5,1.5,3), a)
	_step(Vector3(0,2.0,-58.5), Vector3(3,0.5,1.5), a)
	
	var candle=StandardMaterial3D.new()
	candle.albedo_color=Color(1.0,0.7,0.2); candle.emission_enabled=true
	candle.emission=Color(1.0,0.5,0.1); candle.emission_energy_multiplier=3.0
	_step(Vector3(-1.5,1.8,-58.5), Vector3(0.15,0.5,0.15), candle)
	_step(Vector3(1.5,1.8,-58.5), Vector3(0.15,0.5,0.15), candle)
	_step(Vector3(0,1.6,-58.5), Vector3(0.15,0.4,0.15), candle)
	
	# Pews
	for z in [-38,-42,-46]:
		_step(Vector3(-6,0.9,z), Vector3(4,0.8,1.2), p)
		_step(Vector3(6,0.9,z), Vector3(4,0.8,1.2), p)

# ════════════════════════════════
# CRYPT — east: x=29 to 55, z=10-40
# ════════════════════════════════
func _crypt():
	var w=_m_wall; var p=_m_pillar; var t=_m_tomb
	
	_step(Vector3(29,0.65,0), Vector3(6,0.3,8), _m_marble)
	_csg(Vector3(0.4,3.0,0.4), Vector3(29,1.5,-5), p)
	_csg(Vector3(0.4,3.0,0.4), Vector3(29,1.5,5), p)
	_csg(Vector3(0.4,0.5,10), Vector3(29.5,3.2,0), p)
	
	_step(Vector3(44,0.65,25), Vector3(22,0.3,28), _m_floor)
	
	_csg(Vector3(0.5,3.5,30), Vector3(56,2.0,25), w)
	_csg(Vector3(22,3.5,0.5), Vector3(44,2.0,40), w)
	_csg(Vector3(22,3.5,0.5), Vector3(44,2.0,10), w)
	
	for x in [36,44,52]:
		for z in [16,25,34]:
			_csg(Vector3(0.7,3.5,0.7), Vector3(x,2.0,z), p)
			_step(Vector3(x,0.9,z), Vector3(0.9,0.2,0.9), _m_trim)
			_csg(Vector3(0.3,0.4,7), Vector3(x,3.5,25), w)
	
	for z in [12,22,32]:
		_csg(Vector3(24,0.2,0.5), Vector3(44,3.5,z), w)
	
	var tombs=[Vector3(38,0.8,14), Vector3(38,0.8,24), Vector3(38,0.8,34),
			   Vector3(48,0.8,18), Vector3(48,0.8,28), Vector3(48,0.8,36)]
	for tp in tombs:
		_step(tp, Vector3(1.8,0.7,3.2), t)
		_step(Vector3(tp.x,tp.y+0.5,tp.z), Vector3(2.0,0.15,3.4), _m_marble)
	
	for z in [16,26,36]:
		_csg(Vector3(1.5,2.5,1.2), Vector3(55,1.5,z), w)
		var cn=StandardMaterial3D.new()
		cn.albedo_color=Color(0.9,0.6,0.2); cn.emission_enabled=true
		cn.emission=Color(0.9,0.4,0.1); cn.emission_energy_multiplier=2.0
		_step(Vector3(55.3,1.8,z), Vector3(0.12,0.3,0.12), cn)

# ════════════════════════════════
# RUINS — southwest: x=-36 to -62
# ════════════════════════════════
func _ruins():
	var w=_m_wall; var p=_m_pillar
	
	_step(Vector3(-48,0.65,32), Vector3(26,0.3,32), _m_floor)
	
	var cols=[
		{"x":-38,"z":20,"h":3.5,"br":false},
		{"x":-38,"z":34,"h":2.0,"br":true},
		{"x":-38,"z":46,"h":4.5,"br":false},
		{"x":-48,"z":22,"h":1.5,"br":true},
		{"x":-48,"z":42,"h":3.0,"br":false},
		{"x":-58,"z":26,"h":4.0,"br":false},
		{"x":-58,"z":40,"h":1.5,"br":true},
		{"x":-58,"z":48,"h":2.5,"br":true},
	]
	for c in cols:
		var cx=c["x"]; var cz=c["z"]; var ch=c["h"]
		_step(Vector3(cx,ch/2+0.5,cz), Vector3(0.9,ch,0.9), p)
		_step(Vector3(cx,0.6,cz), Vector3(1.3,0.2,1.3), _m_trim)
		if c["br"]:
			var top=CSGBox3D.new()
			top.size=Vector3(1.0,0.3,1.0)
			top.position=Vector3(cx+0.2,ch+0.15,cz-0.1)
			top.rotation=Vector3(0.2,0,-0.15)
			top.material=p; top.use_collision=true
			add_child(top)
	
	var fallen=[
		{"s":Vector3(5,0.3,0.6),"p":Vector3(-42,0.5,24),"r":Vector3(0,0.3,0.1)},
		{"s":Vector3(0.6,0.3,5),"p":Vector3(-52,0.5,44),"r":Vector3(0,-0.2,-0.1)},
		{"s":Vector3(3.5,0.25,0.5),"p":Vector3(-44,0.45,38),"r":Vector3(0.1,0,0.15)},
		{"s":Vector3(4,0.2,0.4),"p":Vector3(-60,0.4,32),"r":Vector3(0,0.4,0)},
	]
	for f2 in fallen:
		var r=CSGBox3D.new()
		r.size=f2["s"]; r.position=f2["p"]; r.rotation=f2["r"]
		r.material=p; r.use_collision=true
		add_child(r)
	
	_step(Vector3(-42,0.6,28), Vector3(7,1.2,0.5), w)
	_step(Vector3(-52,0.9,44), Vector3(0.5,1.8,10), w)
	_step(Vector3(-46,0.35,38), Vector3(9,0.7,0.5), w)
	_csg(Vector3(0.5,1.2,14), Vector3(-61,0.6,32), w)
	_csg(Vector3(0.5,3.0,34), Vector3(-64,1.5,32), w)
	
	for i in range(15):
		var r=CSGBox3D.new()
		var x=randf_range(-62,-36); var z=randf_range(16,50)
		r.size=Vector3(randf_range(0.2,1.8),randf_range(0.08,0.4),randf_range(0.2,1.4))
		r.position=Vector3(x,r.size.y/2,z)
		r.rotation=Vector3(randf_range(-0.3,0.3),randf_range(0,PI),randf_range(-0.3,0.3))
		r.material=w if randf()>0.5 else p
		r.use_collision=true
		add_child(r)

# ════════════════════════════════
# GRAND STAIRCASE — northeast
# ════════════════════════════════
func _grand_stair():
	var w=_m_wall; var p=_m_pillar; var m=_m_marble
	
	# Platform at core level
	_step(Vector3(32,0.5,-34), Vector3(8,0.1,10), _m_floor)
	# Steps east (2 steps)
	_se(Vector3(28,0.5,-34), 2, 0.4, 1.2, m, 0.0)
	# Upper platform
	_step(Vector3(34,0.9,-34), Vector3(12,0.3,10), _m_floor)
	# Steps north (2 steps)
	_sn(Vector3(38,1.1,-36), 2, 0.4, 1.2, m)
	# Highest platform
	_step(Vector3(34,1.5,-42), Vector3(10,0.3,6), _m_floor)
	
	# Fountain
	_step(Vector3(34,1.0,-34), Vector3(4,0.8,4), _m_marble)
	_step(Vector3(34,1.4,-34), Vector3(3,0.2,3), _m_altar)
	_csg(Vector3(0.4,2.0,0.4), Vector3(34,2.6,-34), p)
	
	_csg(Vector3(0.4,1.5,14), Vector3(27,0.75,-34), w)
	_csg(Vector3(14,1.5,0.4), Vector3(34,0.75,-46), w)
	
	for z in [-40,-34,-28]:
		_csg(Vector3(0.4,1.2,0.4), Vector3(27,1.5,z), p)
		_csg(Vector3(0.4,1.2,0.4), Vector3(42,1.5,z), p)

# ════════════════════════════════
# OVERLOOK — northwest
# ════════════════════════════════
func _overlook():
	var w=_m_wall; var p=_m_pillar; var m=_m_marble
	
	# Platform (slightly raised)
	_step(Vector3(-42,0.8,-45), Vector3(20,0.6,16), m)
	# Only 2 steps up (matches platform height)
	_sn(Vector3(-42,0.5,-30), 2, 0.4, 1.2, w, 0.0)
	
	_step(Vector3(-42,1.55,-53), Vector3(20,1.5,0.4), w)
	_csg(Vector3(0.6,2.5,0.6), Vector3(-52,2.35,-53), p)
	_csg(Vector3(0.6,2.5,0.6), Vector3(-32,2.35,-53), p)
	_csg(Vector3(0.4,2.5,18), Vector3(-53,2.05,-45), w)
	
	_csg(Vector3(0.4,3.5,0.4), Vector3(-42,1.75,-38), p)
	_csg(Vector3(0.4,3.5,0.4), Vector3(-42,1.75,-44), p)
	_csg(Vector3(4,0.4,0.3), Vector3(-42,3.6,-41), p)
	
	for x in [-50,-34]:
		_step(Vector3(x,1.6,-44), Vector3(0.8,1.2,0.8), p)
		var fire=StandardMaterial3D.new()
		fire.albedo_color=Color(1.0,0.6,0.2); fire.emission_enabled=true
		fire.emission=Color(1.0,0.5,0.1); fire.emission_energy_multiplier=4.0
		_step(Vector3(x,2.3,-44), Vector3(0.4,0.5,0.4), fire)

# ════════════════════════════════
# PATHS
# ════════════════════════════════
func _paths():
	var p=_m_pillar; var w=_m_wall
	
	_step(Vector3(-20,0.65,-34), Vector3(14,0.3,6), _m_floor)
	_step(Vector3(6,0.65,-38), Vector3(8,0.3,4), _m_floor)
	_step(Vector3(24,0.65,-2), Vector3(6,0.3,6), _m_floor)
	_step(Vector3(-8,0.65,26), Vector3(12,0.3,4), _m_floor)
	_step(Vector3(38,0.65,-12), Vector3(8,0.3,6), _m_floor)
	_step(Vector3(38,0.65,-22), Vector3(8,0.3,6), _m_floor)
	_csg(Vector3(0.4,3.5,4), Vector3(38,1.75,-20), w)
	_step(Vector3(18,0.65,-42), Vector3(10,0.3,4), _m_floor)
	_step(Vector3(-14,0.65,48), Vector3(18,0.3,4), _m_floor)
	_csg(Vector3(0.4,2.0,6), Vector3(-24,1.0,48), w)
	
	for z in [-12,-22]:
		_csg(Vector3(0.4,1.5,0.4), Vector3(33,0.75,z), p)
	for z in [-40,-46]:
		_csg(Vector3(0.4,1.5,0.4), Vector3(12,0.75,z), p)
	for x in [-16,-10,-4]:
		_csg(Vector3(0.4,1.5,0.4), Vector3(x,0.75,-34), p)
	for x in [-10,0,10]:
		_csg(Vector3(0.4,1.5,0.4), Vector3(x,0.75,26), p)

# ════════════════════════════════
# LIGHTS
# ════════════════════════════════
func _lights():
	for z in [-36,-44,-52]:
		for x in [-5,5]:
			var l=OmniLight3D.new()
			l.position=Vector3(x,6.5,z); l.light_color=Color(1.0,0.55,0.2)
			l.light_energy=0.7; l.omni_range=6; l.shadow_enabled=true
			add_child(l)
	
	var alt=OmniLight3D.new()
	alt.position=Vector3(0,3.5,-58); alt.light_color=Color(1.0,0.5,0.15)
	alt.light_energy=3.0; alt.omni_range=10; alt.shadow_enabled=true
	add_child(alt)
	
	for pos in [Vector3(36,2.5,16),Vector3(52,2.5,34),Vector3(44,2.5,25)]:
		var l=OmniLight3D.new()
		l.position=pos; l.light_color=Color(0.3,0.4,0.55)
		l.light_energy=0.5; l.omni_range=6
		add_child(l)
	
	for pos in [Vector3(-38,2.5,20),Vector3(-48,2.5,42),Vector3(-58,2.5,26)]:
		var l=OmniLight3D.new()
		l.position=pos; l.light_color=Color(1.0,0.5,0.15)
		l.light_energy=0.9; l.omni_range=8; l.shadow_enabled=true
		add_child(l)
		var t=create_tween().set_loops()
		t.tween_method(func(v):l.light_energy=v, 0.7,1.3,randf_range(0.3,0.6))
		t.tween_method(func(v):l.light_energy=v, 1.3,0.7,randf_range(0.3,0.6))
	
	for x in [30,38]:
		var l=OmniLight3D.new()
		l.position=Vector3(x,3.0,-34); l.light_color=Color(1.0,0.7,0.3)
		l.light_energy=0.6; l.omni_range=6
		add_child(l)
	
	for x in [-50,-34]:
		var l=OmniLight3D.new()
		l.position=Vector3(x,2.5,-44); l.light_color=Color(1.0,0.5,0.15)
		l.light_energy=1.5; l.omni_range=8; l.shadow_enabled=true
		add_child(l)
		var t=create_tween().set_loops()
		t.tween_method(func(v):l.light_energy=v, 1.2,1.8,randf_range(0.2,0.5))
		t.tween_method(func(v):l.light_energy=v, 1.8,1.2,randf_range(0.2,0.5))

func _atmo():
	var we=get_tree().current_scene.find_child("WorldEnvironment",true,false)
	if we and we.environment:
		var e=we.environment
		e.glow_enabled=true; e.glow_intensity=0.3; e.glow_strength=0.9
		for i in range(7): e.set_glow_level(i,true)
		e.glow_bloom=0.15; e.tonemap_mode=Environment.TONE_MAPPER_FILMIC
		e.fog_enabled=true; e.fog_light_color=Color(0.12,0.10,0.06)
		e.fog_density=0.003; e.fog_height=0.8; e.fog_height_density=0.4
		e.ssao_enabled=true; e.ssao_radius=1.8; e.ssao_intensity=0.7; e.ssao_power=2.2
	
	var moon=SpotLight3D.new()
	moon.position=Vector3(-20,25,10); moon.rotation=Vector3(deg_to_rad(75),deg_to_rad(-15),0)
	moon.light_color=Color(0.35,0.4,0.55); moon.light_energy=0.3
	moon.spot_range=60; moon.spot_angle=90; moon.shadow_enabled=true
	add_child(moon)

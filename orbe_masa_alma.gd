extends Area3D

var objetivo : Node3D = null
var velocidad = 15.0
var dano = 10.0
var vida_orbe = 4.0
var _liberado = false

@onready var mesh_instancia = $MeshInstance3D

func _ready():
	if mesh_instancia:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.7, 0.85, 1.0, 1.0)
		mat.emission_enabled = true
		mat.emission = Color(0.4, 0.6, 1.0, 1.0)
		mat.emission_energy_multiplier = 3.0
		mesh_instancia.material_override = mat
	
	await get_tree().create_timer(vida_orbe).timeout
	if _liberado:
		return
	_liberado = true
	queue_free()

func _physics_process(delta):
	if not is_instance_valid(objetivo):
		if mesh_instancia:
			mesh_instancia.rotation.y += delta * 5.0
		global_position += Vector3(0, 1.0, 0) * delta * 2.0
		return
	
	var pos_objetivo = objetivo.global_position + Vector3(0, 1.0, 0)
	var direccion = pos_objetivo - global_position
	direccion = direccion.normalized()
	
	global_position += direccion * velocidad * delta
	
	if mesh_instancia:
		mesh_instancia.rotation.y += delta * 8.0

func _on_body_entered(body):
	if not is_instance_valid(body):
		return
	
	if body.name == "Jugador" or body.has_method("recibir_dano_jugador") or body.is_in_group("jugador"):
		return
	
	if body.has_method("recibir_dano"):
		body.recibir_dano(dano)
	
	if _liberado:
		return
	_liberado = true
	queue_free()

extends Area3D

var velocidad = 10.0
var dano = 15.0

func _ready():
	await get_tree().create_timer(4.0).timeout
	queue_free()

func _process(delta):
	global_position += global_transform.basis * Vector3(0, 0, -velocidad * delta)
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador and is_instance_valid(jugador):
		var dist = global_position.distance_to(jugador.global_position)
		if dist < 1.5:
			if jugador.has_method("recibir_dano_jugador"):
				jugador.recibir_dano_jugador(dano)
			_impact()

func _impact():
	var expl = preload("res://explosion.tscn").instantiate()
	expl.global_position = global_position
	get_tree().current_scene.add_child(expl)
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("jugador") and body.has_method("recibir_dano_jugador"):
		body.recibir_dano_jugador(dano)
		_impact()
	elif not body.is_in_group("enemies") and not body.is_in_group("bosses") and not body.has_method("recibir_dano_jugador"):
		_impact()

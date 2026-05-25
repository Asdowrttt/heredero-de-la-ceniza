extends Area3D

# Las cambiamos a 'var' y les pusimos nombres en español para que 
# tu script del jugador pueda modificarlas justo al disparar.
var velocidad = 20.0 
var dano = 50.0

func _ready():
	await get_tree().create_timer(3.0).timeout
	queue_free() 

func _process(delta):
	position += transform.basis * Vector3(0, 0, -velocidad * delta)

func _on_body_entered(body):
	# Ignoramos al jugador para no suicidarnos
	if body.name == "Jugador" or body.has_method("recibir_dano_jugador") or body.is_in_group("jugador"):
		return 
		
	if body.has_method("recibir_dano"):
		# Entregamos directamente el daño que el jugador calculó y nos inyectó
		body.recibir_dano(dano) 
		
	queue_free()

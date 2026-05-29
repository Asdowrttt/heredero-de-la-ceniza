extends Node3D

var enemigo_scene = preload("res://enemigo.tscn")
@onready var reloj = $Timer

# Qué tan lejos (en metros) debe aparecer como mínimo para no pegarte
var distancia_segura = 5.0 

func _on_timer_timeout():
	if not is_inside_tree(): 
		return
	var jugador = get_tree().get_first_node_in_group("jugador")
	
	# --- ESTE ES EL CANDADO NUEVO ---
	# Verificamos que el jugador exista, que sea válido y que siga vivo dentro del mundo
	if jugador == null or not is_instance_valid(jugador) or not jugador.is_inside_tree():
		return # Si no está en el mundo, abortamos la misión y no creamos enemigos
		
	var posicion_valida = false
	var nueva_posicion = Vector3.ZERO
	
	while not posicion_valida:
		var x_aleatoria = randf_range(-10.0, 10.0) 
		var z_aleatoria = randf_range(-10.0, 10.0)
		nueva_posicion = Vector3(x_aleatoria, 2.0, z_aleatoria)
		
		# Como ya estamos 100% seguros de que el jugador está en el mundo, esto ya no dará error
		if nueva_posicion.distance_to(jugador.global_position) > distancia_segura:
			posicion_valida = true

	var nuevo_enemigo = enemigo_scene.instantiate()
	nuevo_enemigo.global_position = nueva_posicion
	add_child.call_deferred(nuevo_enemigo)

func aumentar_dificultad():
	# Si el reloj tarda más de medio segundo, lo podemos hacer más rápido
	if reloj.wait_time > 0.8:
		reloj.wait_time = max(reloj.wait_time - 0.2, 0.5)
		print("¡Se enojaron! Nuevo tiempo de spawn: ", reloj.wait_time)

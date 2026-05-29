extends Camera3D

var intensidad_actual = 0.0
var tiempo_restante = 0.0

func _exit_tree():
	h_offset = 0.0
	v_offset = 0.0

func _process(delta):
	if tiempo_restante > 0:
		tiempo_restante -= delta
		# Generamos un temblor aleatorio súper rápido
		h_offset = randf_range(-intensidad_actual, intensidad_actual)
		v_offset = randf_range(-intensidad_actual, intensidad_actual)
	else:
		# Cuando acaba el tiempo, regresamos la cámara a su centro perfecto
		h_offset = 0.0
		v_offset = 0.0

# Esta es la función maestra que mandaremos a llamar cuando haya trancazos
func aplicar_temblor(intensidad, duracion):
	intensidad_actual = intensidad
	tiempo_restante = duracion

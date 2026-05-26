extends Node3D

# Velocidad a la que va a girar el mono (puedes subir o bajar este número)
@export var velocidad_giro : float = 0.5

func _process(delta):
	# rotate_y hace que gire de izquierda a derecha en el eje Y
	rotate_y(velocidad_giro * delta)

extends Node3D

@onready var particulas = $GPUParticles3D

func _ready():
	# Forzamos a que las partículas exploten nomás nacer
	particulas.emitting = true
	
	# Le decimos al código que se espere 1 segundo (lo que dura el efecto)
	await get_tree().create_timer(1.0).timeout
	
	# Nos borramos del mapa
	queue_free()

extends Node

var record_bajas = 0
const RUTA_GUARDADO = "user://record_jugador.save"

func _ready():
	# En cuanto abres el juego, va y busca el archivo de guardado
	cargar_record()

func guardar_record(nuevo_puntaje):
	# Solo guardamos si el puntaje nuevo es mayor al récord histórico
	if nuevo_puntaje > record_bajas:
		record_bajas = nuevo_puntaje
		
		# Abrimos el archivo en modo ESCRITURA (WRITE)
		var archivo = FileAccess.open(RUTA_GUARDADO, FileAccess.WRITE)
		if archivo != null:
			archivo.store_32(record_bajas) # Guardamos el número
			archivo.close()
			print("¡NUEVO RÉCORD GUARDADO EN EL DISCO: ", record_bajas, "!")

func cargar_record():
	# Revisamos si el archivo existe en tu compu
	if FileAccess.file_exists(RUTA_GUARDADO):
		# Lo abrimos en modo LECTURA (READ)
		var archivo = FileAccess.open(RUTA_GUARDADO, FileAccess.READ)
		if archivo != null:
			record_bajas = archivo.get_32() # Sacamos el número
			archivo.close()
			print("Récord cargado exitosamente: ", record_bajas)

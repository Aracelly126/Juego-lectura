extends Control

func _ready() -> void:
	# Al iniciar el juego, nos aseguramos de que el menú esté oculto
	visible = false

func _input(event: InputEvent) -> void:
	# Detectamos si presionas la tecla "ESC" (ui_cancel)
	if event.is_action_pressed("ui_cancel"):
		cambiar_pausa()

func cambiar_pausa():
	# 1. Invertimos el estado de pausa (si es true pasa a false, y viceversa)
	var nuevo_estado = !get_tree().paused
	get_tree().paused = nuevo_estado
	
	# 2. Mostramos u ocultamos este menú
	visible = nuevo_estado
	
	# 3. MANEJO DEL MOUSE (Vital para juegos 3D)
	if nuevo_estado:
		# Si está pausado, muestra el mouse para poder hacer clic
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		# Si regresamos al juego, atrapa el mouse de nuevo
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# --- CONECTA ESTA FUNCIÓN A TU BOTÓN ---
func _on_button_regresar_pressed() -> void:
	# Al presionar el botón, llamamos a la misma función para quitar la pausa
	cambiar_pausa()

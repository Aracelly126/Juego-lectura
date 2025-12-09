extends Control

# --- REFERENCIAS ---
# Solo necesitamos el botón de salir
# (Ajusta la ruta si tu botón no está dentro de VBoxContainer)
@onready var boton_salir = $VBoxContainer/BotonSalir

func _ready() -> void:
	# Ocultar menú al inicio
	visible = false
	
	# Conectar solo el botón de salir
	if boton_salir:
		boton_salir.pressed.connect(_on_boton_salir_pressed)
	else:
		print("ERROR: No encuentro el BotonSalir.")

func _input(event: InputEvent) -> void:
	# Detectamos tecla ESC (ui_cancel) para abrir/cerrar el menú
	if event.is_action_pressed("ui_cancel"):
		cambiar_pausa()

func cambiar_pausa():
	# 1. Invertir estado de pausa
	var nuevo_estado = !get_tree().paused
	get_tree().paused = nuevo_estado
	
	# 2. Mostrar/Ocultar menú visual
	visible = nuevo_estado
	
	# 3. Manejo del Ratón
	if nuevo_estado:
		# PAUSA: Mostrar ratón para poder clicar en Salir
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		# JUEGO: Atrapamos el ratón para mover la cámara
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# --- FUNCIONES DE BOTONES ---

func _on_boton_salir_pressed() -> void:
	# Cerrar el juego
	get_tree().quit()

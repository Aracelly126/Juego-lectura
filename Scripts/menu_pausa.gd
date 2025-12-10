extends Control

# --- REFERENCIAS ---
# CORRECCIÓN AQUÍ: El botón ahora es un hijo directo de MenuPausa, no de VBoxContainer.
@onready var boton_salir = $BotonSalir 

# --- MEMORIA DEL RATÓN ---
var modo_raton_anterior = Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	# La imagen del menú de pausa (MenuPausa) ya debe tener visibilidad desactivada en el editor.
	visible = false
	
	# La conexión sigue siendo válida
	if boton_salir:
		boton_salir.pressed.connect(_on_boton_salir_pressed)
	else:
		# Añadido un mensaje de error útil si olvidaste renombrar el botón
		print("ERROR: No se encontró el BotonSalir. Revisa el nombre del nodo.")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		cambiar_pausa()

func cambiar_pausa():
	# 1. Invertir estado de pausa
	var nuevo_estado = !get_tree().paused
	get_tree().paused = nuevo_estado
	
	# 2. Mostrar/Ocultar menú visual
	visible = nuevo_estado
	
	# 3. MANEJO INTELIGENTE DEL RATÓN (Esta lógica no cambia, es correcta)
	if nuevo_estado:
		# --- ESTAMOS PAUSANDO ---
		modo_raton_anterior = Input.get_mouse_mode()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	else:
		# --- ESTAMOS QUITANDO LA PAUSA ---
		# Restauramos el ratón al modo que tenía antes de pausar (VISIBLE para Quiz, CAPTURED para jugar)
		Input.mouse_mode = modo_raton_anterior

func _on_boton_salir_pressed() -> void:
	get_tree().quit()

extends Control

# --- REFERENCIAS ---
@onready var boton_salir = $VBoxContainer/BotonSalir

# --- NUEVA VARIABLE: MEMORIA DEL RATÓN ---
# Aquí guardaremos si el ratón estaba visible o atrapado antes de pausar
var modo_raton_anterior = Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	visible = false
	if boton_salir:
		boton_salir.pressed.connect(_on_boton_salir_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		cambiar_pausa()

func cambiar_pausa():
	# 1. Invertir estado de pausa
	var nuevo_estado = !get_tree().paused
	get_tree().paused = nuevo_estado
	
	# 2. Mostrar/Ocultar menú visual
	visible = nuevo_estado
	
	# 3. MANEJO INTELIGENTE DEL RATÓN
	if nuevo_estado:
		# --- ESTAMOS PAUSANDO ---
		# A. Antes de nada, GUARDAMOS cómo estaba el ratón (¿Visible por el quiz o Atrapado jugando?)
		modo_raton_anterior = Input.get_mouse_mode()
		
		# B. Ahora sí, lo hacemos visible para usar el menú de pausa
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	else:
		# --- ESTAMOS QUITANDO LA PAUSA ---
		# Restauramos el ratón a como estaba antes de pausar.
		# Si estabas en el Quiz, se pondrá VISIBLE.
		# Si estabas corriendo, se pondrá CAPTURED.
		Input.mouse_mode = modo_raton_anterior

func _on_boton_salir_pressed() -> void:
	get_tree().quit()

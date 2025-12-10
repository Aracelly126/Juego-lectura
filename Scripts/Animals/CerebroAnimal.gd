extends Node3D

# --- 1. CONFIGURACIÓN DEL EXAMEN ---
@export_category("Datos del Quiz")
@export_group("Mensaje Inicial")
@export_multiline var frase_desafio: String = "¡Demuestra tu sabiduría!"

@export_group("Preguntas")
@export_multiline var pregunta: String = "¿Qué dice el animal?"
@export var opcion_1: String = "Opción 1"
@export var opcion_2: String = "Opción 2"
@export var opcion_3: String = "Opción 3"
@export var correcta: int = 1 

# --- 2. CONEXIONES UI ---
@export_group("Conexiones UI")
@export var panel_quiz: Panel      
@export var lbl_pregunta: Label    
@export var btn_1: Button          
@export var btn_2: Button          
@export var btn_3: Button

# --- 3. EFECTOS ESPECIALES ---
@export_group("Efectos")
@export var luz_magica: OmniLight3D

# --- 4. TELETRANSPORTE FINAL (¡NUEVO!) ---
@export_group("Teletransporte a Escena 2D")
@export var escena_destino_2d: PackedScene # Arrastra aquí la escena 2D (Ej: "Escena2D_Juego.tscn")

# --- REFERENCIAS INTERNAS ---
@onready var cartel_flotante = $Label3D
var jugador_cerca = false
var quiz_activo = false
var jugador_ref = null 

func _ready():
	# Buscamos el área de charla
	var area = $AreaCharla
	if area:
		# ¡CRÍTICO! El animal empieza sordo hasta que la Zona lo activa
		area.monitoring = false 
		
		area.body_entered.connect(_entrar)
		area.body_exited.connect(_salir)
	else:
		print("ERROR: ¡Al animal le falta el nodo AreaCharla!")
	
	if cartel_flotante: cartel_flotante.visible = false
	if luz_magica: luz_magica.light_energy = 0.0

func _input(event):
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		if not quiz_activo:
			abrir_quiz()

func abrir_quiz():
	quiz_activo = true
	if cartel_flotante: cartel_flotante.visible = false
	
	if jugador_ref and jugador_ref.has_method("cambiar_estado_movimiento"):
		jugador_ref.cambiar_estado_movimiento(false)
	
	panel_quiz.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Aseguramos que los botones estén blancos antes de empezar
	resetear_colores()
	
	lbl_pregunta.text = pregunta
	btn_1.text = opcion_1
	btn_2.text = opcion_2
	btn_3.text = opcion_3
	
	desconectar_todo()
	btn_1.pressed.connect(func(): revisar(1))
	btn_2.pressed.connect(func(): revisar(2))
	btn_3.pressed.connect(func(): revisar(3))

func revisar(eleccion):
	# 1. Bloqueamos botones para que no puedas clicar dos veces mientras esperas
	desconectar_todo()
	
	if eleccion == correcta:
		print("¡Correcto!")
		# Ocultamos el panel visualmente
		panel_quiz.visible = false
		
		# --- SALVAR AL JUGADOR ---
		var jugador_a_liberar = jugador_ref 
		
		# --- ANIMACIÓN DE DESAPARICIÓN SUAVE ---
		var tween = create_tween()
		tween.set_parallel(true)
		
		if luz_magica:
			tween.tween_property(luz_magica, "light_energy", 15.0, 1.5)
		
		tween.tween_property(self, "scale", Vector3.ZERO, 1.5)
		
		await get_tree().create_timer(1.5).timeout
		
		# --- DECISIÓN FINAL (¡TELETRANSPORTE AQUÍ!) ---
		if escena_destino_2d:
			print("Cambiando a escena 2D...")
			
			# 1. Liberamos el mouse para la escena 2D
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 
			
			# 2. Aseguramos que el jugador se libere antes de que la escena lo destruya
			if jugador_a_liberar and jugador_a_liberar.has_method("cambiar_estado_movimiento"):
				jugador_a_liberar.cambiar_estado_movimiento(true)
			
			# 3. CAMBIAMOS DE ESCENA
			get_tree().change_scene_to_packed(escena_destino_2d)
			return # Terminamos la función aquí
			
		else:
			# Si NO hay destino 2D, comportamiento normal (desaparecer y devolver control)
			if jugador_a_liberar and jugador_a_liberar.has_method("cambiar_estado_movimiento"):
				jugador_a_liberar.cambiar_estado_movimiento(true)
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			queue_free()
			
	else:
		print("Incorrecto...")
		
		# --- PINTAR DE ROJO EL BOTÓN INCORRECTO ---
		var boton_malo = null
		match eleccion:
			1: boton_malo = btn_1
			2: boton_malo = btn_2
			3: boton_malo = btn_3
		
		if boton_malo:
			boton_malo.modulate = Color.RED
		
		# Esperamos 1 segundo para que veas tu error
		await get_tree().create_timer(1.0).timeout
		
		# Cerramos el quiz
		cerrar_quiz()

func resetear_colores():
	if btn_1: btn_1.modulate = Color.WHITE
	if btn_2: btn_2.modulate = Color.WHITE
	if btn_3: btn_3.modulate = Color.WHITE

func cerrar_quiz():
	cerrar_quiz_visual()
	if jugador_ref and jugador_ref.has_method("cambiar_estado_movimiento"):
		jugador_ref.cambiar_estado_movimiento(true)
	
	if jugador_cerca and cartel_flotante:
		cartel_flotante.visible = true

func cerrar_quiz_visual():
	quiz_activo = false
	panel_quiz.visible = false
	desconectar_todo()
	# Reseteamos colores al cerrar para que quede limpio
	resetear_colores()

func desconectar_todo():
	var mis_botones = [btn_1, btn_2, btn_3]
	for btn in mis_botones:
		if btn:
			var conexiones = btn.pressed.get_connections()
			for conexion in conexiones:
				btn.pressed.disconnect(conexion.callable)

func _entrar(body):
	if body.name == "player":
		jugador_cerca = true
		jugador_ref = body
		if cartel_flotante:
			cartel_flotante.text = frase_desafio + "\n[ F ]"
			cartel_flotante.visible = true

func _salir(body):
	if body.name == "player":
		jugador_cerca = false
		jugador_ref = null
		if cartel_flotante: cartel_flotante.visible = false
		if quiz_activo: cerrar_quiz()

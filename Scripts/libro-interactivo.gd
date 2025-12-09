extends Node3D

# --- REFERENCIAS ---
@onready var animation_player = $AnimationPlayer 
@onready var area_detectora = $Area3D
@onready var mensaje_texto = $Label3D 

# --- POSICIÓN DE LECTURA ---
# Ajusta esto para centrarlo bien en pantalla
var posicion_lectura = Vector3(-0.5, -0.2, -0.5) # Justo al frente, medio metro
var rotacion_lectura = Vector3(0, 0, -45) # Ajusta esto si sale rotado

# --- VARIABLES ---
var jugador_cerca = false
var libro_abierto = false
var nombre_animacion = "Animation" 

var pos_original_mesa = Vector3.ZERO
var rot_original_mesa = Quaternion.IDENTITY
var jugador_ref = null # Referencia al script del jugador
var camara_jugador = null

func _ready():
	if mensaje_texto: mensaje_texto.visible = false
	
	# Guardar posición original
	pos_original_mesa = global_position
	rot_original_mesa = global_transform.basis.get_rotation_quaternion()
	
	if area_detectora:
		area_detectora.body_entered.connect(_on_body_entered)
		area_detectora.body_exited.connect(_on_body_exited)

func _process(delta):
	if libro_abierto and camara_jugador:
		var destino = camara_jugador.to_global(posicion_lectura)
		global_position = global_position.lerp(destino, 15 * delta)
		
		# 1. BASE: Mirar a la cámara
		look_at(camara_jugador.global_position, Vector3.UP)
		
		# 2. CORRECCIONES FIJAS (Lo que ya logramos que funcione)
		# No toques esto, es lo que arregla tu modelo 3D específico
		rotate_object_local(Vector3.UP, deg_to_rad(90)) 
		rotate_object_local(Vector3.LEFT, deg_to_rad(270))
		rotate_object_local(Vector3.FORWARD, deg_to_rad(90))

		# 3. TU AJUSTE PERSONAL (Variable rotacion_lectura)
		# Ahora sí, lo que pongas arriba se sumará aquí:
		if rotacion_lectura != Vector3.ZERO:
			rotate_object_local(Vector3.RIGHT, deg_to_rad(rotacion_lectura.x))   # Eje X (Inclinación)
			rotate_object_local(Vector3.UP, deg_to_rad(rotacion_lectura.y))      # Eje Y (Giro)
			rotate_object_local(Vector3.FORWARD, deg_to_rad(rotacion_lectura.z)) # Eje Z (Rodar)

func _input(event):
	if Input.is_action_just_pressed("interactuar"): # Tecla F
		if libro_abierto:
			cerrar_libro()
		elif jugador_cerca:
			abrir_libro()

func abrir_libro():
	if jugador_ref:
		libro_abierto = true
		
		# 1. CONGELAR AL JUGADOR
		# Llamamos a la función que creamos en el script del Player
		if jugador_ref.has_method("cambiar_estado_movimiento"):
			jugador_ref.cambiar_estado_movimiento(false)
		
		# 2. Preparar cámara y animación
		camara_jugador = get_viewport().get_camera_3d()
		animation_player.play(nombre_animacion)
		
		if mensaje_texto: mensaje_texto.text = "F para cerrar"

func cerrar_libro():
	libro_abierto = false
	
	# 1. DESCONGELAR AL JUGADOR
	if jugador_ref and jugador_ref.has_method("cambiar_estado_movimiento"):
		jugador_ref.cambiar_estado_movimiento(true)
	
	animation_player.play_backwards(nombre_animacion)
	if mensaje_texto: mensaje_texto.text = "F para leer"
	
	# Devolver a la mesa suavemente
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", pos_original_mesa, 0.5)
	tween.tween_property(self, "quaternion", rot_original_mesa, 0.5)

# --- DETECCIÓN ---
func _on_body_entered(body):
	if body.name == "player": # Asegúrate que tu nodo se llama "player"
		jugador_cerca = true
		jugador_ref = body # ¡IMPORTANTE! Guardamos quién es el jugador
		if mensaje_texto and not libro_abierto:
			mensaje_texto.visible = true
			mensaje_texto.text = "F para leer"

func _on_body_exited(body):
	if body.name == "player":
		jugador_cerca = false
		jugador_ref = null # Borramos la referencia por seguridad
		if mensaje_texto: mensaje_texto.visible = false

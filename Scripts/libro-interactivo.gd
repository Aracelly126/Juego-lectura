extends Node3D

# --- CONFIGURACIÓN DE HISTORIA (Dos páginas) ---
@export_group("Contenido del Libro") # Esto agrupa las variables bonito en el editor
@export_multiline var texto_pagina_izquierda: String = "Texto de la página 1..."
@export_multiline var texto_pagina_derecha: String = "Texto de la página 2..."

# --- REFERENCIAS ---
@onready var animation_player = $AnimationPlayer 
@onready var area_detectora = $Area3D
@onready var mensaje_flotante = $Label3D 

# Referencias a la INTERFAZ 2D
@onready var capa_lectura = $CanvasLayer
# OJO: Asegúrate de que renombraste los nodos como te dije en el Paso 1
@onready var label_izquierda = $CanvasLayer/Control/TextoIzquierda
@onready var label_derecha = $CanvasLayer/Control/TextoDerecha

# --- CONFIGURACIÓN DE POSICIÓN ---
var posicion_lectura = Vector3(-0.4, -0.2, -0.5) 
var rotacion_lectura = Vector3(0, 0, -135)

# --- VARIABLES INTERNAS ---
var jugador_cerca = false
var libro_abierto = false
var nombre_animacion = "Animation" 
var pos_original_mesa = Vector3.ZERO
var rot_original_mesa = Quaternion.IDENTITY
var jugador_ref = null 
var camara_jugador = null

func _ready():
	pos_original_mesa = global_position
	rot_original_mesa = global_transform.basis.get_rotation_quaternion()
	
	if mensaje_flotante: mensaje_flotante.visible = false
	if capa_lectura: capa_lectura.visible = false 
	
	# --- CARGAR TEXTOS EN AMBAS PÁGINAS ---
	if label_izquierda:
		label_izquierda.text = texto_pagina_izquierda
	if label_derecha:
		label_derecha.text = texto_pagina_derecha
	
	if area_detectora:
		area_detectora.body_entered.connect(_on_body_entered)
		area_detectora.body_exited.connect(_on_body_exited)

# ... (El resto del script _process, _input, abrir/cerrar y signals sigue IGUAL) ...
# ... (Copia y pega el resto de tu script anterior aquí abajo) ...
func _process(delta):
	if libro_abierto and camara_jugador:
		var destino = camara_jugador.to_global(posicion_lectura)
		global_position = global_position.lerp(destino, 15 * delta)
		global_rotation = camara_jugador.global_rotation
		rotate_object_local(Vector3.UP, deg_to_rad(90)) 
		rotate_object_local(Vector3.LEFT, deg_to_rad(270))
		rotate_object_local(Vector3.FORWARD, deg_to_rad(90))
		if rotacion_lectura != Vector3.ZERO:
			rotate_object_local(Vector3.RIGHT, deg_to_rad(rotacion_lectura.x))
			rotate_object_local(Vector3.UP, deg_to_rad(rotacion_lectura.y))
			rotate_object_local(Vector3.FORWARD, deg_to_rad(rotacion_lectura.z))

func _input(event):
	if Input.is_action_just_pressed("interactuar"): 
		if libro_abierto:
			cerrar_libro()
		elif jugador_cerca:
			abrir_libro()

func abrir_libro():
	if jugador_ref:
		libro_abierto = true
		if jugador_ref.has_method("cambiar_estado_movimiento"):
			jugador_ref.cambiar_estado_movimiento(false)
		camara_jugador = get_viewport().get_camera_3d()
		animation_player.play(nombre_animacion)
		if mensaje_flotante: mensaje_flotante.text = "F para cerrar"
		await get_tree().create_timer(0.8).timeout 
		if libro_abierto: 
			capa_lectura.visible = true

func cerrar_libro():
	libro_abierto = false
	if capa_lectura: capa_lectura.visible = false
	if jugador_ref and jugador_ref.has_method("cambiar_estado_movimiento"):
		jugador_ref.cambiar_estado_movimiento(true)
	animation_player.play_backwards(nombre_animacion)
	if mensaje_flotante: mensaje_flotante.text = "F para leer"
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", pos_original_mesa, 0.5)
	tween.tween_property(self, "quaternion", rot_original_mesa, 0.5)

func _on_body_entered(body):
	if body.name == "player":
		jugador_cerca = true
		jugador_ref = body
		if mensaje_flotante and not libro_abierto:
			mensaje_flotante.visible = true
			mensaje_flotante.text = "F para leer"

func _on_body_exited(body):
	if body.name == "player":
		jugador_cerca = false
		jugador_ref = null
		if mensaje_flotante: mensaje_flotante.visible = false

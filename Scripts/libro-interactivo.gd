extends Node3D

# --- CONFIGURACIÓN DE CONTENIDO (Editable en el Inspector) ---
@export_category("Contenido del Libro")

@export_group("Página Izquierda")
@export var izq_usar_imagen: bool = false
@export_multiline var izq_texto: String = "Texto de la página izquierda..."
@export var izq_textura: Texture2D

@export_group("Página Derecha")
@export var der_usar_imagen: bool = false
@export_multiline var der_texto: String = "Texto de la página derecha..."
@export var der_textura: Texture2D

# --- CONFIGURACIÓN VISUAL ---
@export_group("Apariencia")
@export var color_del_brillo: Color = Color(1, 0.8, 0.2) 

# --- REFERENCIAS DE ESCENA ---
@onready var animation_player = $AnimationPlayer 
@onready var area_detectora = $Area3D
@onready var mensaje_flotante = $Label3D 
@onready var luz_brillo = $OmniLight3D

# --- REFERENCIAS A LA INTERFAZ 2D (LECTURA) ---
@onready var capa_lectura = $CanvasLayer
# Referencias de Texto
@onready var label_izquierda = $CanvasLayer/Control/TextoIzquierda
@onready var label_derecha = $CanvasLayer/Control/TextoDerecha
# Referencias de Imagen (¡Nuevas!)
@onready var img_izquierda = $CanvasLayer/Control/ImagenIzquierda
@onready var img_derecha = $CanvasLayer/Control/ImagenDerecha

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
var tiempo_brillo = 0.0 

func _ready():
	pos_original_mesa = global_position
	rot_original_mesa = global_transform.basis.get_rotation_quaternion()
	
	# Ocultar interfaces iniciales
	if mensaje_flotante: mensaje_flotante.visible = false
	if capa_lectura: capa_lectura.visible = false 
	
	# --- CONFIGURAR EL CONTENIDO DE LAS PÁGINAS ---
	actualizar_paginas()
	
	# Aplicar color de luz
	if luz_brillo:
		luz_brillo.light_color = color_del_brillo
	
	# Conectar señales
	if area_detectora:
		area_detectora.body_entered.connect(_on_body_entered)
		area_detectora.body_exited.connect(_on_body_exited)

# Función nueva para manejar qué se muestra
func actualizar_paginas():
	# --- LÓGICA IZQUIERDA ---
	if izq_usar_imagen:
		if label_izquierda: label_izquierda.visible = false
		if img_izquierda:
			img_izquierda.visible = true
			img_izquierda.texture = izq_textura
	else:
		if img_izquierda: img_izquierda.visible = false
		if label_izquierda:
			label_izquierda.visible = true
			label_izquierda.text = izq_texto

	# --- LÓGICA DERECHA ---
	if der_usar_imagen:
		if label_derecha: label_derecha.visible = false
		if img_derecha:
			img_derecha.visible = true
			img_derecha.texture = der_textura
	else:
		if img_derecha: img_derecha.visible = false
		if label_derecha:
			label_derecha.visible = true
			label_derecha.text = der_texto

func _process(delta):
	# 1. MOVIMIENTO (Si está abierto)
	if libro_abierto and camara_jugador:
		var destino = camara_jugador.to_global(posicion_lectura)
		global_position = global_position.lerp(destino, 15 * delta)
		
		global_rotation = camara_jugador.global_rotation
		
		# Correcciones del modelo
		rotate_object_local(Vector3.UP, deg_to_rad(90)) 
		rotate_object_local(Vector3.LEFT, deg_to_rad(270))
		rotate_object_local(Vector3.FORWARD, deg_to_rad(90))
		
		if rotacion_lectura != Vector3.ZERO:
			rotate_object_local(Vector3.RIGHT, deg_to_rad(rotacion_lectura.x))
			rotate_object_local(Vector3.UP, deg_to_rad(rotacion_lectura.y))
			rotate_object_local(Vector3.FORWARD, deg_to_rad(rotacion_lectura.z))
	
	# 2. BRILLO PULSANTE (Si está cerrado)
	elif luz_brillo:
		tiempo_brillo += delta * 2.0
		luz_brillo.light_energy = 2.0 + sin(tiempo_brillo) * 1.0

func _input(event):
	if Input.is_action_just_pressed("interactuar"): 
		if libro_abierto:
			cerrar_libro()
		elif jugador_cerca:
			abrir_libro()

func abrir_libro():
	if jugador_ref:
		libro_abierto = true
		
		# Apagamos la luz al leer
		if luz_brillo: luz_brillo.visible = false
		
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
	
	# Encendemos la luz de nuevo
	if luz_brillo: luz_brillo.visible = true
	
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

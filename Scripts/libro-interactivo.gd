extends Node3D

# --- REFERENCIAS ---
@onready var animation_player = $AnimationPlayer 
@onready var area_detectora = $Area3D
# Referencia al texto flotante que acabamos de crear
@onready var mensaje_texto = $Label3D 

# --- VARIABLES ---
var jugador_cerca = false
var libro_abierto = false
var nombre_animacion = "Animation" 

func _ready():
	# Nos aseguramos de que el texto empiece invisible
	if mensaje_texto:
		mensaje_texto.visible = false
	
	# Conexiones de las señales
	if area_detectora:
		area_detectora.body_entered.connect(_on_body_entered)
		area_detectora.body_exited.connect(_on_body_exited)

func _input(event):
	# Ahora usamos la acción "interactuar" que configuramos con la F
	if Input.is_action_just_pressed("interactuar"):
		if jugador_cerca:
			abrir_o_cerrar_libro()

func abrir_o_cerrar_libro():
	if not libro_abierto:
		animation_player.play(nombre_animacion)
		libro_abierto = true
		# Cambiamos el texto cuando el libro está abierto
		if mensaje_texto: mensaje_texto.text = "Pulsa F para cerrar"
	else:
		animation_player.play_backwards(nombre_animacion)
		libro_abierto = false
		# Volvemos al texto original
		if mensaje_texto: mensaje_texto.text = "Pulsa F para leer"

# --- DETECCIÓN ---
func _on_body_entered(body):
	if body.name == "player": 
		jugador_cerca = true
		# Muestra el mensaje
		if mensaje_texto:
			mensaje_texto.text = "Pulsa F para leer"
			mensaje_texto.visible = true

func _on_body_exited(body):
	if body.name == "player":
		jugador_cerca = false
		# Oculta el mensaje
		if mensaje_texto:
			mensaje_texto.visible = false
		
		# Opcional: Cerrar libro si te alejas
		if libro_abierto:
			abrir_o_cerrar_libro()

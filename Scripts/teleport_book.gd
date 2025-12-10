extends Node3D

# --- CONFIGURACIÓN (Arrastra y escribe en el Inspector) ---
@export_group("Teletransporte")
@export var escena_destino: PackedScene # Arrastra aquí la escena a la que quieres ir (ej: "Libreria.tscn")
@export var mensaje_interaccion: String = "Pulsa F para teletransportarte"

@export_group("Efectos")
@export var altura_flotacion: float = 0.05 # Altura máxima de la onda (en metros)
@export var velocidad_flotacion: float = 2.0 # Rapidez de la onda

# --- REFERENCIAS ---
@onready var area_detector = $Area3D # El nodo Area3D que detecta al jugador
@onready var cartel_flotante = $Label3D # El nodo Label3D

var jugador_cerca: bool = false
var posicion_original: Vector3

func _ready():
	posicion_original = global_position
	
	# Aseguramos que el detector esté conectado
	area_detector.body_entered.connect(_on_body_entered)
	area_detector.body_exited.connect(_on_body_exited)
	
	# Ponemos el texto en el cartel
	cartel_flotante.text = mensaje_interaccion
	cartel_flotante.visible = false

func _process(delta):
	# Efecto de flotación constante
	var offset_y = sin(Time.get_ticks_msec() / 1000.0 * velocidad_flotacion) * altura_flotacion
	global_position.y = posicion_original.y + offset_y

func _input(event):
	# Si el jugador está cerca y pulsa F (interactuar)
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		teletransportar()

# En tu script TeleportBook.gd

func teletransportar():
	if escena_destino:
		# 1. Aseguramos que la pausa y el ratón se desactiven antes de cargar la nueva escena
		get_tree().paused = false 
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
		# 2. Carga la nueva escena
		get_tree().change_scene_to_packed(escena_destino)
	else:
		print("ERROR: ¡No hay escena de destino asignada en el Inspector del libro!")

# --- Detección ---
func _on_body_entered(body):
	if body.name == "player": # Asegúrate que tu jugador se llame "player"
		jugador_cerca = true
		cartel_flotante.visible = true

func _on_body_exited(body):
	if body.name == "player":
		jugador_cerca = false
		cartel_flotante.visible = false

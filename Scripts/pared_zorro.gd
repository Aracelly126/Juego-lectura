extends Area3D

# --- CAJITAS PARA ARRASTRAR COSAS EN EL INSPECTOR ---
@export var zorro_modelo: Node3D             # Aquí pondremos al zorro entero
@export var animador_zorro: AnimationPlayer  # Aquí pondremos su reproductor de animación
@export var nombre_animacion: String = ""    # Aquí escribiremos el nombre de la animación

var ya_se_activo = false

func _ready():
	# Conectamos la señal de "choque" automáticamente
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Verificamos que sea el jugador y que no haya pasado antes
	if body.name == "player" and not ya_se_activo:
		activar_zorro()

func activar_zorro():
	ya_se_activo = true
	
	if zorro_modelo:
		zorro_modelo.visible = true
	
	if animador_zorro:
		# --- ESTO ES LO NUEVO: IMPRIMIR LA LISTA DE NOMBRES ---
		print("--- LISTA DE ANIMACIONES DETECTADAS ---")
		print(animador_zorro.get_animation_list())
		print("---------------------------------------")
		
		# Intentamos reproducir
		animador_zorro.play(nombre_animacion)

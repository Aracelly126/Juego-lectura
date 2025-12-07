extends CharacterBody3D

# Configuración
const VELOCIDAD = 5.0
const SALTO = 4.5
const SENSIBILIDAD = 0.003 # Qué tan rápido gira la cámara

# Referencia a la cámara (Tus "ojos")
# IMPORTANTE: Asegúrate de que el nodo hijo se llame "Camera3D" exactamente
@onready var camara = $Camera3D

func _ready():
	# Al iniciar, ocultamos el mouse y lo atrapamos en el centro de la pantalla
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	# Si movemos el mouse...
	if event is InputEventMouseMotion:
		# Giramos al personaje (eje Y - izquierda/derecha)
		rotate_y(-event.relative.x * SENSIBILIDAD)
		# Giramos la cámara (eje X - arriba/abajo)
		camara.rotate_x(-event.relative.y * SENSIBILIDAD)
		# Limitamos la vista para no dar la vuelta completa (tope de cuello)
		camara.rotation.x = clamp(camara.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = SALTO

	# Movimiento WASD
	# IMPORTANTE: Esto requiere que hayas configurado el Mapa de Entrada (Input Map)
	# con los nombres: "izquierda", "derecha", "adelante", "atras"
	var input_dir := Input.get_vector("izquierda", "derecha", "adelante", "atras")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * VELOCIDAD
		velocity.z = direction.z * VELOCIDAD
	else:
		velocity.x = move_toward(velocity.x, 0, VELOCIDAD)
		velocity.z = move_toward(velocity.z, 0, VELOCIDAD)

	move_and_slide()

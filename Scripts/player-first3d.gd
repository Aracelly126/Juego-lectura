extends CharacterBody3D

# --- CONFIGURACIÓN DE MOVIMIENTO ---
const VELOCIDAD = 10
const SALTO = 4.5
const SENSIBILIDAD = 0.003
var gravedad = ProjectSettings.get_setting("physics/3d/default_gravity")

# --- VARIABLE DE CONTROL (NUEVO) ---
# Esto permite que el libro nos "apague" el movimiento
var puede_moverse = true

# --- CONFIGURACIÓN DEL TAMBALEO (HEAD BOB) ---
const BOB_FRECUENCIA = 4.5
const BOB_AMPLITUD = 0.08
var t_bob = 0.0
var pos_inicial_camara = Vector3.ZERO

# --- REFERENCIAS ---
@onready var camara = $Camera3D
# Verifica que la ruta "Root Scene/AnimationPlayer" sea correcta en tu proyecto
@onready var anim_player = $"Root Scene/AnimationPlayer" 

# --- NOMBRES DE ANIMACIONES ---
var anim_caminar = "HumanArmature|Man_Walk"
var anim_quieto = "HumanArmature|Man_Idle"

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pos_inicial_camara = camara.position

# --- FUNCIÓN PARA BLOQUEAR/DESBLOQUEAR (LLAMADA POR EL LIBRO) ---
func cambiar_estado_movimiento(activo: bool):
	puede_moverse = activo
	if not activo:
		velocity = Vector3.ZERO # Frenar en seco

# --- AQUÍ ESTÁ EL MOVIMIENTO DE LA CÁMARA ---
func _unhandled_input(event):
	# El "if puede_moverse" es clave: si estás leyendo, el mouse NO moverá la cámara
	if puede_moverse and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSIBILIDAD)
		camara.rotate_x(-event.relative.y * SENSIBILIDAD)
		camara.rotation.x = clamp(camara.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Gravedad (siempre activa para no flotar)
	if not is_on_floor():
		velocity.y -= gravedad * delta

	# SI ESTAMOS BLOQUEADOS (LEYENDO):
	if not puede_moverse:
		# Forzamos la animación de estar quieto
		if anim_player.current_animation != anim_quieto:
			anim_player.play(anim_quieto, 0.2)
		move_and_slide()
		return # <--- Cortamos aquí para que no ejecute movimiento ni headbob

	# --- CÓDIGO NORMAL DE MOVIMIENTO (SOLO SI NO ESTAMOS LEYENDO) ---
	
	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = SALTO

	# Movimiento WASD
	var input_dir := Input.get_vector("izquierda", "derecha", "adelante", "atras")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * VELOCIDAD
		velocity.z = direction.z * VELOCIDAD
		
		# Animación caminar
		if anim_player.current_animation != anim_caminar:
			# El 1.0 es la velocidad normal de la animación.
			# Si patina, cambia 1.0 por 0.8
			anim_player.play(anim_caminar, -1, 1.0) 
			
	else:
		velocity.x = move_toward(velocity.x, 0, VELOCIDAD)
		velocity.z = move_toward(velocity.z, 0, VELOCIDAD)
		
		# Animación quieto
		if is_on_floor():
			if anim_player.current_animation != anim_quieto:
				anim_player.play(anim_quieto, 0.2)

	# --- TAMBALEO (HEAD BOB) ---
	if is_on_floor():
		if direction:
			t_bob += delta * velocity.length()
			_headbob(t_bob)
		else:
			# Regresar la cámara al centro suavemente
			camara.position = camara.position.lerp(pos_inicial_camara, 10 * delta)

	move_and_slide()

# Función matemática del tambaleo
func _headbob(time) -> void:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FRECUENCIA) * BOB_AMPLITUD
	# El signo negativo (-) invierte el lado de inicio
	pos.x = -cos(time * BOB_FRECUENCIA / 2) * BOB_AMPLITUD 
	camara.position = pos_inicial_camara + pos

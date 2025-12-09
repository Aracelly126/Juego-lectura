extends CharacterBody3D

# --- CONFIGURACIÓN DE MOVIMIENTO ---
# --- 2.75 ---
const VELOCIDAD = 10
const SALTO = 4.5
const SENSIBILIDAD = 0.003
var gravedad = ProjectSettings.get_setting("physics/3d/default_gravity")

# --- CONTROL DE MOVIMIENTO ---
var puede_moverse = true

# --- CONFIGURACIÓN DEL TAMBALEO (HEAD BOB) ---
const BOB_FRECUENCIA = 4.5
const BOB_AMPLITUD = 0.08
var t_bob = 0.0
var pos_inicial_camara = Vector3.ZERO

# --- REFERENCIAS ---
@onready var camara = $Camera3D
@onready var anim_player = $"Root Scene/AnimationPlayer"

# --- NOMBRES DE ANIMACIONES ---
var anim_caminar = "HumanArmature|Man_Walk"
var anim_quieto = "HumanArmature|Man_Idle"

func _ready():
	# Capturar mouse correctamente (NO se escapará de la ventana)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pos_inicial_camara = camara.position


# --- RECUPERA EL MOUSE SI SE LIBERA (por Alt+Tab, etc.) ---
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		# Si el jugador hace clic y el mouse no está capturado, capturarlo otra vez
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# --- MOVER CÁMARA CON MOUSE (solo si puede moverse) ---
func _unhandled_input(event):
	if puede_moverse and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSIBILIDAD)
		camara.rotate_x(-event.relative.y * SENSIBILIDAD)
		camara.rotation.x = clamp(camara.rotation.x, deg_to_rad(-90), deg_to_rad(90))


# --- BLOQUEAR / DESBLOQUEAR MOVIMIENTO (usado por el libro) ---
func cambiar_estado_movimiento(activo: bool):
	puede_moverse = activo
	if not activo:
		velocity = Vector3.ZERO


func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity.y -= gravedad * delta

	# Movimiento bloqueado (leyendo)
	if not puede_moverse:
		if anim_player.current_animation != anim_quieto:
			anim_player.play(anim_quieto, 0.2)
		move_and_slide()
		return

	# --- MOVIMIENTO NORMAL ---

	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = SALTO

	# WASD
	var input_dir := Input.get_vector("izquierda", "derecha", "adelante", "atras")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * VELOCIDAD
		velocity.z = direction.z * VELOCIDAD

		if anim_player.current_animation != anim_caminar:
			anim_player.play(anim_caminar, -1, 1.0)
	else:
		velocity.x = move_toward(velocity.x, 0, VELOCIDAD)
		velocity.z = move_toward(velocity.z, 0, VELOCIDAD)

		if is_on_floor() and anim_player.current_animation != anim_quieto:
			anim_player.play(anim_quieto, 0.2)

	# --- HEAD BOB ---
	if is_on_floor():
		if direction:
			t_bob += delta * velocity.length()
			_headbob(t_bob)
		else:
			camara.position = camara.position.lerp(pos_inicial_camara, 10 * delta)

	move_and_slide()


func _headbob(time) -> void:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FRECUENCIA) * BOB_AMPLITUD
	pos.x = -cos(time * BOB_FRECUENCIA / 2) * BOB_AMPLITUD
	camara.position = pos_inicial_camara + pos

extends CharacterBody3D

# --- CONFIGURACIÓN DE MOVIMIENTO ---
# Velocidad reducida a 2.5 como pediste
const VELOCIDAD = 2.75
const SALTO = 4.5
const SENSIBILIDAD = 0.003
var gravedad = ProjectSettings.get_setting("physics/3d/default_gravity")

# --- CONFIGURACIÓN DEL TAMBALEO (HEAD BOB) ---
# SINCRONIZACIÓN:
# Al caminar lento (2.5), necesitamos una frecuencia baja.
# 1.8 es ideal para simular pasos pesados o tranquilos.
const BOB_FRECUENCIA = 4.2
const BOB_AMPLITUD = 0.09
var t_bob = 0.0
var pos_inicial_camara = Vector3.ZERO

# --- REFERENCIAS ---
@onready var camara = $Camera3D
# Asegúrate de que esta ruta sea correcta ("Root Scene" o el nombre de tu modelo)
@onready var anim_player = $"Root Scene/AnimationPlayer"

# --- NOMBRES DE ANIMACIONES ---
var anim_caminar = "HumanArmature|Man_Walk"
var anim_quieto = "HumanArmature|Man_Idle"

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pos_inicial_camara = camara.position

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSIBILIDAD)
		camara.rotate_x(-event.relative.y * SENSIBILIDAD)
		camara.rotation.x = clamp(camara.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity.y -= gravedad * delta

	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = SALTO

	# Movimiento
	var input_dir := Input.get_vector("izquierda", "derecha", "adelante", "atras")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * VELOCIDAD
		velocity.z = direction.z * VELOCIDAD
		
		# Animación de Caminar
		# OPCIONAL: Si notas que los pies "resbalan" porque la animación va muy rápido
		# para la velocidad lenta, cambia la línea de abajo por:
		# anim_player.play(anim_caminar, -1, 0.5) <--- El 0.5 hace la animación más lenta
		if anim_player.current_animation != anim_caminar:
			anim_player.play(anim_caminar)
			
	else:
		velocity.x = move_toward(velocity.x, 0, VELOCIDAD)
		velocity.z = move_toward(velocity.z, 0, VELOCIDAD)
		
		# Animación de Quieto
		if is_on_floor():
			if anim_player.current_animation != anim_quieto:
				anim_player.play(anim_quieto, 0.2)

	# --- LÓGICA DEL TAMBALEO ---
	if is_on_floor():
		if direction:
			# El tambaleo ahora usa la velocidad reducida para calcular el tiempo
			t_bob += delta * velocity.length()
			_headbob(t_bob)
		else:
			camara.position = camara.position.lerp(pos_inicial_camara, 10 * delta)

	move_and_slide()

# Función de movimiento de cámara
func _headbob(time) -> void:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FRECUENCIA) * BOB_AMPLITUD
	pos.x = cos(time * BOB_FRECUENCIA / 2) * BOB_AMPLITUD
	camara.position = pos_inicial_camara + pos

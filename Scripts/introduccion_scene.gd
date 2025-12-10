extends Control

func _ready():
	# 1. Asegura que el mouse esté VISIBLE al entrar a esta escena 2D
	# (Esto soluciona el problema de que el mouse no aparezca para hacer clic)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# 2. Asegura que el juego no esté pausado, si lo estaba antes
	get_tree().paused = false


func _on_button_play_pressed():
	# 3. ANTES de volver al mundo 3D, ocultamos el mouse
	# para que puedas controlar la cámara inmediatamente.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Esta instrucción le dice al juego que cambie a la escena del nivel 3D.
	get_tree().change_scene_to_file("res://Scenes/first_3d.tscn")

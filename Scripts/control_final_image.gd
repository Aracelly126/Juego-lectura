extends Control

func _ready():
	# 1. Asegura que el mouse esté VISIBLE al entrar a esta escena 2D
	# (Esto soluciona el problema de que el mouse no aparezca para hacer clic)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# 2. Asegura que el juego no esté pausado, si lo estaba antes
	get_tree().paused = false


func _on_boton_regreso_3d_pressed():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().change_scene_to_file("res://Scenes/Libreria.tscn")

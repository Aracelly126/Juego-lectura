extends Control

func _on_button_play_pressed():
	# Esta instrucción le dice al juego que cambie a la escena del nivel 3D.
	get_tree().change_scene_to_file("res://Scenes/first_3d.tscn")

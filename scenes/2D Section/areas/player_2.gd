extends Player
func _input(event):
	if event.is_action_pressed("travel"):
		get_tree().change_scene_to_file("res://scenes/2D Section/areas/mountain_past.tscn")

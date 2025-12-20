extends Node2D
@export var plant_scene: PackedScene

func _ready():
	
	if Global.plant_planted_position != Vector2.ZERO:
		var plant_instance = plant_scene.instantiate()
		plant_instance.global_position = Global.plant_planted_position
		add_child(plant_instance)

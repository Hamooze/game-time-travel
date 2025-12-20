extends Node2D
@export var tree_scene: PackedScene
@export var plant_scene: PackedScene
@export var original_plant_position: Vector2 = Vector2(79, 26.5)  

func _ready():
	# Spawn tree if plant was planted in the past
	if Global.plant_planted_position != Vector2.ZERO:
		var tree_instance = tree_scene.instantiate()
		tree_instance.global_position = Global.plant_planted_position
		add_child(tree_instance)
	
	# Spawn plant if not collected yet
	if not Global.plant_collected and plant_scene:
		var plant_instance = plant_scene.instantiate()
		plant_instance.global_position = original_plant_position
		add_child(plant_instance)

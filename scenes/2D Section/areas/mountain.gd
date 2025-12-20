extends Node2D
@export var tree_scene: PackedScene
@export var plant_scene: PackedScene
@export var original_plant_position: Vector2 = Vector2(165, -41)  
@export var fixed_bridge: TileMapLayer
@export var broke_bridge: TileMapLayer

func _ready():
	# Spawn tree if plant was planted in the past
	if Global.plant_planted_position != Vector2.ZERO:
		var tree_instance = tree_scene.instantiate()
		tree_instance.global_position = Global.plant_planted_position
		add_child(tree_instance)
		fixed_bridge.visible = true
		broke_bridge.queue_free()
	
	# Spawn plant if not collected yet
	if not Global.plant_collected and plant_scene:
		var plant_instance = plant_scene.instantiate()
		plant_instance.global_position = original_plant_position
		add_child(plant_instance)

extends Area2D
@export var target_scene := "Mountain"
@export var spawn_position := Vector2.ZERO  # optional

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	print("WalkingToMountain ready - target_scene: ", target_scene, " spawn_position: ", spawn_position)

func _on_body_entered(body: Node2D) -> void:
	print("WalkingToMountain: body_entered - ", body.name, " (", body.get_class(), ")")
	if body is Player:
		print("WalkingToMountain: Player detected! Transitioning to: ", target_scene)
		# Use spawn_position if set, otherwise Vector2.ZERO (AreaManager will use default)
		var actual_spawn = spawn_position if spawn_position != Vector2.ZERO else Vector2.ZERO
		AreaManager.transition_to_scene(target_scene, actual_spawn)
	else:
		print("WalkingToMountain: Body is not Player, ignoring")

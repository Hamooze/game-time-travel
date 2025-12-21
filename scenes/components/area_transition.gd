class_name AreaTransition
extends Area2D

@export var target_scene: String = ""
@export var player_spawn_position: Vector2 = Vector2.ZERO
@export var spawn_offset: Vector2 = Vector2(0, 40) # Default offset to position player outside the transition area

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	print("AreaTransition ready - target_scene: ", target_scene, " collision_mask: ", collision_mask)

func _on_body_entered(body: Node2D) -> void:
	print("AreaTransition: body_entered - ", body.name, " (", body.get_class(), ")")
	# Check if body is a CharacterBody2D (works for both Player and Car)
	if body is CharacterBody2D:
		print("AreaTransition: CharacterBody2D detected!")
		# If no specific spawn position is set, use the transition area's position plus an offset
		var actual_spawn_position = player_spawn_position
		if actual_spawn_position == Vector2.ZERO:
			actual_spawn_position = global_position + spawn_offset
			
		# Call the AreaManager to handle the transition
		print("Transition to: " + target_scene + " at position: " + str(actual_spawn_position))
		call_deferred("_deferred_transition", target_scene, actual_spawn_position)
	else:
		print("AreaTransition: Body is not CharacterBody2D, ignoring")


# New method for deferred transition
func _deferred_transition(target_scene: String, actual_spawn_position: Vector2) -> void:
	AreaManager.transition_to_scene(target_scene, actual_spawn_position)

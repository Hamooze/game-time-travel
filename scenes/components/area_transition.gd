class_name AreaTransition
extends Area2D

@export var target_scene: String = ""
@export var player_spawn_position: Vector2 = Vector2.ZERO
@export var spawn_offset: Vector2 = Vector2(0, 40) # Default offset to position player outside the transition area

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		# If no specific spawn position is set, use the transition area's position plus an offset
		var actual_spawn_position = player_spawn_position
		if actual_spawn_position == Vector2.ZERO:
			actual_spawn_position = global_position + spawn_offset
			
		# Call the AreaManager to handle the transition
		print("Transition to: " + target_scene + " at position: " + str(actual_spawn_position))
		call_deferred("_deferred_transition", target_scene, actual_spawn_position)


# New method for deferred transition
func _deferred_transition(target_scene: String, actual_spawn_position: Vector2) -> void:
	AreaManager.transition_to_scene(target_scene, actual_spawn_position)

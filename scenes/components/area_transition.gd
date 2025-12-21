class_name AreaTransition
extends Area2D

@export var target_scene: String = ""
@export var player_spawn_position: Vector2 = Vector2.ZERO
@export var spawn_offset: Vector2 = Vector2(0, 40) # Default offset to position player outside the transition area

var transition_cooldown: bool = false
var scene_ready: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Wait a frame before allowing transitions to prevent immediate triggering
	await get_tree().process_frame
	scene_ready = true
	print("AreaTransition ready - target_scene: ", target_scene, " collision_mask: ", collision_mask)

func _on_body_entered(body: Node2D) -> void:
	print("AreaTransition: body_entered - ", body.name, " (", body.get_class(), ")")
	
	# Prevent immediate transition on scene load
	if not scene_ready:
		print("AreaTransition: Scene not ready yet, ignoring transition")
		return
	
	# Prevent multiple transitions
	if transition_cooldown:
		print("AreaTransition: Transition cooldown active, ignoring")
		return
	
	# Check if body is specifically the Player (by name and type)
	# Player nodes are always named "Player" or "Player2" (in mountain scenes)
	if body is CharacterBody2D and (body.name == "Player" or body.name == "Player2"):
		print("AreaTransition: Player detected! (", body.name, ")")
		transition_cooldown = true
		
		# If no specific spawn position is set, use the transition area's position plus an offset
		var actual_spawn_position = player_spawn_position
		if actual_spawn_position == Vector2.ZERO:
			actual_spawn_position = global_position + spawn_offset
			
		# Call the AreaManager to handle the transition
		print("Transition to: " + target_scene + " at position: " + str(actual_spawn_position))
		call_deferred("_deferred_transition", target_scene, actual_spawn_position)
	else:
		print("AreaTransition: Body is not Player (name: ", body.name, ", type: ", body.get_class(), "), ignoring")


# New method for deferred transition
func _deferred_transition(target_scene: String, actual_spawn_position: Vector2) -> void:
	AreaManager.transition_to_scene(target_scene, actual_spawn_position)

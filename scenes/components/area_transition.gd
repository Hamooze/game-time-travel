class_name AreaTransition
extends Area2D

@export var target_scene: String = ""
@export var player_spawn_position: Vector2 = Vector2.ZERO
@export var spawn_offset: Vector2 = Vector2(0, 40) # Default offset to position player outside the transition area

var transition_cooldown: bool = false
var scene_ready: bool = false
var cooldown_timer: float = 0.0
var cooldown_duration: float = 1.0  # 1 second cooldown after transition

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Reset cooldown when scene loads
	transition_cooldown = false
	cooldown_timer = 0.0
	# Wait longer before allowing transitions to prevent immediate triggering
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout  # Additional 0.5 second delay
	scene_ready = true
	print("AreaTransition ready - target_scene: ", target_scene, " collision_mask: ", collision_mask)

func _process(_delta: float) -> void:
	# Handle cooldown timer
	if transition_cooldown:
		cooldown_timer += _delta
		if cooldown_timer >= cooldown_duration:
			transition_cooldown = false
			cooldown_timer = 0.0
			print("AreaTransition: Cooldown expired")

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
	
	# Check if body is specifically the Player or Car (by name and type)
	# Player nodes are always named "Player" or "Player2" (in mountain scenes)
	# Car is used in the side scroller scene
	if body is CharacterBody2D and (body.name == "Player" or body.name == "Player2" or body.name == "Car"):
		print("AreaTransition: Valid character detected! (", body.name, ")")
		
		transition_cooldown = true
		cooldown_timer = 0.0
		
		# If no specific spawn position is set, use the transition area's position plus an offset
		var actual_spawn_position = player_spawn_position
		if actual_spawn_position == Vector2.ZERO:
			actual_spawn_position = global_position + spawn_offset
			
		# Call the AreaManager to handle the transition
		print("Transition to: " + target_scene + " at position: " + str(actual_spawn_position))
		call_deferred("_deferred_transition", target_scene, actual_spawn_position)
	else:
		print("AreaTransition: Body is not Player/Car (name: ", body.name, ", type: ", body.get_class(), "), ignoring")


# New method for deferred transition
func _deferred_transition(target_scene: String, actual_spawn_position: Vector2) -> void:
	AreaManager.transition_to_scene(target_scene, actual_spawn_position)

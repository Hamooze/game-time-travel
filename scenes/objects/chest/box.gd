extends CharacterBody2D

@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var push_distance: float = 50.0
@export var move_speed: float = 100.0
@export var max_interaction_distance: float = 60.0  # Maximum distance player can be to push box

var is_moving = false

func _ready() -> void:
	interactable_component.interacted.connect(on_interacted)

func on_interacted() -> void:
	if interactable_component.player_in_range and not is_moving:
		# Check if player is close enough
		var player = find_player_in_scene(get_tree().root)
		if player == null:
			return
		
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player > max_interaction_distance:
			return  # Player is too far away
		
		# Only move if this box is the closest one to the player
		if is_closest_box_to_player():
			move_box()

func is_closest_box_to_player() -> bool:
	var player = find_player_in_scene(get_tree().root)
	if player == null:
		return false
	
	var my_distance = global_position.distance_to(player.global_position)
	var interactable_components = get_tree().get_nodes_in_group("interactable")
	
	# Check if any other box is closer
	for component in interactable_components:
		if component is InteractableComponent and component.player_in_range:
			var other_box = component.get_parent()
			if other_box != self and other_box is CharacterBody2D:
				var other_distance = other_box.global_position.distance_to(player.global_position)
				if other_distance < my_distance:
					return false
	
	return true

func move_box() -> void:
	var player = find_player_in_scene(get_tree().root)
	if player == null:
		return
	
	var relative_pos = player.global_position - global_position
	var abs_x = abs(relative_pos.x)
	var abs_y = abs(relative_pos.y)
	var target_pos = global_position
	
	# Determine axis using ratio-based check (1.2 ratio threshold)
	var ratio_y_to_x = abs_y / abs_x if abs_x > 0 else 999
	var ratio_x_to_y = abs_x / abs_y if abs_y > 0 else 999
	
	if ratio_y_to_x > 1.2:
		# Move on Y axis (away from player)
		target_pos.y += push_distance if relative_pos.y < 0 else -push_distance
	elif ratio_x_to_y > 1.2:
		# Move on X axis (away from player)
		target_pos.x += push_distance if relative_pos.x < 0 else -push_distance
	else:
		# Fallback: use whichever is larger
		if abs_x >= abs_y:
			target_pos.x += push_distance if relative_pos.x < 0 else -push_distance
		else:
			target_pos.y += push_distance if relative_pos.y < 0 else -push_distance
	
	if target_pos != global_position:
		move_to_position(target_pos)

func move_to_position(target: Vector2) -> void:
	is_moving = true
	if collision_shape != null:
		collision_shape.disabled = true
	
	var duration = max(global_position.distance_to(target) / move_speed, 0.1)
	var tween = create_tween()
	tween.tween_property(self, "global_position", target, duration)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func(): 
		is_moving = false
		if collision_shape != null:
			collision_shape.disabled = false
	)

func find_player_in_scene(node: Node) -> Node:
	if node.name == "Player" and node is CharacterBody2D:
		return node
	for child in node.get_children():
		var result = find_player_in_scene(child)
		if result != null:
			return result
	return null

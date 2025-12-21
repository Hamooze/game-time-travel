# facility_past.gd
extends Node2D

var player: CharacterBody2D = null
var place_area: Area2D = null

func _ready():
	player = find_child("Player", true, false)
	place_area = find_child("Place", true, false)
	
	# Restore placed boxes for this scene
	await get_tree().process_frame  # Wait for player to be fully ready
	restore_placed_boxes()
	check_box_in_place_area()

func restore_placed_boxes():
	if player == null:
		print("restore_placed_boxes: player is null")
		return
	
	# Get box_scene from player
	var box_scene = player.box_scene
	if box_scene == null:
		print("restore_placed_boxes: No box_scene found in player")
		return
	
	# Use consistent scene identifier
	var scene_id = "facility_past"
	print("Restoring boxes for scene: ", scene_id, " | Total tracked boxes: ", Global.placed_boxes.size())
	
	# Restore all placed boxes for this scene
	var restored_count = 0
	for box_data in Global.placed_boxes:
		var box_scene_id = box_data.get("scene_id", "")
		print("Checking box: scene_id=", box_scene_id, " position=", box_data.get("position"))
		
		if box_scene_id == scene_id:
			# Check if this box was already collected
			var box_id = box_data.get("collectable_id", "")
			if Global.collected_objects.get(box_id, false):
				print("Skipping collected box: ", box_id)
				continue  # Skip collected boxes
			
			# Create the box instance
			var box_instance = box_scene.instantiate()
			box_instance.global_position = box_data.get("position", Vector2.ZERO)
			box_instance.collectable_id = box_id
			# Set z_index to appear above Lab (z_index=1) and Door (z_index=2) layers
			box_instance.z_index = 3
			add_child(box_instance)
			restored_count += 1
			print("✓ Restored placed box at: ", box_instance.global_position, " with ID: ", box_id)
	
	print("Restored ", restored_count, " boxes for ", scene_id)

func check_box_in_place_area():
	# Check if any box is inside the Place Area2D
	if place_area == null:
		return
	
	# Get all boxes in the scene (they should be BoxCollectable nodes)
	var boxes = get_tree().get_nodes_in_group("box_collectable")
	var box_in_place = false
	
	for box in boxes:
		if box == null:
			continue
		
		var box_pos = box.global_position
		
		# Check if the box's InteractableComponent (Area2D) overlaps with Place area
		var box_interactable = box.get_node_or_null("InteractableComponent")
		if box_interactable != null and box_interactable is Area2D:
			# Get overlapping areas from the Place area
			var overlapping_areas = place_area.get_overlapping_areas()
			if box_interactable in overlapping_areas:
				box_in_place = true
				break
		
		# Fallback: Check if box position is inside Place area's collision shape
		# Get the Place area's collision shape
		var place_collision = place_area.get_node_or_null("CollisionShape2D")
		if place_collision != null and place_collision.shape != null:
			# Convert box position to local space of Place area
			var local_pos = place_area.to_local(box_pos)
			# Check if point is inside the shape (for RectangleShape2D)
			if place_collision.shape is RectangleShape2D:
				var rect_shape = place_collision.shape as RectangleShape2D
				var rect_pos = place_collision.position
				var rect_size = rect_shape.size
				var rect_min = rect_pos - rect_size / 2.0
				var rect_max = rect_pos + rect_size / 2.0
				
				if local_pos.x >= rect_min.x and local_pos.x <= rect_max.x and \
				   local_pos.y >= rect_min.y and local_pos.y <= rect_max.y:
					box_in_place = true
					break
	
	# Update Global state and emit signal if state changed
	if box_in_place != Global.door_jammed_in_past:
		Global.door_jammed_in_past = box_in_place
		Global.door_state_changed.emit(box_in_place)
		print("Door state changed: jammed = ", box_in_place)


func _physics_process(_delta):
	if player == null:
		return
	
	# Check for travel button press (Q key) to transition back to facility_entrance (present)
	if Input.is_action_just_pressed("travel"):
		# Get player's current position to maintain it in the new scene
		var player_position = player.global_position
		print("Travel key (Q) pressed - transitioning back to FacilityEntrance (present) at position: ", player_position)
		AreaManager.transition_to_scene("FacilityEntrance", player_position)
		return
	
	# Check if any box is in the Place area
	check_box_in_place_area()
	
	# Check for interact button press
	if Input.is_action_just_pressed("interact"):
		# Find nearby box
		var interactable_components = get_tree().get_nodes_in_group("interactable")
		for component in interactable_components:
			if component is InteractableComponent:
				if component.player_in_range:
					var box = component.get_parent()
					if box != null and box.has_method("push_forward"):
						var box_pos = box.global_position
						var player_pos = player.global_position
						var relative_pos = player_pos - box_pos
						
						# Only allow pushing from left or right sides
						# Require horizontal distance to be at least 1.2x the vertical distance
						# This ensures player is clearly on the side, not at an angle
						var horizontal_dist = abs(relative_pos.x)
						var vertical_dist = abs(relative_pos.y)
						
						# Also require minimum horizontal distance to avoid edge cases
						if horizontal_dist < 10.0 or (vertical_dist > 0 and horizontal_dist < vertical_dist * 1.2):
							# Player is not clearly on the side (too much vertical component or too close)
							break
						
						# Determine push direction based on which side player is on
						var push_dir = Vector2.ZERO
						if relative_pos.x < 0:
							# Player is on left side, push right
							push_dir = Vector2.RIGHT
						else:
							# Player is on right side, push left
							push_dir = Vector2.LEFT
						
						# Push the box
						box.push_forward(push_dir, player_pos)
						
						# Play push animation
						var anim = player.get_node_or_null("AnimatedSprite2D")
						if anim != null and anim.sprite_frames != null:
							if anim.sprite_frames.has_animation("push"):
								if push_dir.x > 0:
									anim.flip_h = false
								else:
									anim.flip_h = true
								anim.play("push")
						break

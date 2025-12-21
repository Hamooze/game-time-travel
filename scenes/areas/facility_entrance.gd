# facility_entrance.gd
extends Node2D

var player: CharacterBody2D = null
var map_tileset: Node2D = null
var boxes_layer: TileMapLayer = null
var door_layer: TileMapLayer = null
var door_open_layer: TileMapLayer = null

func _ready():
	player = find_child("Player", true, false)
	map_tileset = find_child("MapTileSet", true, false)
	
	# Find the tile map layers
	if map_tileset:
		boxes_layer = map_tileset.get_node_or_null("Boxes")
		door_layer = map_tileset.get_node_or_null("DoorClose")
		door_open_layer = map_tileset.get_node_or_null("DoorOpen")
	
	# Connect to Global signal for door state changes
	if not Global.door_state_changed.is_connected(_on_door_state_changed):
		Global.door_state_changed.connect(_on_door_state_changed)
	
	# Restore placed boxes for this scene
	await get_tree().process_frame  # Wait for player to be fully ready
	restore_placed_boxes()
	
	# Update door layers based on current Global state
	update_door_layers(Global.door_jammed_in_past)

func _on_door_state_changed(jammed: bool):
	# Called when door state changes (box placed/removed in past)
	update_door_layers(jammed)

func update_door_layers(jammed: bool):
	# Show Boxes layer and DoorOpen, hide DoorClose when door is jammed
	if jammed:
		if boxes_layer:
			boxes_layer.visible = true
		if door_open_layer:
			door_open_layer.visible = true
		if door_layer:
			door_layer.visible = false
		print("Door layers updated: OPEN (box jammed in past)")
	else:
		# Default state: hide Boxes and DoorOpen, show DoorClose
		if boxes_layer:
			boxes_layer.visible = false
		if door_open_layer:
			door_open_layer.visible = false
		if door_layer:
			door_layer.visible = true
		print("Door layers updated: CLOSED")

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
	var scene_id = "facility_entrance"
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
			# Set z_index to appear above Lab and Door layers
			box_instance.z_index = 3
			add_child(box_instance)
			restored_count += 1
			print("✓ Restored placed box at: ", box_instance.global_position, " with ID: ", box_id)
	
	print("Restored ", restored_count, " boxes for ", scene_id)

func _physics_process(_delta):
	if player == null:
		return
	
	# Check for travel button press (Q key) to transition to facility_past
	if Input.is_action_just_pressed("travel"):
		# Get player's current position to maintain it in the new scene
		var player_position = player.global_position
		print("Travel key (Q) pressed - transitioning to FacilityPast at position: ", player_position)
		AreaManager.transition_to_scene("FacilityPast", player_position)
		return
	
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

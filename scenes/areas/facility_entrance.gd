# facility_entrance.gd
extends Node2D

var player: CharacterBody2D = null

func _ready():
	player = find_child("Player", true, false)

func _physics_process(_delta):
	if player == null:
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

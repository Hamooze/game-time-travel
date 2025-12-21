extends Sprite2D

@onready var interactable_component: InteractableComponent = $InteractableComponent

# Unique identifier for this collectable (set by parent scene or auto-generated)
@export var collectable_id: String = ""

func _ready() -> void:
	if interactable_component:
		interactable_component.interacted.connect(_on_interacted)
		# Add to group for interaction prompt detection
		add_to_group("box_collectable")
	else:
		push_warning("BoxCollectable: missing InteractableComponent child.")
	
	# Set z_index to appear above Lab and Door layers (Lab=1, Door=2)
	z_index = 3
	
	# Generate unique ID if not set (based on scene and position, separate for each time period)
	# This allows past and present boxes to be tracked separately
	if collectable_id.is_empty():
		var scene_name = get_tree().current_scene.name.to_lower().replace(" ", "_")
		var pos_str = str(int(global_position.x)) + "_" + str(int(global_position.y))
		collectable_id = scene_name + ":box_" + pos_str  # Separate ID for present vs past
	
	# Check if this object has already been collected
	if Global.collected_objects.get(collectable_id, false):
		print("Box already collected: ", collectable_id, " - hiding")
		queue_free()

func _on_interacted() -> void:
	if interactable_component.player_in_range:
		print("✓ Collected Box! ID: ", collectable_id)
		Global.has_box = true
		# Mark this object as collected
		Global.collected_objects[collectable_id] = true
		
		# Remove from placed_boxes if it was a placed box
		for i in range(Global.placed_boxes.size() - 1, -1, -1):
			if Global.placed_boxes[i].get("collectable_id") == collectable_id:
				Global.placed_boxes.remove_at(i)
				break
		
		queue_free()


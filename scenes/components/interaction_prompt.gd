extends Control

var interactables_in_range: int = 0

func _ready():
	visible = false
	# Connect to all interactable components
	connect_to_interactables()

func connect_to_interactables():
	# Wait for scene tree to be ready
	await get_tree().process_frame
	
	# Connect to InteractableComponent signals
	var interactables = get_tree().get_nodes_in_group("interactable")
	for interactable in interactables:
		if interactable is InteractableComponent:
			if not interactable.interactable_activated.is_connected(_on_interactable_activated):
				interactable.interactable_activated.connect(_on_interactable_activated)
			if not interactable.interactable_deactivated.is_connected(_on_interactable_deactivated):
				interactable.interactable_deactivated.connect(_on_interactable_deactivated)

func _process(_delta):
	# Check for SpecialItem objects (they don't use InteractableComponent)
	var special_items_in_range = 0
	var special_items = get_tree().get_nodes_in_group("special_item")
	for item in special_items:
		if "player_in_range" in item and item.player_in_range:
			special_items_in_range += 1
	
	# Check for BoxCollectable objects (they use InteractableComponent, so already counted in interactables_in_range)
	# But we can add them to a group for future use if needed
	
	# Check for car interaction in pre_car scene
	var car_in_range = false
	var player = find_player_in_scene(get_tree().root)
	if player != null:
		# Check if player has is_near_car property by trying to access it
		if "is_near_car" in player:
			if player.is_near_car:
				car_in_range = true
	
	# Update visibility based on all interaction types
	# BoxCollectable uses InteractableComponent, so it's already included in interactables_in_range
	var total_in_range = interactables_in_range + special_items_in_range + (1 if car_in_range else 0)
	visible = total_in_range > 0

func find_player_in_scene(node: Node) -> Node:
	if node.name == "Player" and node is CharacterBody2D:
		return node
	for child in node.get_children():
		var result = find_player_in_scene(child)
		if result != null:
			return result
	return null

func _on_interactable_activated():
	interactables_in_range += 1

func _on_interactable_deactivated():
	interactables_in_range = max(0, interactables_in_range - 1)

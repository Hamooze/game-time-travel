extends Node2D
@export var tree_scene: PackedScene
@export var plant_scene: PackedScene
@export var original_plant_position: Vector2 = Vector2(165, -41)  
@export var fixed_bridge: TileMapLayer
@export var broke_bridge: TileMapLayer

@onready var paper2: Sprite2D = $paper2

var player: CharacterBody2D = null

func _ready():
	# In mountain scene, the player is named "Player2"
	player = find_child("Player2", true, false)
	if player == null:
		print("ERROR: Player2 not found in mountain scene!")
	else:
		print("Mountain scene: Player2 found at position: ", player.global_position)
	
	# Find bridge layers if not assigned
	if fixed_bridge == null:
		fixed_bridge = find_child("FixedBridge2", true, false)
	if broke_bridge == null:
		broke_bridge = find_child("Bridge2", true, false)
	
	# Spawn tree if plant was planted in the past
	if Global.plant_planted_position != Vector2.ZERO:
		var tree_instance = tree_scene.instantiate()
		tree_instance.global_position = Global.plant_planted_position
		add_child(tree_instance)
		if fixed_bridge != null:
			fixed_bridge.visible = true
			fixed_bridge.collision_enabled = true  # Enable collision on fixed bridge
		if broke_bridge != null:
			broke_bridge.visible = false
			broke_bridge.collision_enabled = false  # Disable collision on broken bridge
	else:
		# Plant not planted yet - ensure broken bridge has collision and fixed bridge doesn't
		if broke_bridge != null:
			broke_bridge.visible = true
			broke_bridge.collision_enabled = true  # Enable collision on broken bridge
		if fixed_bridge != null:
			fixed_bridge.visible = false
			fixed_bridge.collision_enabled = false  # Disable collision on fixed bridge
	
	# Spawn plant if not collected yet
	if not Global.plant_collected and plant_scene:
		var plant_instance = plant_scene.instantiate()
		plant_instance.global_position = original_plant_position
		add_child(plant_instance)

var travel_cooldown = false

func _physics_process(_delta):
	if player == null:
		return
	
	# Check for travel button press (Q key) to transition to mountain_past
	if Input.is_action_just_pressed("travel") and not travel_cooldown:
		travel_cooldown = true
		# Play travel sound effect if available
		if player.has_method("_play_travel_sfx"):
			player._play_travel_sfx()
		
		# Get player's current position to maintain it in the new scene
		var player_position = player.global_position
		print("Travel key (Q) pressed - transitioning to MountainPast at position: ", player_position)
		
		# Wait for sound effect, then transition (using call_deferred to handle async)
		var timer = get_tree().create_timer(0.15)
		timer.timeout.connect(func(): 
			AreaManager.transition_to_scene("MountainPast", player_position)
			travel_cooldown = false
		)
		
func _process(delta: float) -> void:
	if Global.paper2_up:
		if paper2.visible == true:
			paper2.visible = false
	

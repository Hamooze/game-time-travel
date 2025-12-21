extends Node2D
@export var plant_scene: PackedScene

var player: CharacterBody2D = null

func _ready():
	player = find_child("Player", true, false)
	if player == null:
		print("ERROR: Player not found in mountain_past scene!")
	else:
		print("Mountain_past scene: Player found at position: ", player.global_position)
	
	if Global.plant_planted_position != Vector2.ZERO:
		var plant_instance = plant_scene.instantiate()
		plant_instance.global_position = Global.plant_planted_position
		add_child(plant_instance)

var travel_cooldown = false

func _physics_process(_delta):
	if player == null:
		return
	
	# Check for travel button press (Q key) to transition back to mountain (present)
	if Input.is_action_just_pressed("travel") and not travel_cooldown:
		travel_cooldown = true
		# Play travel sound effect if available
		if player.has_method("_play_travel_sfx"):
			player._play_travel_sfx()
		
		# Get player's current position to maintain it in the new scene
		var player_position = player.global_position
		print("Travel key (Q) pressed - transitioning back to Mountain (present) at position: ", player_position)
		
		# Wait for sound effect, then transition (using call_deferred to handle async)
		var timer = get_tree().create_timer(0.15)
		timer.timeout.connect(func(): 
			AreaManager.transition_to_scene("Mountain", player_position)
			travel_cooldown = false
		)

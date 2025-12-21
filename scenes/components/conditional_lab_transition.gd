class_name ConditionalLabTransition
extends Area2D

@export var target_scene: String = "Lab"
@export var player_spawn_position: Vector2 = Vector2.ZERO
@export var prompt_text: String = "Press E to enter Lab"

var player_in_range: bool = false
var door_is_open: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	add_to_group("lab_transition")
	
	# Connect to Global signal for door state changes
	if not Global.door_state_changed.is_connected(_on_door_state_changed):
		Global.door_state_changed.connect(_on_door_state_changed)
	
	# Check initial door state
	check_door_state()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and (body.name == "Player" or body.get_script() != null):
		player_in_range = true
		update_interaction_prompt()

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and (body.name == "Player" or body.get_script() != null):
		player_in_range = false
		update_interaction_prompt()

func _on_door_state_changed(jammed: bool) -> void:
	door_is_open = jammed
	update_interaction_prompt()

func check_door_state() -> void:
	# Check if door is open by checking Global state
	door_is_open = Global.door_jammed_in_past
	update_interaction_prompt()

func update_interaction_prompt() -> void:
	# The interaction prompt will check this node's state in its _process
	# No need to manually update it here
	pass

func _process(_delta: float) -> void:
	# Only allow transition if door is open and player is in range
	if door_is_open and player_in_range:
		if Input.is_action_just_pressed("interact"):
			# Transition to lab
			var actual_spawn_position = player_spawn_position
			if actual_spawn_position == Vector2.ZERO:
				actual_spawn_position = global_position
			
			print("Transitioning to Lab at position: ", actual_spawn_position)
			AreaManager.transition_to_scene(target_scene, actual_spawn_position)


class_name InteractableComponent
extends Area2D

signal interactable_activated
signal interactable_deactivated
signal interacted  # New signal for when player presses E

var player_in_range: bool = false

func _ready():
	add_to_group("interactable")

func _process(_delta):
	# Check if player is in range and presses the interact button
	if player_in_range and Input.is_action_just_pressed("interact"):
		interacted.emit()

func _on_body_entered(body: Node2D) -> void:
	# Check if it's a player (CharacterBody2D with player-like name or script)
	if body is CharacterBody2D and (body.name == "Player" or body.get_script() != null):
		player_in_range = true
		interactable_activated.emit()

func _on_body_exited(body: Node2D) -> void:
	# Check if it's a player (CharacterBody2D with player-like name or script)
	if body is CharacterBody2D and (body.name == "Player" or body.get_script() != null):
		player_in_range = false
		interactable_deactivated.emit()

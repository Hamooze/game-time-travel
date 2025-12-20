class_name InteractableComponent
extends Area2D

signal interactable_activated
signal interactable_deactivated
signal interacted  # New signal for when player presses E

var player_in_range: bool = false

func _ready():
	print("InteractableComponent ready")
	add_to_group("interactable")

func _process(_delta):
	# Check if player is in range and presses the interact button
	if player_in_range and Input.is_action_just_pressed("interact"):
		print("Player interacted!")
		interacted.emit()

func _on_body_entered(body: Node2D) -> void:
	# Check if it's a player by looking for CollisionShape2D child node
	if body is CharacterBody2D:
		var collision_shape = body.get_node_or_null("CollisionShape2D")
		if collision_shape != null and collision_shape is CollisionShape2D:
			player_in_range = true
			print("Player entered interactable area")
			interactable_activated.emit()

func _on_body_exited(body: Node2D) -> void:
	# Check if it's a player by looking for CollisionShape2D child node
	if body is CharacterBody2D:
		var collision_shape = body.get_node_or_null("CollisionShape2D")
		if collision_shape != null and collision_shape is CollisionShape2D:
			player_in_range = false
			print("Player exited interactable area")
			interactable_deactivated.emit()

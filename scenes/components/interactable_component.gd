class_name InteractableComponent
extends Area2D

signal interactable_activated
signal interactable_deactivated
signal interacted  # New signal for when player presses E

var player_in_range: bool = false

func _ready():
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	print("InteractableComponent ready")

func _process(_delta):
	# Check if player is in range and presses the interact button
	if player_in_range and Input.is_action_just_pressed("interact"):
		print("Player interacted!")
		interacted.emit()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true
		print("Player entered interactable area")
		interactable_activated.emit()

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		print("Player exited interactable area")
		interactable_deactivated.emit()

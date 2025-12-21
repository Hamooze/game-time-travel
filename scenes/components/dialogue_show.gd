class_name DialogueShow
extends Area2D

var player_in_range: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	add_to_group("dialogue_show")

func _on_body_entered(body: Node2D) -> void:
	# Check if it's the player (Player or Player2)
	if body is CharacterBody2D and (body.name == "Player" or body.name == "Player2"):
		player_in_range = true
		print("DialogueShow: Player entered range")

func _on_body_exited(body: Node2D) -> void:
	# Check if it's the player (Player or Player2)
	if body is CharacterBody2D and (body.name == "Player" or body.name == "Player2"):
		player_in_range = false
		print("DialogueShow: Player exited range")


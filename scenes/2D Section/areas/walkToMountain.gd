extends Area2D
@export var target_scene := "Mountain"
@export var spawn_position := Vector2.ZERO  # optional

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		AreaManager.transition_to_scene(target_scene, spawn_position)

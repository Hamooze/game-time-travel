class_name SpecialItem
extends Sprite2D

@export_file("*.tscn") var on_collect_scene_path := "res://scenes/ANIMATION2/PreAnimation2.tscn"

var player_in_range: bool = false
var area: Area2D

func _ready():
	# Get the Area2D child node
	area = $Area2D
	
	# Connect the Area2D signals
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	
	print("Special Item is ready - Press E to collect!")

func _process(_delta):
	# Check if player is in range and presses the interact button
	if player_in_range and Input.is_action_just_pressed("interact"):
		print("✓ Collected Special Item!")
		_handle_collection()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true
		print("Press E to collect Special Item")

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false


func _handle_collection() -> void:
	if not on_collect_scene_path.is_empty():
		get_tree().change_scene_to_file(on_collect_scene_path)
	else:
		queue_free()

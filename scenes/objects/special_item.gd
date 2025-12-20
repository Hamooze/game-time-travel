class_name SpecialItem
extends Sprite2D

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
		# You can add custom behavior here specific to this item
		# For example: play a special sound, add to inventory, trigger event, etc.
		queue_free()  # Destroy this item

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true
		print("Press E to collect Special Item")

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false

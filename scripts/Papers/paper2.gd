class_name paper2
extends Area2D

@export var collectable_name: String

func _ready():
	# Connect the signal in code to ensure it's connected
	body_entered.connect(_on_body_entered)
	print("CollectableComponent ready: ", collectable_name)
	if Global.plant_collected:
		queue_free()
	

func _on_body_entered(body: Node2D) -> void:
	print("Body entered collectable: ", body.name, " - Type: ", body.get_class())
	
	# Check if the body is a Player
	if body is Player:
		print("✓ Player collected: ", collectable_name)
		# Destroy the parent object (the collectable item)
		
		Global.paper2_up = true
		get_parent().queue_free()

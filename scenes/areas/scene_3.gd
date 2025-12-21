extends Node2D
var dialogue_triggered = false
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	print("=== LEVEL READY ===")
	# Wait for scene to fully load and player to be ready
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("Waiting 0.5 seconds before auto-triggering dialogue...")
	await get_tree().create_timer(0.5).timeout
	
	if not dialogue_triggered:
		print("=== AUTO-TRIGGER STARTING ===")
		dialogue_triggered = true
		
		# Set global dialogue state
		print("Setting Global.in_dialogue to true")
		Global.in_dialogue = true
		print("Global.in_dialogue is now: ", Global.in_dialogue)
		
		# Find the Actionable node and trigger dialogue directly
		var actionable = find_child("Actionable", true, false)
		if actionable:
			print("Found Actionable node")
			
			# Ensure it has a dialogue resource - if not, try to load Dream.dialogue
			if not actionable.dialogue_resource:
				var dream_dialogue = load("res://scripts/Dialogue/Dream.dialogue")
				if dream_dialogue:
					actionable.dialogue_resource = dream_dialogue
					print("Set Dream.dialogue resource on Actionable")
			
			if actionable.has_method("action"):
				print("Triggering dialogue...")
				actionable.action()
				print("Dialogue triggered successfully!")
			else:
				print("ERROR: Actionable node doesn't have action() method")
		else:
			print("ERROR: Could not find Actionable node!")
			# Fallback: try to find it by checking all Area2D nodes
			for node in get_children():
				if node.name == "Actionable" and node.has_method("action"):
					print("Found Actionable via fallback, triggering dialogue...")
					# Ensure dialogue resource is set
					if not node.dialogue_resource:
						var dream_dialogue = load("res://scripts/Dialogue/Dream.dialogue")
						if dream_dialogue:
							node.dialogue_resource = dream_dialogue
					node.action()
					break
		
		print("=== AUTO-TRIGGER COMPLETE ===")
	else:
		print("Dialogue already triggered, skipping auto-trigger")

func _process(delta: float) -> void:
	pass

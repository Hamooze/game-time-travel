extends Node2D
var dialogue_triggered = false
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	print("=== LEVEL READY ===")
	print("Waiting 0.2 seconds before auto-trigger...")
	# Wait 0.2 seconds then press ui_accept
	await get_tree().create_timer(0.2).timeout
	
	if not dialogue_triggered:
		print("=== AUTO-TRIGGER STARTING ===")
		print("Auto-pressing ui_accept")
		dialogue_triggered = true
		
		# Set global dialogue state
		print("Setting Global.in_dialogue to true")
		Global.in_dialogue = true
		print("Global.in_dialogue is now: ", Global.in_dialogue)
		
		# Lock player movement before triggering dialogue
		var player = get_tree().get_first_node_in_group("player")
		if player:
			Global.in_dialogue = true
		else:
			print("ERROR: Could not find player in group!")
		
		# Create and trigger the input event
		print("Creating and parsing ui_accept input event")
		var event = InputEventAction.new()
		event.action = "ui_accept"
		event.pressed = true
		Input.parse_input_event(event)
		print("=== AUTO-TRIGGER COMPLETE ===")
	else:
		print("Dialogue already triggered, skipping auto-trigger")

func _process(delta: float) -> void:
	pass

extends Node2D
var dialogue_triggered = false

@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	# Wait 0.2 seconds then press ui_accept
	await get_tree().create_timer(0.2).timeout
	
	if not dialogue_triggered:
		print("Auto-pressing ui_accept")
		dialogue_triggered = true
		
		# Lock player movement before triggering dialogue
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.movement_locked += 1
			print("Player movement locked by auto-trigger")
		
		# Create and trigger the input event
		var event = InputEventAction.new()
		event.action = "ui_accept"
		event.pressed = true
		Input.parse_input_event(event)

func _process(delta: float) -> void:
	pass

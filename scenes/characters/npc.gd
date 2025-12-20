extends CharacterBody2D

const SPEED = 100.0
@onready var sprite = $AnimatedSprite2D  # Change to your actual sprite node name
var is_moving = false

func _ready():
	# Start invisible
	visible = true
	
	# Wait 1 second
	await get_tree().create_timer(1.0).timeout
	
	# Activate side_walk animation
	sprite.play("side_walk")
	
	# Make visible and start moving
	visible = true
	is_moving = true
	
	# Move right for 5 seconds
	await get_tree().create_timer(5.0).timeout
	
	# Set invisible and stop
	visible = false
	is_moving = false
	velocity.x = 0

func _physics_process(delta: float) -> void:
	# Only move if the flag is set
	if is_moving:
		# Move right
		velocity.x = SPEED
		velocity.y = 0
		
		move_and_slide()

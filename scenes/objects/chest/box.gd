extends CharacterBody2D

@onready var interactable_component: InteractableComponent = $InteractableComponent

var push_force := 60.0  # Reduced push force for more controlled movement
var push_distance := 60.0

func _ready() -> void:
	interactable_component.interactable_activated.connect(on_interactable_activated)
	interactable_component.interactable_deactivated.connect(on_interactable_deactivated)

func on_interactable_activated() -> void:
	pass

func on_interactable_deactivated() -> void:
	pass

func _physics_process(_delta: float) -> void:
	# Only process physics when box has velocity (is being pushed)
	# This prevents any physics interaction when the box is stationary
	if abs(velocity.x) > 0.1:  # Check X velocity specifically since Y is always 0
		move_and_slide()
		
		# Check for collisions with walls/obstacles, but allow pushing through player
		# The player should be able to walk alongside the box as it moves
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider != null:
				# Only stop on non-player collisions (walls, other objects)
				# Don't stop on player collision - let the box push past/through player
				if collider.name != "Player" and not collider.is_in_group("player"):
					# Hit a wall or other object, stop
					velocity = Vector2.ZERO
					return
		
		# Gradually slow down (only X axis) - faster slowdown for quicker stopping
		velocity.x = lerp(velocity.x, 0.0, 0.15)  # Increased from 0.02 to 0.15 for faster slowdown
		velocity.y = 0.0  # Always keep Y at 0
		if abs(velocity.x) < 5.0:  # Increased threshold from 1.0 to 5.0 for faster stopping
			velocity = Vector2.ZERO
	else:
		# Ensure velocity stays zero when not being pushed
		# Don't call move_and_slide() - this prevents any physics interaction
		velocity = Vector2.ZERO

func push_forward(direction: Vector2, player_position: Vector2) -> void:
	# Force horizontal movement only (X axis)
	var dir = Vector2.ZERO
	if direction.x > 0:
		dir = Vector2.RIGHT
	elif direction.x < 0:
		dir = Vector2.LEFT
	else:
		# If no horizontal component, determine from player position
		var relative_pos = global_position - player_position
		if relative_pos.x < 0:
			dir = Vector2.RIGHT  # Player on left, push right
		else:
			dir = Vector2.LEFT   # Player on right, push left
	
	# Set velocity directly based on direction
	velocity = Vector2(dir.x * push_force, 0)

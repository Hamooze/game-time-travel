class_name Player
extends CharacterBody2D
const speed = 60
var current_dir = "none"
var has_plant: bool = false
@export var plant_scene: PackedScene

func collect_plant():
	has_plant = true
	print("Plant collected!")
	
	
func plant():
	if Global.has_plant:
		Global.has_plant = false
		Global.plant_planted_position = global_position 
		print("plant false")
		if plant_scene:
			var plant_instance = plant_scene.instantiate()
			plant_instance.global_position = global_position
			get_parent().add_child(plant_instance)
		else:
			print("Plant scene not assigned!")
			

		return true
	else:
		print("No plant to plant!")
		return false
	


func _physics_process(_delta):
	player_movement(_delta)
	
func player_movement(_delta):
	# Reset velocity
	velocity = Vector2.ZERO
	
	# Check all directions independently (not elif)
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
	if Input.is_action_pressed("ui_left"):
		velocity.x = -speed
	if Input.is_action_pressed("ui_down"):
		velocity.y = speed
	if Input.is_action_pressed("ui_up"):
		velocity.y = -speed
	if Input.is_action_pressed("plant"):  
		plant()
		
	
		
		
	
	
	# Normalize diagonal movement so speed is consistent
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
		# Determine animation direction based on velocity
		# Check for diagonal down movement (down + left/right)
		if velocity.y > 0 and velocity.x != 0:
			# Diagonal down - use side animation
			if velocity.x > 0:
				current_dir = "right"
			else:
				current_dir = "left"
		# Prioritize vertical movement for other diagonals
		elif velocity.y < 0:
			current_dir = "up"
		elif velocity.y > 0:
			current_dir = "down"
		elif velocity.x > 0:
			current_dir = "right"
		elif velocity.x < 0:
			current_dir = "left"
		
		play_anim(1)
	else:
		play_anim(0)
	
	move_and_slide()

func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			anim.play("side_idle")
	elif dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			anim.play("side_idle")
	elif dir == "down":
		if movement == 1:
			anim.play("front_walk")
		elif movement == 0:
			anim.play("front_idle")
	elif dir == "up":
		if movement == 1:
			anim.play("back_walk")
		elif movement == 0:
			anim.play("back_idle")
			
			

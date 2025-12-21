class_name Player
extends CharacterBody2D

const speed = 75
var current_dir = "none"
var has_plant: bool = false
var viewing_papers = false
var current_paper_index = 0
var available_papers = []
var plant_sfx_player: AudioStreamPlayer
@export var plant_sfx: AudioStream



@export var plant_scene: PackedScene
@onready var actionable_finder:Area2D = $ActionableFinder

var papers = []
var papers_container = null
var movement_restricted = false
var restricted_directions = {}

func _ready():
	plant_sfx_player = AudioStreamPlayer.new()
	add_child(plant_sfx_player)
	add_to_group("player")
	print("=== PLAYER READY - SETTING UP PAPERS ===")
	
	# Get reference to Papers Node2D container
	var camera = $Camera2D
	papers_container = camera.get_node_or_null("Papers")
	
	if papers_container:
		print("Found Papers container")
		# Papers container stays visible, but we hide individual papers
		papers_container.visible = true
		
		# Try to get each paper sprite, only add if it exists
		var paper1 = papers_container.get_node_or_null("Paper1")
		var paper2 = papers_container.get_node_or_null("Paper2")
		var paper3 = papers_container.get_node_or_null("Paper3")
		var paper4 = papers_container.get_node_or_null("Paper4")
		var paper5 = papers_container.get_node_or_null("Paper5")
		
		if paper1: 
			papers.append(paper1)
			print("Found Paper1")
		else:
			print("ERROR: Paper1 not found")
			
		if paper2: 
			papers.append(paper2)
			print("Found Paper2")
		else:
			print("ERROR: Paper2 not found")
			
		if paper3: 
			papers.append(paper3)
			print("Found Paper3")
		else:
			print("ERROR: Paper3 not found")
			
		if paper4: 
			papers.append(paper4)
			print("Found Paper4")
		else:
			print("ERROR: Paper4 not found")
			
		if paper5: 
			papers.append(paper5)
			print("Found Paper5")
		else:
			print("ERROR: Paper5 not found")
	else:
		print("ERROR: Papers container not found! Check your scene structure.")
	
	# Hide all papers initially
	for i in range(papers.size()):
		if papers[i]:
			papers[i].visible = false
			print("Set Paper", i+1, " invisible")
	
	print("Total papers found: ", papers.size())
	print("=== PAPER SETUP COMPLETE ===")

func collect_plant():
	has_plant = true
	print("Plant collected!")
	
func _play_plant_sfx():
	print( plant_sfx)
	if plant_sfx_player and plant_sfx:
		plant_sfx_player.stream = plant_sfx
		print("sound played")
		plant_sfx_player.play()

func plant():
	if Global.has_plant:
		Global.has_plant = false
		Global.plant_planted_position = global_position 
		print("plant false")
		if plant_scene:
			var plant_instance = plant_scene.instantiate()
			plant_instance.global_position = global_position
			# Prevent the planted instance from being picked up again.
			if plant_instance.has_method("set_pickup_enabled"):
				plant_instance.call("set_pickup_enabled", false)
			get_parent().add_child(plant_instance)
			_play_plant_sfx()
			print("planted")
		else:
			print("Plant scene not assigned!")
			
		return true
	else:
		print("No plant to plant!")
		return false

func _physics_process(_delta):
	# Check for paper viewing toggle (R key)
	if Input.is_action_just_pressed("ui_focus_next"):  # Map R key to this action in Project Settings
		print("Tab key pressed - toggling paper view")
		toggle_paper_view()
	
	# Handle paper navigation when viewing
	if viewing_papers:
		if Input.is_action_just_pressed("ui_right"):
			print("Right arrow pressed - next paper")
			next_paper()
		elif Input.is_action_just_pressed("ui_left"):
			print("Left arrow pressed - previous paper")
			previous_paper()
	else:
		# Only allow movement when not viewing papers, not in dialogue, and movement not locked
		if not Global.tab_papers and not Global.in_dialogue:
			player_movement(_delta)

func toggle_paper_view():
	if viewing_papers:
		# Exit paper view
		print("Exiting paper view")
		viewing_papers = false
		Global.tab_papers = false
		hide_all_papers()
	else:
		# Enter paper view - check which papers are available
		print("Entering paper view - checking available papers")
		update_available_papers()
		
		if available_papers.size() > 0:
			print("Available papers: ", available_papers.size())
			viewing_papers = true
			Global.tab_papers = true
			current_paper_index = 0
			show_current_paper()
		else:
			print("No papers available to view!")

func update_available_papers():
	available_papers = []
	
	print("Checking Global paper status:")
	print("  paper1_up: ", Global.paper1_up)
	print("  paper2_up: ", Global.paper2_up)
	print("  paper3_up: ", Global.paper3_up)
	print("  paper4_up: ", Global.paper4_up)
	print("  paper5_up: ", Global.paper5_up)
	
	# Check global variables for collected papers
	if papers.size() > 0 and Global.paper1_up:
		available_papers.append(0)
		print("Added Paper1 to available papers")
	if papers.size() > 1 and Global.paper2_up:
		available_papers.append(1)
		print("Added Paper2 to available papers")
	if papers.size() > 2 and Global.paper3_up:
		available_papers.append(2)
		print("Added Paper3 to available papers")
	if papers.size() > 3 and Global.paper4_up:
		available_papers.append(3)
		print("Added Paper4 to available papers")
	if papers.size() > 4 and Global.paper5_up:
		available_papers.append(4)
		print("Added Paper5 to available papers")
	
	print("Total available papers: ", available_papers)

func show_current_paper():
	hide_all_papers()
	if available_papers.size() > 0:
		var paper_index = available_papers[current_paper_index]
		if paper_index < papers.size():
			papers[paper_index].visible = true
			print("Showing Paper", paper_index + 1, " (index ", current_paper_index, " of ", available_papers.size(), ")")

func hide_all_papers():
	print("Hiding all papers")
	for i in range(papers.size()):
		if papers[i]:
			papers[i].visible = false

func next_paper():
	if available_papers.size() > 0:
		current_paper_index = (current_paper_index + 1) % available_papers.size()
		print("Moving to next paper, index: ", current_paper_index)
		show_current_paper()

func previous_paper():
	if available_papers.size() > 0:
		current_paper_index = (current_paper_index - 1) % available_papers.size()
		if current_paper_index < 0:
			current_paper_index = available_papers.size() - 1
		print("Moving to previous paper, index: ", current_paper_index)
		show_current_paper()

func player_movement(_delta):
	# Reset velocity
	velocity = Vector2.ZERO
	
	# Check all directions independently (not elif)
	# Check for movement restrictions (set by facility_entrance when pushing)
	var right_pressed = Input.is_action_pressed("ui_right")
	var left_pressed = Input.is_action_pressed("ui_left")
	var down_pressed = Input.is_action_pressed("ui_down")
	var up_pressed = Input.is_action_pressed("ui_up")
	
	# Check horizontal restrictions
	if right_pressed and not restricted_directions.get("right", false):
		velocity.x = speed
	if left_pressed and not restricted_directions.get("left", false):
		velocity.x = -speed
	
	# Check vertical restrictions - allow if diagonal, block if pure vertical
	var is_diagonal = (right_pressed or left_pressed) and (up_pressed or down_pressed)
	
	if down_pressed:
		# Allow down if it's diagonal OR if pure down is not blocked
		if is_diagonal or not restricted_directions.get("down_only", false):
			if not restricted_directions.get("down", false):
				velocity.y = speed
	
	if up_pressed:
		# Allow up if it's diagonal OR if pure up is not blocked
		if is_diagonal or not restricted_directions.get("up_only", false):
			if not restricted_directions.get("up", false):
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
			

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var actionable = actionable_finder.get_overlapping_areas()
		if actionable.size() > 0:
			actionable[0].action()
			return

extends CharacterBody2D

const speed = 50  # Same speed as player for consistency
const horizontal_speed = 140  # Speed for constant left movement
const REWIND_TIME = 5.0  # Seconds to rewind
const REWIND_DURATION = 5.0  # How long the rewind animation takes
const REWIND_DELAY = 1.0  # Seconds to wait before starting rewind
const MAP_TOP = -200  # Top boundary of the map
const MAP_BOTTOM = 230  # Bottom boundary of the map
var is_stopped = false  # Track if car has stopped due to collision
var is_rewinding = false  # Track if car is currently rewinding
var is_waiting_for_rewind = false  # Track if waiting before rewind starts
var is_playing_crash_r = false  # Track if playing crash_r animation before rewind
var crash_time = 0.0  # When the crash happened
var crash_r_start_time = 0.0  # When crash_r animation started
var position_history = []  # Array to store position history: [{time: float, position: Vector2}]
var current_time = 0.0  # Track elapsed time
var rewind_start_time = 0.0  # When rewind started
var rewind_start_position = Vector2.ZERO  # Position when rewind started
var rewind_target_position = Vector2.ZERO  # Position to rewind to
var rewind_history = []  # Positions to animate through during rewind
var crt_effect_node: Node = null  # Reference to CRT effect node (CanvasLayer)
var music_player: AudioStreamPlayer = null  # Main music player
var reverse_music_player: AudioStreamPlayer = null  # Reverse music player

const MAIN_MUSIC_PATH = "res://assets/Music_final/Music_final/car_play.mp3"
const REVERSE_MUSIC_PATH = "res://assets/Music_final/Music_final/car_play_reverse.mp3"

func _ready():
	# Find the CRT effect node in the scene tree
	find_crt_effect()
	# Connect animation finished signal
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	# Setup audio players
	setup_audio()

func find_crt_effect():
	# Look for CanvasLayer node in the scene tree
	# First try: search from parent up
	var parent = get_parent()
	while parent != null:
		# Look for CanvasLayer
		var canvas_layer = parent.find_child("CanvasLayer", true, false)
		if canvas_layer != null:
			crt_effect_node = canvas_layer
			print("CRT effect node (CanvasLayer) found: ", crt_effect_node.get_path())
			return
		
		parent = parent.get_parent()
	
	# Second try: search from scene root
	var scene_root = get_tree().root
	var canvas_layer = scene_root.find_child("CanvasLayer", true, false)
	if canvas_layer != null:
		crt_effect_node = canvas_layer
		print("CRT effect node (CanvasLayer) found (from root): ", crt_effect_node.get_path())
		return
	
	print("CRT effect node (CanvasLayer) not found!")

func _physics_process(_delta):
	current_time += _delta
	
	if is_rewinding:
		handle_rewind(_delta)
	elif is_playing_crash_r:
		handle_crash_r_animation(_delta)
	elif is_waiting_for_rewind:
		handle_rewind_delay(_delta)
	else:
		car_movement(_delta)

func car_movement(_delta):
	# If stopped due to collision, don't move
	if is_stopped:
		velocity = Vector2.ZERO
		$AnimatedSprite2D.stop()  # Stop animation when car stops
		move_and_slide()
		return
	
	# Store current position in history before moving
	store_position()
	
	# Set constant right movement (forward in side-scroller)
	velocity.x = horizontal_speed
	
	# Reset vertical velocity, then check for up/down input
	velocity.y = 0
	
	# Only allow player input if not rewinding
	if not is_rewinding:
		# Check for vertical movement input (mimicking player controller)
		if Input.is_action_pressed("ui_down"):
			velocity.y = speed
		if Input.is_action_pressed("ui_up"):
			velocity.y = -speed
	
	# Play the move animation since the car is always moving
	$AnimatedSprite2D.play("move")
	
	# Apply movement
	move_and_slide()
	
	# Clamp position to map boundaries
	global_position.y = clamp(global_position.y, MAP_TOP, MAP_BOTTOM)
	
	# Check for collisions - if we hit something, start waiting for rewind
	if get_slide_collision_count() > 0:
		on_crash()

func store_position():
	# Store current position with timestamp
	position_history.append({
		"time": current_time,
		"position": global_position
	})
	
	# Remove positions older than REWIND_TIME to keep array size manageable
	var cutoff_time = current_time - REWIND_TIME
	position_history = position_history.filter(func(entry): return entry.time >= cutoff_time)

func on_crash():
	# Stop the car and start waiting for rewind
	is_stopped = true
	is_waiting_for_rewind = true
	crash_time = current_time
	velocity = Vector2.ZERO
	# Play crash animation and keep it looping during delay
	$AnimatedSprite2D.play("crash")
	# Switch to reverse music when crash happens
	switch_to_reverse_music()

func handle_rewind_delay(_delta):
	# Wait 1 second before starting rewind
	# Keep crash animation playing during delay
	if $AnimatedSprite2D.animation != "crash":
		$AnimatedSprite2D.play("crash")
	
	var elapsed = current_time - crash_time
	if elapsed >= REWIND_DELAY:
		# Delay complete, start crash_r animation
		is_waiting_for_rewind = false
		start_crash_r_animation()
	else:
		# Still waiting, keep car stopped
		velocity = Vector2.ZERO
		move_and_slide()

func start_crash_r_animation():
	# Play crash_r animation and enable CRT effect
	is_playing_crash_r = true
	crash_r_start_time = current_time
	$AnimatedSprite2D.play("crash_r")
	# Enable CRT effect when crash_r starts
	enable_crt_effect()

func handle_crash_r_animation(_delta):
	# Wait for crash_r animation to finish
	if not $AnimatedSprite2D.is_playing() or $AnimatedSprite2D.animation != "crash_r":
		# Animation finished, start rewind movement
		is_playing_crash_r = false
		start_rewind()
	else:
		# Still playing, keep car stopped
		velocity = Vector2.ZERO
		move_and_slide()

func start_rewind():
	# Check if we have any history at all
	if position_history.size() < 2:
		# No history, just stop
		is_stopped = true
		velocity = Vector2.ZERO
		$AnimatedSprite2D.stop()
		return
	
	# Calculate target time (5 seconds ago, or as far back as we have)
	var target_time = current_time - REWIND_TIME
	var oldest_time = position_history[0].time
	
	# Use the oldest available time if we don't have 5 seconds yet
	if oldest_time > target_time:
		target_time = oldest_time
	
	var rewind_target = null
	
	# Find the closest position to target time
	for i in range(position_history.size() - 1, -1, -1):
		if position_history[i].time <= target_time:
			rewind_target = position_history[i]
			break
	
	# If we found a rewind target (should always happen if we have history)
	if rewind_target != null:
		# Start rewind animation immediately
		is_rewinding = true
		is_stopped = false
		rewind_start_time = current_time
		rewind_start_position = global_position
		rewind_target_position = rewind_target.position
		
		# Build rewind path - get all positions from target to current
		rewind_history = []
		for entry in position_history:
			if entry.time >= target_time and entry.time <= current_time:
				rewind_history.append(entry.position)
		
		# Reverse the history so we go backwards
		rewind_history.reverse()
		
		# Stop normal movement
		velocity = Vector2.ZERO
	else:
		# Fallback: rewind to oldest position
		rewind_target_position = position_history[0].position
		is_rewinding = true
		is_stopped = false
		rewind_start_time = current_time
		rewind_start_position = global_position
		rewind_history = []
		for entry in position_history:
			rewind_history.append(entry.position)
		rewind_history.reverse()
		velocity = Vector2.ZERO

func handle_rewind(_delta):
	# Calculate progress through rewind (0 to 1)
	var elapsed = current_time - rewind_start_time
	var progress = elapsed / REWIND_DURATION
	
	if progress >= 1.0:
		# Rewind complete
		finish_rewind()
		return
	
	# Interpolate through rewind history
	if rewind_history.size() > 0:
		var index = int(progress * (rewind_history.size() - 1))
		index = clamp(index, 0, rewind_history.size() - 1)
		
		# Smooth interpolation between positions
		var next_index = min(index + 1, rewind_history.size() - 1)
		var local_progress = (progress * (rewind_history.size() - 1)) - index
		
		if index < rewind_history.size() - 1:
			global_position = rewind_history[index].lerp(rewind_history[next_index], local_progress)
		else:
			global_position = rewind_history[index]
	
	# Clamp position to map boundaries during rewind
	global_position.y = clamp(global_position.y, MAP_TOP, MAP_BOTTOM)
	
	# Keep velocity zero during rewind
	velocity = Vector2.ZERO
	move_and_slide()

func finish_rewind():
	# Complete the rewind
	is_rewinding = false
	global_position = rewind_target_position
	
	# Clamp position to map boundaries after rewind
	global_position.y = clamp(global_position.y, MAP_TOP, MAP_BOTTOM)
	
	# Find the time we rewound to
	var target_time = current_time - REWIND_TIME
	var oldest_time = position_history[0].time if position_history.size() > 0 else current_time
	
	# Use the oldest available time if we don't have 5 seconds yet
	if oldest_time > target_time:
		target_time = oldest_time
	
	# Clear position history from after the rewind point
	position_history = position_history.filter(func(entry): return entry.time <= target_time)
	
	# Reset time to match the rewind point
	current_time = target_time
	
	# Clear rewind data
	rewind_history.clear()
	
	# Resume normal movement
	is_stopped = false
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("move")
	
	# Disable CRT effect
	disable_crt_effect()
	
	# Switch back to normal music when rewind ends
	switch_to_main_music()

func _on_animation_finished():
	# Handle animation finished signal
	if is_playing_crash_r and $AnimatedSprite2D.animation == "crash_r":
		# crash_r finished, start rewind
		is_playing_crash_r = false
		start_rewind()

func enable_crt_effect():
	if crt_effect_node != null:
		crt_effect_node.visible = true
		print("CRT effect enabled")
	else:
		# Try to find it again if we haven't found it yet
		find_crt_effect()
		if crt_effect_node != null:
			crt_effect_node.visible = true
			print("CRT effect enabled (found on retry)")
		else:
			print("CRT effect node still not found!")

func disable_crt_effect():
	if crt_effect_node != null:
		crt_effect_node.visible = false
		print("CRT effect disabled")

func setup_audio():
	# Create main music player
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	var main_music = load(MAIN_MUSIC_PATH)
	if main_music:
		music_player.stream = main_music
		music_player.volume_db = 0.0
		music_player.play()
		print("Main music started")
	else:
		print("ERROR: Could not load main music: ", MAIN_MUSIC_PATH)
	
	# Create reverse music player
	reverse_music_player = AudioStreamPlayer.new()
	add_child(reverse_music_player)
	var reverse_music = load(REVERSE_MUSIC_PATH)
	if reverse_music:
		reverse_music_player.stream = reverse_music
		reverse_music_player.volume_db = 0.0
		print("Reverse music loaded")
	else:
		print("ERROR: Could not load reverse music: ", REVERSE_MUSIC_PATH)

func switch_to_reverse_music():
	# Stop main music and play reverse music
	if music_player and music_player.playing:
		music_player.stop()
	if reverse_music_player:
		reverse_music_player.play()
		print("Switched to reverse music")

func switch_to_main_music():
	# Stop reverse music and play main music
	if reverse_music_player and reverse_music_player.playing:
		reverse_music_player.stop()
	if music_player:
		music_player.play()
		print("Switched back to main music")

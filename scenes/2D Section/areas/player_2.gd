extends Player
var travel_sfx_player: AudioStreamPlayer
@export var travel_sfx: AudioStream

# Mountain scene boundaries (matching Camera2D limits)
const MAP_LEFT = -272
const MAP_RIGHT = 464
const MAP_TOP = -150
const MAP_BOTTOM = 160

func _ready() -> void:
	
	super._ready()
	travel_sfx_player = AudioStreamPlayer.new()
	add_child(travel_sfx_player)
	
func _play_travel_sfx():
	print( travel_sfx)
	if travel_sfx_player and travel_sfx:
		travel_sfx_player.stream = travel_sfx
		
		travel_sfx_player.play()
		print("sound travel played")

func _physics_process(_delta):
	# Call parent's physics process
	super._physics_process(_delta)
	
	# Clamp position to camera limits
	global_position.x = clamp(global_position.x, MAP_LEFT, MAP_RIGHT)
	global_position.y = clamp(global_position.y, MAP_TOP, MAP_BOTTOM)

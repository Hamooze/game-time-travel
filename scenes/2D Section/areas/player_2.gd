extends Player
var travel_sfx_player: AudioStreamPlayer
@export var travel_sfx: AudioStream

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

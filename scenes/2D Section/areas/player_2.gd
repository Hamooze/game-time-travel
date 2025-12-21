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
func _input(event):
	if event.is_action_pressed("travel"):
		_play_travel_sfx()
		await get_tree().create_timer(0.15).timeout
		get_tree().change_scene_to_file("res://scenes/2D Section/areas/mountain_past.tscn")

extends AudioStreamPlayer

## Script to handle BegTheme music with offset
## Set the offset_time property in the scene to start music at a specific time

@export var offset_time: float = 0.0  # Offset in seconds

func _ready() -> void:
	# Disable autoplay temporarily to handle offset manually
	var was_autoplay = autoplay
	autoplay = false
	
	# Wait a frame to ensure the stream is loaded
	await get_tree().process_frame
	
	# Start playing and seek to offset
	if was_autoplay or offset_time > 0.0:
		play()
		# Wait a tiny bit for playback to start, then seek
		await get_tree().create_timer(0.01).timeout
		if offset_time > 0.0:
			seek(offset_time)
		print("BegTheme started at offset: ", offset_time, " seconds")


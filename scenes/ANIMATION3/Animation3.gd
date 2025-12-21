extends Node2D

@export_file("*.tscn") var next_scene_path := ""
@export_file("*.mp3", "*.ogg", "*.wav") var audio_path := "res://assets/ANIMATON3/AUDIO/FINALPUBLISH.mp3"
@export_dir var frames_dir := "res://assets/ANIMATON3/FRAMES"
@export var animation_duration_seconds: float = 0.0
@export var allow_skip: bool = true

@onready var anim: AnimatedSprite2D = $Background/SpriteA
@onready var audio_player: AudioStreamPlayer = $AudioPlayer
@onready var _viewport := get_viewport()

var _is_transitioning := false


func _ready() -> void:
	_viewport.size_changed.connect(_on_viewport_resized)
	await _play_animation()


func _play_animation() -> void:
	var frames := _load_frames(frames_dir)
	if frames == null:
		push_warning("Animation3: no frames could be loaded from %s" % frames_dir)
		return

	var frame_count := frames.get_frame_count("default")
	if frame_count == 0:
		push_warning("Animation3: loaded frames contain no images")
		return

	var duration: float = max(animation_duration_seconds, 0.0)
	var stream: AudioStream = _load_audio(audio_path)
	if stream:
		audio_player.stream = stream
		var audio_length: float = _get_audio_length(stream)
		if audio_length > 0.0:
			duration = max(duration, audio_length)
		audio_player.play()

	if duration <= 0.0:
		# Fallback to ~24fps if no duration info is available
		duration = frame_count / 24.0

	var fps: float = frame_count / max(duration, 0.1)
	frames.set_animation_speed("default", fps)
	anim.sprite_frames = frames
	anim.play("default")
	_rescale_background()

	await get_tree().create_timer(duration).timeout
	if _is_transitioning:
		return

	if stream and audio_player.playing:
		await audio_player.finished
		if _is_transitioning:
			return

	_go_next_scene()


func _load_frames(frames_dir: String) -> SpriteFrames:
	if frames_dir.is_empty():
		return null
	var dir := DirAccess.open(frames_dir)
	if dir == null:
		push_warning("Animation3: cannot open frames_dir: %s" % frames_dir)
		return null

	var files: Array[String] = []
	dir.list_dir_begin()
	var file := dir.get_next()
	while file != "":
		if not dir.current_is_dir():
			var lower := file.to_lower()
			if lower.ends_with(".png") or lower.ends_with(".webp") or lower.ends_with(".jpg") or lower.ends_with(".jpeg") or lower.ends_with(".gif"):
				files.append(file)
		file = dir.get_next()
	dir.list_dir_end()
	files.sort()

	if files.is_empty():
		push_warning("Animation3: no frame images found in %s" % frames_dir)
		return null

	var sf := SpriteFrames.new()
	if sf.has_animation("default"):
		sf.remove_animation("default")
	sf.add_animation("default")
	sf.set_animation_loop("default", false)
	for f in files:
		var tex := _load_texture(frames_dir.path_join(f))
		if tex:
			sf.add_frame("default", tex)
	return sf


func _load_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	var res := ResourceLoader.load(path)
	if res is Texture2D:
		return res
	push_warning("Animation3: failed to load texture as Texture2D: %s" % path)
	return null


func _load_audio(path: String) -> AudioStream:
	if path.is_empty():
		return null
	var res := ResourceLoader.load(path)
	if res is AudioStream:
		return res
	push_warning("Animation3: failed to load audio stream: %s" % path)
	return null


func _get_audio_length(stream: AudioStream) -> float:
	if stream == null:
		return 0.0
	if stream.has_method("get_length"):
		return stream.get_length()
	return 0.0


func _go_next_scene() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	audio_player.stop()
	if next_scene_path.is_empty():
		return
	get_tree().change_scene_to_file(next_scene_path)


func _rescale_background() -> void:
	if anim.sprite_frames == null or not anim.sprite_frames.has_animation("default"):
		return
	var tex := anim.sprite_frames.get_frame_texture("default", 0)
	if tex == null:
		return
	var vp_size := get_viewport_rect().size
	var tex_size := tex.get_size()
	if tex_size.x == 0 or tex_size.y == 0:
		return
	var scale_factor: float = max(vp_size.x / tex_size.x, vp_size.y / tex_size.y)
	anim.scale = Vector2.ONE * scale_factor


func _on_viewport_resized() -> void:
	_rescale_background()


func _unhandled_input(event: InputEvent) -> void:
	if not allow_skip:
		return
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
		_go_next_scene()

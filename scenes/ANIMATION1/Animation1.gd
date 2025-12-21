extends Node2D

@export_file("*.tscn") var next_scene_path := "res://scenes/areas/dream_sequence.tscn"
@export_file("*.mp3", "*.ogg", "*.wav") var audio_path := "res://assets/ANIMATION1/AUDIO/PART1audio.mp3"
@export_dir var part1_frames_dir := "res://assets/ANIMATION1/ezgif-8f47caec16f755ba-jpg"
@export var part1_target_seconds: float = 28.0
@export_dir var part2_frames_dir := ""
@export var part2_target_seconds: float = 0.0
@export var allow_skip: bool = true

@onready var anim: AnimatedSprite2D = $Background/SpriteA
@onready var audio_player: AudioStreamPlayer = $AudioPlayer
@onready var _viewport := get_viewport()

var _is_transitioning := false


func _ready() -> void:
	_viewport.size_changed.connect(_on_viewport_resized)
	await _play_animation_chain()


func _play_animation_chain() -> void:
	var stream := _load_audio(audio_path)
	var audio_length := _get_audio_length(stream)
	if stream:
		audio_player.stream = stream
		audio_player.play()

	var sections := _build_sections(audio_length)
	for section in sections:
		if not _play_section(section):
			continue
		await get_tree().create_timer(section.duration).timeout
		if _is_transitioning:
			return

	if stream and audio_player.playing:
		await audio_player.finished

	_go_next_scene()


func _build_sections(audio_length: float) -> Array:
	var sections: Array = []

	if part2_frames_dir.is_empty():
		var only_duration := part1_target_seconds
		if audio_length > 0.0:
			only_duration = audio_length
		elif only_duration <= 0.0:
			only_duration = 28.0
		sections.append(_make_section("part1", part1_frames_dir, only_duration))
		return sections

	var duration1 := part1_target_seconds
	var duration2 := part2_target_seconds
	if audio_length > 0.0:
		if duration1 > 0.0 and duration2 <= 0.0:
			duration2 = max(audio_length - duration1, 0.1)
		elif duration2 > 0.0 and duration1 <= 0.0:
			duration1 = max(audio_length - duration2, 0.1)
		elif duration1 <= 0.0 and duration2 <= 0.0:
			duration1 = audio_length * 0.5
			duration2 = audio_length - duration1

	if duration1 <= 0.0:
		duration1 = 10.0
	if duration2 <= 0.0:
		duration2 = 10.0

	sections.append(_make_section("part1", part1_frames_dir, duration1))
	sections.append(_make_section("part2", part2_frames_dir, duration2))
	return sections


func _make_section(name: String, frames_dir: String, duration: float) -> Dictionary:
	var frames := _load_frames(frames_dir)
	if frames == null:
		push_warning("%s: no frames loaded from %s" % [name, frames_dir])
	return {
		"name": name,
		"frames_dir": frames_dir,
		"duration": max(duration, 0.1),
		"frames": frames,
	}


func _play_section(section: Dictionary) -> bool:
	var frames: SpriteFrames = section.get("frames")
	if frames == null:
		return false
	var duration: float = max(section.get("duration", 0.1), 0.1)
	var frame_count := frames.get_frame_count("default")
	if frame_count == 0:
		return false
	var fps := frame_count / duration
	frames.set_animation_speed("default", fps)
	anim.sprite_frames = frames
	anim.play("default")
	_rescale_background()
	return true


func _load_frames(frames_dir: String) -> SpriteFrames:
	if frames_dir.is_empty():
		return null
	var dir := DirAccess.open(frames_dir)
	if dir == null:
		push_warning("Cannot open frames_dir: %s" % frames_dir)
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
		push_warning("No frame images found in %s" % frames_dir)
		return null

	var sf := SpriteFrames.new()
	# Ensure a clean animation set - check if default already exists
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
	var res := ResourceLoader.load(path)
	if res is Texture2D:
		return res
	push_warning("Failed to load texture as Texture2D: %s" % path)
	return null


func _load_audio(path: String) -> AudioStream:
	if path.is_empty():
		return null
	var res := ResourceLoader.load(path)
	if res is AudioStream:
		return res
	push_warning("Failed to load audio stream: %s" % path)
	return null


func _get_audio_length(stream: AudioStream) -> float:
	if stream == null:
		return 0.0
	if stream.has_method("get_length"):
		return stream.get_length()
	return 0.0


func _go_next_scene() -> void:
	if _is_transitioning or next_scene_path.is_empty():
		return
	_is_transitioning = true
	audio_player.stop()
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

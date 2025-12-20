extends Node2D

@export_file("*.tscn") var next_scene_path := "res://scenes/ANIMATION1/Animation1.tscn"
@export_dir var frames_dir := "res://assets/MAINMENU/Frames"
@export var animation_fps: float = 12.0
@export var wait_time_seconds: float = 7.0

@onready var anim: AnimatedSprite2D = $Background/SpriteA
@onready var _viewport := get_viewport()

var _frame_count := 0

func _ready() -> void:
	_setup_animation()
	_rescale_background()
	_viewport.size_changed.connect(_on_viewport_resized)
	_start_timer()

func _start_timer() -> void:
	if wait_time_seconds <= 0.0:
		_go_next_scene()
		return
	await get_tree().create_timer(wait_time_seconds).timeout
	_go_next_scene()

func _go_next_scene() -> void:
	if next_scene_path.is_empty():
		return
	get_tree().change_scene_to_file(next_scene_path)

func _setup_animation() -> void:
	var frames := _load_frames()
	if frames == null or not frames.has_animation("default"):
		push_warning("LoadingScreen: no frames loaded from %s" % frames_dir)
		return
	frames.set_animation_speed("default", animation_fps)
	anim.sprite_frames = frames
	anim.play("default")
	_frame_count = frames.get_frame_count("default")
	print("LoadingScreen: loaded frames: %d from %s" % [_frame_count, frames_dir])
	_rescale_background()

func _load_frames() -> SpriteFrames:
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
	files.sort() # lexicographic; works with numbered names
	if files.is_empty():
		push_warning("No frame images found in %s" % frames_dir)
		return null
	var sf := SpriteFrames.new()
	# Ensure a clean animation set
	if sf.has_animation("default"):
		sf.remove_animation("default")
	sf.add_animation("default")
	sf.set_animation_loop("default", true)
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


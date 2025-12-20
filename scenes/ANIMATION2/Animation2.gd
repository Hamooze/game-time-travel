extends Node2D

@export_file("*.tscn") var next_scene_path := "res://scenes/MainScreen/MainMenu.tscn"
@export_file("*.mp3", "*.ogg", "*.wav") var audio_path := ""
# Defaults now point to your uploaded frames.
@export_file("*.png", "*.jpg", "*.jpeg", "*.webp", "*.gif") var panel1_path := "res://assets/ANIMATION2/PICS/Scene1.jpg"
@export_file("*.png", "*.jpg", "*.jpeg", "*.webp", "*.gif") var panel2_path := "res://assets/ANIMATION2/PICS/Scene2.jpg"
@export var panel_duration_seconds: float = 5.0
@export var allow_skip: bool = true

@onready var sprite: Sprite2D = $Background/SpriteA
@onready var audio_player: AudioStreamPlayer = $AudioPlayer
@onready var _viewport := get_viewport()

var _is_transitioning := false


func _ready() -> void:
	_viewport.size_changed.connect(_on_viewport_resized)
	await _play_sequence()


func _play_sequence() -> void:
	var textures := _load_textures()
	var stream := _load_audio(audio_path)
	if stream:
		audio_player.stream = stream
		audio_player.play()

	if textures.is_empty():
		push_warning("Animation2: no panels could be loaded")
		_go_next_scene()
		return

	for tex in textures:
		sprite.texture = tex
		_rescale_background()
		await get_tree().create_timer(max(panel_duration_seconds, 0.1)).timeout
		if _is_transitioning:
			return

	if stream and audio_player.playing:
		await audio_player.finished

	_go_next_scene()


func _load_textures() -> Array[Texture2D]:
	var textures: Array[Texture2D] = []
	var fallbacks := [
		{"path": panel1_path, "color": Color(0.16, 0.35, 0.85), "label": "Panel 1 placeholder"},
		{"path": panel2_path, "color": Color(0.85, 0.32, 0.18), "label": "Panel 2 placeholder"},
	]
	for fb in fallbacks:
		var path: String = fb.get("path", "")
		var tex := _load_texture(path)
		if tex:
			textures.append(tex)
			continue
		if not path.is_empty():
			push_warning("Animation2: failed to load panel at %s" % path)
		# Fallback to a simple colored card so the cutscene is never blank
		var placeholder := _make_placeholder(fb.get("color", Color.DARK_GRAY))
		textures.append(placeholder)
	return textures


func _load_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if not FileAccess.file_exists(path):
		return null
	var res := ResourceLoader.load(path)
	if res is Texture2D:
		return res
	return null


func _make_placeholder(color: Color) -> Texture2D:
	var img := Image.create(640, 360, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)


func _load_audio(path: String) -> AudioStream:
	if path.is_empty():
		return null
	var res := ResourceLoader.load(path)
	if res is AudioStream:
		return res
	push_warning("Animation2: failed to load audio stream: %s" % path)
	return null


func _go_next_scene() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	audio_player.stop()
	if next_scene_path.is_empty():
		return
	get_tree().change_scene_to_file(next_scene_path)


func _rescale_background() -> void:
	if sprite.texture == null:
		return
	var vp_size := get_viewport_rect().size
	var tex_size := sprite.texture.get_size()
	if tex_size.x == 0 or tex_size.y == 0:
		return
	var scale_factor: float = max(vp_size.x / tex_size.x, vp_size.y / tex_size.y)
	sprite.scale = Vector2.ONE * scale_factor


func _on_viewport_resized() -> void:
	_rescale_background()


func _unhandled_input(event: InputEvent) -> void:
	if not allow_skip:
		return
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
		_go_next_scene()

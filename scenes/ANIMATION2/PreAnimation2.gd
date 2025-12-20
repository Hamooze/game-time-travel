extends Node2D

@export_file("*.tscn") var next_scene_path := "res://scenes/ANIMATION2/Animation2.tscn"
@export var fade_duration: float = 0.6
@export var hold_duration: float = 0.2
@export var allow_skip: bool = true

@onready var _fade_rect: ColorRect = $FadeRect
var _is_transitioning := false


func _ready() -> void:
	if _fade_rect:
		_fade_rect.visible = true
		_fade_rect.modulate.a = 0.0
		_start_transition()
	else:
		_go_next_scene()


func _start_transition() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	var tw := create_tween()
	tw.tween_property(_fade_rect, "modulate:a", 1.0, max(fade_duration, 0.05))
	await tw.finished
	if hold_duration > 0.0:
		await get_tree().create_timer(hold_duration).timeout
	_go_next_scene()


func _go_next_scene() -> void:
	if next_scene_path.is_empty():
		return
	get_tree().change_scene_to_file(next_scene_path)


func _unhandled_input(event: InputEvent) -> void:
	if not allow_skip:
		return
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
		_go_next_scene()


extends Node2D

@onready var paper5:Sprite2D = $paper5 
@onready var paper4:Sprite2D = $paper4
@onready var paper3:Sprite2D = $paper3

func _process(delta: float) -> void:
	if Global.paper5_up:
		if paper5.visible == true:
			paper5.visible = false
	if Global.paper4_up:
		if paper4.visible == true:
			paper4.visible = false
	if Global.paper3_up:
		if paper3.visible == true:
			paper3.visible = false
			
	if Global.transition == true:
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/ANIMATION3/Animation3.tscn")

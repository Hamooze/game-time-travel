extends Node

var paper1_up = false
var paper2_up = false
var paper3_up = false
var paper4_up = false
var paper5_up = false

var tab_papers = false

var has_bp = false

var in_dialogue = false
var has_plant: bool = false
var plant_collected: bool = false
var plant_planted_position: Vector2 = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

var has_box: bool = false
var collected_objects: Dictionary = {}
var placed_boxes: Array = []
var door_jammed_in_past: bool = false
signal door_state_changed(jammed: bool)  # Signal emitted when door state changes

extends Node

var paper1_up = false
var paper2_up = false
var paper3_up = false
var paper4_up = false
var paper5_up = false

var tab_papers = false

var in_dialogue = false
var has_plant: bool = false
var plant_collected: bool = false
var plant_planted_position: Vector2 = Vector2.ZERO
var has_box: bool = false

# Track collected objects by unique ID (scene_name:object_id)
# Format: "facility_entrance:box_121_197" -> true means collected
var collected_objects: Dictionary = {}

# Track placed boxes across time periods
# Format: Array of dictionaries with {scene_name, position, collectable_id}
var placed_boxes: Array = []

# Track if door should be open in present (facility_entrance) based on box placement in past
var door_jammed_in_past: bool = false

signal door_state_changed(jammed: bool)  # Signal emitted when door state changes

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	

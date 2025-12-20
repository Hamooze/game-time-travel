extends StaticBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var interactable_component: InteractableComponent = $InteractableComponent

var is_player_in_range := false
var is_open := false

func _ready() -> void:
	interactable_component.interactable_activated.connect(on_interactable_activated)
	interactable_component.interactable_deactivated.connect(on_interactable_deactivated)
	animated_sprite_2d.play("default")

func on_interactable_activated() -> void:
	is_player_in_range = true

func on_interactable_deactivated() -> void:
	is_player_in_range = false
	if is_open:
		animated_sprite_2d.play("close")
		is_open = false
		print("close")

func _process(delta: float) -> void:
	if is_player_in_range and Input.is_action_just_pressed("interact") and not is_open:
		animated_sprite_2d.play("open")
		is_open = true
		print("open")

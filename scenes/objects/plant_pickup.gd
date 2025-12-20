class_name PlantPickup
extends Sprite2D

# When false, the plant becomes "decorative" (e.g. after planting) and won't be collectible.
@export var pickup_enabled: bool = true

@onready var interactable_component: InteractableComponent = $InteractableComponent

func _ready() -> void:
	if interactable_component:
		interactable_component.interacted.connect(_on_interacted)
	else:
		push_warning("PlantPickup: missing InteractableComponent child.")

func set_pickup_enabled(value: bool) -> void:
	pickup_enabled = value
	if interactable_component:
		# Disable interaction polling when not needed
		interactable_component.set_process(pickup_enabled)

func _on_interacted() -> void:
	if not pickup_enabled:
		return

	Global.has_plant = true
	Global.plant_collected = true
	queue_free()

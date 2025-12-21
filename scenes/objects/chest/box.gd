extends CharacterBody2D

@onready var interactable_component: InteractableComponent = $InteractableComponent

func _ready() -> void:
	interactable_component.interactable_activated.connect(on_interactable_activated)
	interactable_component.interactable_deactivated.connect(on_interactable_deactivated)

func on_interactable_activated() -> void:
	pass

func on_interactable_deactivated() -> void:
	pass

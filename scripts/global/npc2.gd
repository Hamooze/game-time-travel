extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D  # Change to your actual sprite node name


func _process(delta: float) -> void:
	if Global.future == true:
		sprite.visible = true

extends Area2D
#//
@export var teleport_position: Vector2 = Vector2(362, 169)

var player_nearby := false
var player_ref: Player = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if player_nearby and Input.is_action_just_pressed("interact"):
		player_ref.global_position = teleport_position
		print("Climbing tree!")

func _on_body_entered(body: Node) -> void:
	if body is Player:
		player_ref = body
		player_nearby = true
		print("Player near tree")

func _on_body_exited(body: Node) -> void:
	if body == player_ref:
		player_ref = null
		player_nearby = false
		print("Player left tree")

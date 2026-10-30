
extends Area2D

@export var duration: float = 1.5
@export var knockback_strength: float = 350.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("Tornado")
	body_entered.connect(_on_body_entered)

	await get_tree().create_timer(duration).timeout
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body is CharacterBody2D:
		var push_direction: float = sign(
			body.global_position.x - global_position.x
		)

		if push_direction == 0.0:
			push_direction = 1.0

		body.velocity.x = push_direction * knockback_strength


extends Area2D

@export var speed: float = 350.0
@export var lifetime: float = 2.0

var direction: float = 1.0
var damage: int = 0     # set by the player when it's fired

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("FireBall")
	sprite.flip_h = direction < 0.0

	get_tree().create_timer(lifetime).timeout.connect(
		queue_free
	)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(damage)
		queue_free()
	elif body is StaticBody2D:   # hit a tree
		queue_free()

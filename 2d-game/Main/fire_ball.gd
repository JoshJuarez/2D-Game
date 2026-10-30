
extends Area2D

@export var speed: float = 350.0
@export var lifetime: float = 2.0

var direction: float = 1.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("FireBall")
	sprite.flip_h = direction < 0.0

	get_tree().create_timer(lifetime).timeout.connect(
		queue_free
	)

func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta

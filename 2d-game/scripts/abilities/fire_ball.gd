
extends Area2D

@export var speed: float = 350.0
@export var lifetime: float = 2.0

var direction: float = 1.0
const EXPLOSION = preload("res://2d-game/scenes/abilities/explosion.tscn")
var damage: int = 0
var spent = false     # set by the player when it's fired

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("FireBall")
	sprite.flip_h = direction < 0.0

	get_tree().create_timer(lifetime).timeout.connect(
		queue_free
	)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body is StaticBody2D:   # hit a tree
		explode()

func _on_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if area.name == "Hurtbox" and enemy.is_in_group("enemy") and not spent:
		enemy.take_damage(damage)
		explode()

func explode() -> void:
	if spent: return   # only explode once, even if it touches two things at once
	spent = true
	var boom = EXPLOSION.instantiate()
	boom.global_position = global_position
	get_parent().add_child(boom)
	queue_free()

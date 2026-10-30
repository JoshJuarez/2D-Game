extends Area2D

@export var duration: float = 1.5
@export var knockback_strength: float = 420.0

var follow: Node2D   # the Mage; the tornado stays wrapped around her

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("Tornado")
	await get_tree().create_timer(duration).timeout
	queue_free()

func _physics_process(_delta: float) -> void:
	if is_instance_valid(follow):
		global_position = follow.global_position

	# Push every orc whose body is inside the tornado away from its center
	for area in get_overlapping_areas():
		var enemy = area.get_parent()
		if area.name == "Hurtbox" and enemy.is_in_group("enemy"):
			var away = global_position.direction_to(enemy.global_position)
			if away == Vector2.ZERO:
				away = Vector2.RIGHT
			enemy.knockback(away * knockback_strength)

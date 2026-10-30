extends CharacterBody2D

signal died

var health = 30
var speed = 110
var contact_damage = 10
var damage_cooldown = 0.0
var player: Node2D
var recoil_time = 0.0
var action_time = 0.0   # while above 0, an attack or hurt animation is playing
var dead = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if dead or not is_instance_valid(player):
		return

	var direction = global_position.direction_to(player.global_position)
	recoil_time -= delta

	if recoil_time > 0:
		velocity = -direction * speed      # back away from the player
	else:
		velocity = direction * speed       # chase the player
	move_and_slide()
	sprite.flip_h = direction.x < 0

	action_time -= delta
	if action_time <= 0:
		sprite.play("walk")

	damage_cooldown -= delta
	if damage_cooldown <= 0:
		for body in $ContactArea.get_overlapping_bodies():
			if body.is_in_group("player"):
				body.take_damage(contact_damage)
				damage_cooldown = 0.5
				recoil_time = 0.3
				sprite.play("attack")
				action_time = 0.3
				
	

func take_damage(amount: int) -> void:
	if health <= 0: return
	health -= amount
	recoil_time = 0.2
	if health > 0:
		sprite.play("hurt")
		action_time = 0.2
	else:
		die()

func die() -> void:
	dead = true
	if is_instance_valid(player):
		player.enemy_defeated()
	died.emit()
	# Stop being hittable or solid while the death animation plays
	remove_from_group("enemy")
	$CollisionShape2D.set_deferred("disabled", true)
	$ContactArea/CollisionShape2D.set_deferred("disabled", true)
	sprite.play("death")
	await sprite.animation_finished
	queue_free()

extends CharacterBody2D

signal died

var health = 30
var speed = 110
var contact_damage = 10
var damage_cooldown = 0.0
var player: Node2D
var recoil_time = 0.0

func _ready() -> void:
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	var direction = global_position.direction_to(player.global_position)
	recoil_time -= delta

	if recoil_time > 0:
		velocity = -direction * speed      # back away from the player
	else:
		velocity = direction * speed       # chase the player
	move_and_slide()
	$Sprite2D.flip_h = direction.x < 0

	damage_cooldown -= delta
	if damage_cooldown <= 0:
		for body in $ContactArea.get_overlapping_bodies():
			if body.is_in_group("player"):
				body.take_damage(contact_damage)
				damage_cooldown = 0.5
				recoil_time = 0.3
				
	

func take_damage(amount: int) -> void:
	if health <= 0: return
	health -= amount
	recoil_time = 0.2
	if(health <= 0):
		player.enemy_defeated() 
		died.emit()
		queue_free()

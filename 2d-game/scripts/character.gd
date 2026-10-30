extends CharacterBody2D

var health = 0
var time_since_hit = 0.0 
var attack_cooldown = 0.0
var invincible_time = 0.0

func _ready() -> void:
	add_to_group("player")
	health = GameState.max_hp
	get_node("../CanvasLayer/XP bar").value = GameState.xp
	GameState.upgraded.connect(_on_upgraded)
	

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * GameState.speed
	move_and_slide()
	
	attack_cooldown -= delta
	invincible_time -= delta

	if direction.x != 0:
		$Character_Sprite2D.flip_h = direction.x < 0
		$AttackHitbox.scale.x = -1 if direction.x < 0 else 1

	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0:
		attack()
	
	time_since_hit += delta 
	if time_since_hit >= 20.0 and health > 0:
		health = min(health + 5.0 * delta, GameState.max_hp)
		
	get_node("../CanvasLayer/HP bar").value = health
	get_node("../CanvasLayer/HP bar").max_value = GameState.max_hp
	get_node("../CanvasLayer/health label").text = str(int(health)) + " / " + str(GameState.max_hp)
	get_node("../CanvasLayer/XP bar").value = GameState.xp
	get_node("../CanvasLayer/XP bar").max_value = GameState.xp_to_next_level()
	get_node("../CanvasLayer/Label").text = "Level " + str(GameState.level)
	#get_node("../CanvasLayer/wave label").text = "Wave " + str(GameState.wave) + " / 5"
	
func take_damage(amount: int) -> void:
	if invincible_time > 0:
		return

	health = max(health - amount, 0.0)
	time_since_hit = 0.0
	invincible_time = 0.5

	if health <= 0:
		print("Player died")
		queue_free()
	
func enemy_defeated() -> void:
	if health > 0:
		health = min(health + 5.0, GameState.max_hp)
		GameState.add_xp(1)
		
func attack() -> void:
	attack_cooldown = 0.4
	for body in $AttackHitbox.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			body.take_damage(GameState.strength)
	
func _on_upgraded(stat: String) -> void:
	if stat == "hp":
		health = min(health + 25.0, GameState.max_hp)

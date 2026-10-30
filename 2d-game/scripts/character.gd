extends CharacterBody2D

var health = 0
var time_since_hit = 0.0 
var attack_cooldown = 0.0
var invincible_time = 0.0

# Mahad's characters: which sprite each class uses and its animation names
const LOOKS = {
	"Brawler":  {"node": "BrawlerSprite",  "hitbox": "BrawlerHitbox",  "cooldown": 0.45, "idle": "idle", "run": "run", "attack": "Attack 1", "hurt": "Hurt", "death": "Death"},
	"Mage":     {"node": "MageSprite",     "hitbox": "MageHitbox",     "cooldown": 0.5,  "idle": "Idle", "run": "Run", "attack": "Attack",   "hurt": "Hurt", "death": "Death"},
	"Assassin": {"node": "AssassinSprite", "hitbox": "AssassinHitbox", "cooldown": 0.25, "idle": "Idle", "run": "run", "attack": "Attack 1", "hurt": "hurt", "death": "Death"},
}
var look = {}
var sprite: AnimatedSprite2D
var hitbox: Area2D
const FIREBALL = preload("res://2d-game/scenes/abilities/fire_ball.tscn")
const TORNADO = preload("res://2d-game/scenes/abilities/tornado.tscn")
var action_time = 0.0   # while above 0, an attack or hurt animation is playing
var dying = false

# Brawler block (hold right-click)
var blocking = false

# Assassin dash (Shift)
const DASH_SPEED = 650.0
var dash_time = 0.0
var dash_cooldown = 0.0
var dash_direction = Vector2.RIGHT

# Mage tornado (right-click)
var tornado_cooldown = 0.0

func _ready() -> void:
	add_to_group("player")
	health = GameState.max_hp
	get_node("../CanvasLayer/XP bar").value = GameState.xp
	GameState.upgraded.connect(_on_upgraded)

	# Show only the chosen class's character
	look = LOOKS[GameState.selected_class]
	for info in LOOKS.values():
		get_node(info.node).visible = false
	sprite = get_node(look.node)
	sprite.visible = true
	sprite.play(look.idle)

	# Keep only the chosen class's hitbox
	for info in LOOKS.values():
		if info.hitbox != look.hitbox:
			get_node(info.hitbox).queue_free()
	hitbox = get_node(look.hitbox)
	

func _physics_process(delta: float) -> void:
	if dying:
		return

	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Brawler: hold right-click to block. Can't move or attack, takes no damage.
	blocking = GameState.selected_class == "Brawler" and Input.is_action_pressed("Block")

	# Assassin: Shift dashes in the direction you're moving, briefly invincible
	dash_time -= delta
	dash_cooldown -= delta
	if GameState.selected_class == "Assassin" and Input.is_action_just_pressed("dash") and dash_cooldown <= 0:
		dash()

	# Mage: right-click casts a tornado around her that blows orcs away
	tornado_cooldown -= delta
	if GameState.selected_class == "Mage" and Input.is_action_just_pressed("Block") and tornado_cooldown <= 0:
		cast_tornado()

	if dash_time > 0:
		velocity = dash_direction * DASH_SPEED
	elif blocking:
		velocity = Vector2.ZERO
	else:
		velocity = direction * GameState.speed
	move_and_slide()
	
	attack_cooldown -= delta
	invincible_time -= delta

	if direction.x != 0:
		sprite.flip_h = direction.x < 0
		hitbox.scale.x = -1 if direction.x < 0 else 1

	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0 and not blocking:
		attack()

	# Animations: attack/hurt/dash play out first, then block, otherwise run or idle
	action_time -= delta
	if action_time <= 0:
		if blocking:
			if sprite.animation != "Block":
				sprite.play("Block")   # plays once, then holds the shield up
		else:
			sprite.play(look.run if direction != Vector2.ZERO else look.idle)
	
	time_since_hit += delta 
	if time_since_hit >= 20.0 and health > 0:
		health = min(health + 5.0 * delta, GameState.max_hp)
		
	get_node("../CanvasLayer/HP bar").value = health
	get_node("../CanvasLayer/HP bar").max_value = GameState.max_hp
	get_node("../CanvasLayer/health label").text = str(int(health)) + " / " + str(GameState.max_hp)
	get_node("../CanvasLayer/XP bar").value = GameState.xp
	get_node("../CanvasLayer/XP bar").max_value = GameState.xp_to_next_level()
	get_node("../CanvasLayer/Label").text = "Level " + str(GameState.level)
	get_node("../CanvasLayer/wave label").text = "Wave " + str(GameState.wave) + " / " + str(GameState.TOTAL_WAVES)
	
func take_damage(amount: int) -> void:
	if dying or invincible_time > 0 or blocking:
		return

	health = max(health - amount, 0.0)
	time_since_hit = 0.0
	invincible_time = 0.5
	# Getting hit doesn't interrupt an attack animation
	var attacking = sprite.animation == look.attack and action_time > 0
	if not attacking:
		sprite.play(look.hurt)
		action_time = anim_length(look.hurt)

	if health <= 0:
		die()

func die() -> void:
	dying = true
	velocity = Vector2.ZERO
	GameState.result_text = "You died on wave " + str(GameState.wave) + ", level " + str(GameState.level)
	get_node("../CanvasLayer/HP bar").value = 0
	get_node("../CanvasLayer/health label").text = "0 / " + str(GameState.max_hp)
	sprite.play(look.death)
	await get_tree().create_timer(anim_length(look.death) + 0.4).timeout
	get_tree().change_scene_to_file("res://2d-game/scenes/result.tscn")

func cast_tornado() -> void:
	tornado_cooldown = 4.0
	var tornado = TORNADO.instantiate()
	tornado.follow = self
	tornado.global_position = global_position
	get_parent().add_child(tornado)
	sprite.play("Push")
	action_time = anim_length("Push")

func dash() -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction == Vector2.ZERO:
		direction = Vector2.LEFT if sprite.flip_h else Vector2.RIGHT
	dash_direction = direction.normalized()
	dash_time = 0.18
	dash_cooldown = 0.8
	invincible_time = max(invincible_time, 0.25)   # dodge through orcs
	sprite.play("dash")
	action_time = 0.18
		
func enemy_defeated() -> void:
	if health > 0 and not dying:
		health = min(health + 5.0, GameState.max_hp)
		GameState.add_xp(1)
		
func attack() -> void:
	attack_cooldown = look.cooldown
	sprite.play(look.attack)
	action_time = anim_length(look.attack)
	for area in hitbox.get_overlapping_areas():
		var enemy = area.get_parent()
		if area.name == "Hurtbox" and enemy.is_in_group("enemy"):
			enemy.take_damage(GameState.strength)

	if GameState.selected_class == "Mage":
		shoot_fireball()

func shoot_fireball() -> void:
	var fireball = FIREBALL.instantiate()
	fireball.direction = -1.0 if sprite.flip_h else 1.0
	fireball.damage = GameState.strength
	fireball.position = global_position + Vector2(15 * fireball.direction, -5)
	get_parent().add_child(fireball)
	
func _on_upgraded(stat: String) -> void:
	if stat == "hp":
		health = min(health + 25.0, GameState.max_hp)

# How long an animation takes to play once, in seconds
func anim_length(anim: String) -> float:
	var frames = sprite.sprite_frames
	return frames.get_frame_count(anim) / frames.get_animation_speed(anim)


extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -350.0
@export var gravity: float = 980.0

# Fireball settings
@export var fireball_scene: PackedScene
@export var fireball_distance: float = 25.0
@export var fireball_height: float = 0.0

# Tornado settings
@export var tornado_scene: PackedScene
@export var tornado_distance: float = 30.0
@export var tornado_height: float = 0.0
@export var tornado_cooldown: float = 1.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var attacking: bool = false
var pushing: bool = false
var tornado_ready: bool = true

var _previous_j: bool = false
var _previous_left: bool = false
var _previous_right: bool = false
var _previous_w: bool = false

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Movement
	var direction: float = 0.0

	if Input.is_key_pressed(KEY_A):
		direction = -1.0
	elif Input.is_key_pressed(KEY_D):
		direction = 1.0

	# Controls
	var j_pressed := Input.is_key_pressed(KEY_J)
	var left_pressed := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var right_pressed := Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	var w_pressed := Input.is_key_pressed(KEY_W)

	var attack_pressed := (
		(j_pressed and not _previous_j)
		or (left_pressed and not _previous_left)
	)

	var push_pressed := right_pressed and not _previous_right
	var jump_pressed := w_pressed and not _previous_w

	_previous_j = j_pressed
	_previous_left = left_pressed
	_previous_right = right_pressed
	_previous_w = w_pressed

	# Tornado defense
	if push_pressed and not attacking and not pushing and tornado_ready:
		if tornado_scene != null:
			pushing = true
			velocity.x = 0.0
			sprite.play("Push")
			summon_tornado()

	# Fireball attack
	elif attack_pressed and not attacking and not pushing:
		attacking = true

		if direction != 0.0:
			sprite.flip_h = direction < 0.0
			sprite.play("Run and Attack")
		else:
			sprite.play("Attack")

		shoot_fireball()

	# Movement during attacks
	if pushing or (attacking and sprite.animation == "Attack"):
		velocity.x = 0.0
	else:
		velocity.x = direction * speed

	# Jump
	if jump_pressed and is_on_floor() and not attacking and not pushing:
		velocity.y = jump_velocity

	# Face movement direction
	if direction != 0.0 and not attacking and not pushing:
		sprite.flip_h = direction < 0.0

	# Normal animations
	if not attacking and not pushing:
		if not is_on_floor():
			if sprite.animation != "Jump":
				sprite.play("Jump")
		elif direction != 0.0:
			if sprite.animation != "Run":
				sprite.play("Run")
		else:
			if sprite.animation != "Idle":
				sprite.play("Idle")

	move_and_slide()

# Fireball attack
func shoot_fireball() -> void:
	if fireball_scene == null:
		push_warning("Fireball scene is not assigned!")
		return

	var fireball = fireball_scene.instantiate()
	var facing: float = -1.0 if sprite.flip_h else 1.0

	fireball.set("direction", facing)
	get_tree().current_scene.add_child(fireball)

	fireball.global_position = sprite.global_position + Vector2(
		fireball_distance * facing,
		fireball_height
	)

	fireball.set("start_position", fireball.global_position)

# Tornado defense
func summon_tornado() -> void:
	if tornado_scene == null:
		return

	tornado_ready = false

	var tornado = tornado_scene.instantiate()
	var facing: float = -1.0 if sprite.flip_h else 1.0

	get_tree().current_scene.add_child(tornado)

	# Spawn in front of Mage
	tornado.global_position = sprite.global_position + Vector2(
		tornado_distance * facing,
		tornado_height
	)

	start_tornado_cooldown()

# Five-second tornado cooldown
func start_tornado_cooldown() -> void:
	await get_tree().create_timer(tornado_cooldown).timeout
	tornado_ready = true

# Reset animations
func _on_animation_finished() -> void:
	if sprite.animation == "Attack" or sprite.animation == "Run and Attack":
		attacking = false
	elif sprite.animation == "Push":
		pushing = false

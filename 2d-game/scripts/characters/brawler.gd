
extends CharacterBody2D

@export var speed: float = 180.0
@export var jump_velocity: float = -350.0
@export var gravity: float = 980.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var attacking: bool = false
var blocking: bool = false
var combo_step: int = 0
var combo_queued: bool = false

func _ready() -> void:
	if not sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.connect(_on_animation_finished)
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Horizontal input
	var direction: float = 0.0

	if Input.is_key_pressed(KEY_A):
		direction -= 1.0
	if Input.is_key_pressed(KEY_D):
		direction += 1.0

	if direction != 0.0:
		sprite.flip_h = direction < 0.0

	# Blocking with right-click
	blocking = Input.is_action_pressed("Block")

	# Allow attacks while blocking
	if Input.is_action_just_pressed("attack"):
		if not attacking:
			combo_step = 1
			_play_attack()
		elif combo_step < 3:
			combo_queued = true

	# Stay still while blocking, including during attacks
	if blocking:
		velocity.x = 0.0
	else:
		velocity.x = direction * speed

	# Jump only when not blocking
	if Input.is_key_pressed(KEY_W) and is_on_floor() and not blocking:
		velocity.y = jump_velocity

	# Animations
	if not attacking:
		if blocking:
			if sprite.animation != "Block":
				sprite.play("Block")
		elif not is_on_floor():
			if velocity.y < 0.0:
				if sprite.animation != "Jump_Start":
					sprite.play("Jump_Start")
			else:
				if sprite.animation != "Jump_Fall":
					sprite.play("Jump_fall")
		elif direction != 0.0:
			if sprite.animation != "run":
				sprite.play("run")
		else:
			if sprite.animation != "idle":
				sprite.play("idle")

	move_and_slide()

func _play_attack() -> void:
	attacking = true
	combo_queued = false
	sprite.play("Attack " + str(combo_step))

func _on_animation_finished() -> void:
	if not attacking:
		return

	if combo_queued and combo_step < 3:
		combo_step += 1
		_play_attack()
	else:
		attacking = false
		combo_step = 0
		combo_queued = false

		if Input.is_action_pressed("Block"):
			sprite.play("Block")
		else:
			sprite.play("idle")

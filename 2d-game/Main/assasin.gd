
extends CharacterBody2D

@export var speed: float = 260.0
@export var jump_velocity: float = -350.0
@export var gravity: float = 980.0

@export var dash_speed: float = 500.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0

@export var parry_window: float = 0.4
@export var parry_cooldown: float = 1.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var attacking: bool = false
var dashing: bool = false
var parrying: bool = false

var can_dash: bool = true
var can_parry: bool = true
var can_double_jump: bool = true

var action: String = ""
var dash_direction: float = 1.0

var previous_attack1: bool = false
var previous_attack2: bool = false
var previous_jump: bool = false
var previous_dash: bool = false
var previous_parry: bool = false

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		can_double_jump = true

	# Movement
	var direction: float = 0.0

	if Input.is_key_pressed(KEY_A):
		direction = -1.0
	elif Input.is_key_pressed(KEY_D):
		direction = 1.0

	# Controls
	var attack1_down := (
		Input.is_key_pressed(KEY_J)
		or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	)
	var attack2_down := Input.is_key_pressed(KEY_K)
	var jump_down := Input.is_key_pressed(KEY_W)
	var dash_down := Input.is_key_pressed(KEY_SHIFT)
	var parry_down := Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)

	var attack1_pressed := attack1_down and not previous_attack1
	var attack2_pressed := attack2_down and not previous_attack2
	var jump_pressed := jump_down and not previous_jump
	var dash_pressed := dash_down and not previous_dash
	var parry_pressed := parry_down and not previous_parry

	previous_attack1 = attack1_down
	previous_attack2 = attack2_down
	previous_jump = jump_down
	previous_dash = dash_down
	previous_parry = parry_down

	# Turn toward movement direction
	if direction != 0.0 and action == "":
		sprite.flip_h = direction < 0.0

	# Parry
	if parry_pressed and can_parry and action == "":
		start_parry()

	# First dagger attack
	elif attack1_pressed and action == "":
		start_attack("Attack 1")

	# Second dagger attack
	elif attack2_pressed and action == "":
		start_attack("Attack 2")

	# Dash
	elif dash_pressed and can_dash and action == "":
		start_dash()

	# Jump and double jump
	if jump_pressed and action == "":
		if is_on_floor():
			velocity.y = jump_velocity
			sprite.play("Jump")
		elif can_double_jump:
			velocity.y = jump_velocity
			can_double_jump = false
			sprite.play("double_jump")

	# Horizontal movement
	if dashing:
		velocity.x = dash_direction * dash_speed
	elif attacking or parrying:
		velocity.x = 0.0
	else:
		velocity.x = direction * speed

	# Normal animations
	if action == "":
		if not is_on_floor():
			if sprite.animation != "Jump" and sprite.animation != "double_jump":
				sprite.play("Jump")
		elif direction != 0.0:
			if sprite.animation != "run":
				sprite.play("run")
		else:
			if sprite.animation != "Idle":
				sprite.play("Idle")

	move_and_slide()

	# Return to idle after landing
	if is_on_floor() and action == "":
		if direction == 0.0 and sprite.animation != "Idle":
			sprite.play("Idle")

func start_attack(animation_name: String) -> void:
	attacking = true
	action = animation_name
	velocity.x = 0.0
	sprite.play(animation_name)

func start_dash() -> void:
	dashing = true
	can_dash = false
	action = "dash"

	dash_direction = -1.0 if sprite.flip_h else 1.0

	sprite.play("dash")

	await get_tree().create_timer(dash_duration).timeout

	dashing = false
	action = ""

	await get_tree().create_timer(
		max(0.0, dash_cooldown - dash_duration)
	).timeout

	can_dash = true

func start_parry() -> void:
	parrying = true
	can_parry = false
	action = "parry"

	velocity.x = 0.0
	sprite.play("parry")

	await get_tree().create_timer(parry_window).timeout

	if parrying:
		parrying = false
		action = "parry_failed"
		sprite.play("parry_failed")

	await get_tree().create_timer(parry_cooldown).timeout
	can_parry = true

# Call this when an enemy attack is successfully parried
func successful_parry() -> void:
	if not parrying:
		return

	parrying = false
	action = "parry_counter"
	sprite.play("parry_counter")

func take_damage() -> void:
	if parrying:
		successful_parry()
		return

	attacking = false
	dashing = false
	parrying = false
	action = "hurt"
	sprite.play("hurt")

func die() -> void:
	attacking = false
	dashing = false
	parrying = false
	action = "Death"
	velocity = Vector2.ZERO
	sprite.play("Death")
	set_physics_process(false)

func _on_animation_finished() -> void:
	if sprite.animation == "Attack 1" or sprite.animation == "Attack 2":
		attacking = false
		action = ""

	elif sprite.animation == "parry":
		if parrying:
			parrying = false
			action = "parry_failed"
			sprite.play("parry_failed")

	elif sprite.animation == "parry_failed":
		action = ""

	elif sprite.animation == "parry_counter":
		action = ""

	elif sprite.animation == "hurt":
		action = ""

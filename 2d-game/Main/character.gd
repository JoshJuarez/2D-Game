extends CharacterBody2D

var speed = 0

func _ready() -> void:
	speed = GameState.speed
	#GameState.add_xp(10)
	#print(GameState.level)

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()

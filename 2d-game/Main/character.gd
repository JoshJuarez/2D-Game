extends CharacterBody2D

var speed = 0
var health = 100.0
var time_since_hit = 0.0 
var xp = 0
var level = 1

func _ready() -> void:
	speed = GameState.speed
	#GameState.add_xp(10)
	#print(GameState.level)

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	time_since_hit += delta 
	if time_since_hit >= 20.0 and health > 0:
		health = min(health + 5.0 * delta, 100.0)
	while xp >= 100:
		xp -= 100
		level += 1
	get_node("../CanvasLayer/HP bar").value = health 
	get_node("../CanvasLayer/XP bar").value = xp
	get_node("../CanvasLayer/Label").text = "Level" + str(level)
	
func take_damage(amount: int ) -> void:
	health = max(health - amount, 0.0)
	time_since_hit = 0.0
	
func enemy_defeated() -> void:
	if health > 0:
		health = min(health + 5.0, 100.0)
		xp += 10 

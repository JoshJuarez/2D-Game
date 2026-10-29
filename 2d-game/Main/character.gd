extends CharacterBody2D

var speed = 0
var health = 0
var time_since_hit = 0.0 

func _ready() -> void:
	speed = GameState.speed
	health = GameState.max_hp
	get_node("../CanvasLayer/HP bar").max_value = GameState.max_hp
	get_node("../CanvasLayer/XP bar").max_value = GameState.xp_to_next_level()
	get_node("../CanvasLayer/XP bar").value = GameState.xp
	

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	time_since_hit += delta 
	if time_since_hit >= 20.0 and health > 0:
		health = min(health + 5.0 * delta, GameState.max_hp)
		
	get_node("../CanvasLayer/HP bar").value = health 
	get_node("../CanvasLayer/XP bar").value = GameState.xp
	get_node("../CanvasLayer/Label").text = "Level " + str(GameState.level)
	
func take_damage(amount: int ) -> void:
	health = max(health - amount, 0.0)
	time_since_hit = 0.0
	
func enemy_defeated() -> void:
	if health > 0:
		health = min(health + 5.0, GameState.max_hp)
		GameState.add_xp(1)

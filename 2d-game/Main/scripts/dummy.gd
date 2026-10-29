extends StaticBody2D
func _ready() -> void:
	add_to_group("enemy")

func take_damage(amount: int) -> void:
	print("Dummy took ", amount)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

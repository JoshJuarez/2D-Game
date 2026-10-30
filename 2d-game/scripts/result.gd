extends Control

func _ready() -> void:
	%ResultLabel.text = GameState.result_text
	%RestartButton.pressed.connect(_restart)

func _restart() -> void:
	get_tree().change_scene_to_file("res://2d-game/scenes/class_select.tscn")

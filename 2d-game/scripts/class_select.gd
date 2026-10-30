extends Control

func _ready() -> void:
	%BrawlerButton.pressed.connect(_pick.bind("Brawler"))
	%AssassinButton.pressed.connect(_pick.bind("Assassin"))
	%MageButton.pressed.connect(_pick.bind("Mage"))

func _pick(chosen_class: String) -> void:
	GameState.start_run(chosen_class)
	get_tree().change_scene_to_file("res://2d-game/scenes/main_scene.tscn")

extends CanvasLayer

var pending_choices = 0

func _ready() -> void:
	hide()
	GameState.leveled_up.connect(_on_leveled_up)
	%HPButton.pressed.connect(_choose.bind("hp"))
	%SpeedButton.pressed.connect(_choose.bind("speed"))
	%StrengthButton.pressed.connect(_choose.bind("strength"))

func _on_leveled_up(_new_level) -> void:
	pending_choices += 1
	show()
	get_tree().paused = true

func _choose(stat: String) -> void:
	GameState.apply_upgrade(stat)
	pending_choices -= 1
	if pending_choices <= 0:
		hide()
		get_tree().paused = false

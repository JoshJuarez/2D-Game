extends Node

signal wave_started(wave_number)
signal all_waves_cleared

const ORC_SCENE = preload("res://2d-game/scenes/orc.tscn")
const TOTAL_WAVES = 1
const SPAWN_DISTANCE = 350.0

var enemies_alive = 0

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	start_next_wave()

func start_next_wave() -> void:
	GameState.wave += 1
	wave_started.emit(GameState.wave)
	var count = 3 + 2 * GameState.wave
	enemies_alive = count
	for i in count:
		spawn_orc()

func spawn_orc() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var orc = ORC_SCENE.instantiate()
	var angle = randf() * TAU
	orc.position = player.global_position + Vector2.RIGHT.rotated(angle) * SPAWN_DISTANCE
	orc.health = 30 + 10 * (GameState.wave - 1)
	orc.speed = 110 + 10 * (GameState.wave - 1)
	orc.died.connect(_on_orc_died)
	get_parent().add_child(orc)

func _on_orc_died() -> void:
	enemies_alive -= 1
	if enemies_alive > 0:
		return
	if GameState.wave >= TOTAL_WAVES:
		get_tree().change_scene_to_file("res://2d-game/scenes/result.tscn")
		all_waves_cleared.emit()
	else:
		await get_tree().create_timer(3.0).timeout
		start_next_wave()

extends Node

signal leveled_up(new_level)
signal xp_changed(current_xp, xp_needed)

const CLASSES = {
	"Brawler":  {"max_hp": 150, "speed": 160, "strength": 15},
	"Assassin": {"max_hp": 80,  "speed": 260, "strength": 12},
	"Mage":     {"max_hp": 90,  "speed": 200, "strength": 25},
}

const TOTAL_WAVES = 5

var selected_class = "Brawler"
var max_hp = 0
var speed = 0
var strength = 0
var xp = 0
var level = 1
var wave = 0
var result_text = ""

signal upgraded(stat)

func _ready() -> void:
	start_run(selected_class)

# Resets everything for a fresh run with the chosen class
func start_run(chosen_class: String) -> void:
	selected_class = chosen_class
	var stats = CLASSES[chosen_class]
	max_hp = stats.max_hp
	speed = stats.speed
	strength = stats.strength
	xp = 0
	level = 1
	wave = 0

func xp_to_next_level() -> int:
	return 1 + 2 * level

func add_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_to_next_level():
		xp -= xp_to_next_level()
		level += 1
		leveled_up.emit(level)
	xp_changed.emit(xp, xp_to_next_level())

# Called by the level-up popup on Day 2
func apply_upgrade(stat: String) -> void:
	match stat:
		"hp": max_hp += 25
		"speed": speed += 25
		"strength": strength += 5
	upgraded.emit(stat)

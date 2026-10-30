extends Node2D

# Different trees from Trees+.png (green, dark green, red, light green...)
const LOOKS = [
	Rect2(0, 13, 76, 83), Rect2(79, 13, 77, 83), Rect2(159, 13, 77, 83),
	Rect2(319, 13, 79, 83), Rect2(399, 13, 79, 83), Rect2(479, 13, 79, 83),
]

func _ready() -> void:
	# Pick a look based on position, so each tree always looks the same
	var i = abs(int(position.x * 7 + position.y * 13)) % LOOKS.size()
	$Sprite2D.region_rect = LOOKS[i]

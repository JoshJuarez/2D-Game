extends Sprite2D

# Small ground decorations from Trees+.png: stumps, bushes, roots, tiny mushrooms
const LOOKS = [
	Rect2(639, 165, 22, 28), Rect2(671, 165, 22, 28),
	Rect2(639, 259, 30, 30), Rect2(671, 259, 30, 30), Rect2(703, 259, 30, 30), Rect2(735, 259, 30, 30),
	Rect2(639, 292, 31, 29), Rect2(671, 292, 31, 29), Rect2(671, 323, 30, 30),
	Rect2(671, 202, 26, 23), Rect2(703, 202, 26, 23),
	Rect2(735, 914, 14, 15), Rect2(751, 914, 14, 15), Rect2(735, 930, 14, 14), Rect2(751, 930, 14, 14),
]

func _ready() -> void:
	var i = abs(int(position.x * 7 + position.y * 13)) % LOOKS.size()
	region_rect = LOOKS[i]

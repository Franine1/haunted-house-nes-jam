extends Sprite2D
const game_data: GameData = preload("res://resources/game data/gameData.tres")
func _ready():
	print("ugh")
	var temp: Array[Dialogue]
	for child in get_children():
		if child is Dialogue:
			temp.append(child)
			print(temp[0].line())

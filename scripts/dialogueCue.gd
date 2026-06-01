class_name DialogueCue
extends Dialogue

@export var cue: String
@export var value: int
@export var additive: bool = true
const game_data: GameData = preload("res://resources/game data/gameData.tres")

func line() -> Array[String]:
	return []

func A_reaction():
	pass

func select_reaction():
	pass

func dialogue_finished() -> bool:
	if !additive:
		game_data.set_data(cue,0)
	game_data.change_data(cue,value)
	return true

func reset_dialogue() -> void:
	pass

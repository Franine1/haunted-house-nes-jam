class_name DialogueCue
extends Dialogue

@export var cue: String
@export var value: Variant
const game_data: GameData = preload("res://resources/game data/gameData.tres")

func line() -> Array[String]:
	return []

func A_reaction():
	pass

func select_reaction():
	pass

func dialogue_finished() -> bool:
	game_data.set_data(cue,value)
	return true

func reset_dialogue() -> void:
	pass

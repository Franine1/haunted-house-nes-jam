class_name DialogueCue
extends Dialogue

@export var cue: String
@export var value: int
@export var delay: float = 0.0
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
	if delay <= 0:
		game_data.change_data(cue,value)
	else:
		var source = get_tree().current_scene
		source.get_tree().create_timer(delay).timeout.connect(game_data.change_data.bind(cue,value))
	return true

func reset_dialogue() -> void:
	pass

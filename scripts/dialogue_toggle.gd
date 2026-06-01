class_name DialogueToggle
extends DialogueSection

@export var cue: String
@export var value: int
const game_data: GameData = preload("res://resources/game data/gameData.tres")



func dialogue_finished() -> bool:
	if game_data.get_data(cue) < value:
		return true
	return (index >= sections.size() or index < 0 or (index == (sections.size()-1) and sections[index].dialogue_finished()))

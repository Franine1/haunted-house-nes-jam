class_name DialogueToggle
extends DialogueSection

@export var cue: String
@export var value: int
## This toggle only activates if the "CUE" is "COMPARE_TYPE" compared to "VALUE".
@export var compare_type: compare = compare.GREATER_OR_EQUAL
const game_data: GameData = preload("res://resources/game data/gameData.tres")

enum compare {
	EQUAL
	,LESS
	,GREATER
	,LESS_OR_EQUAL
	,GREATER_OR_EQUAL
}

func dialogue_finished() -> bool:
	var temp: int = game_data.get_data(cue)
	var valid: bool = false
	if temp == value:
		if [compare.EQUAL,compare.LESS_OR_EQUAL,compare.GREATER_OR_EQUAL].has(compare_type):
			valid = true
	
	if temp < value:
		if [compare.LESS,compare.LESS_OR_EQUAL].has(compare_type):
			valid = true
	
	if temp > value:
		if [compare.GREATER,compare.GREATER_OR_EQUAL].has(compare_type):
			valid = true
	
	if !valid:
		return true
	return (index >= sections.size() or index < 0 or (index == (sections.size()-1) and sections[index].dialogue_finished()))

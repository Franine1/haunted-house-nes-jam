## Expands upon the capabilities of a DialogueSection by having the bonus of
## being able to skip itself if it finds a boolean expression to be
## false. It only does integer comparisons, based on a datapoint
## in the central game_data resource of your choosing. Could be used to make
## the same interaction point give different text based on how many
## times you interact, or to make an interaction only happen if 
## the player did something elsewhere in the world.
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

## Same as a DialogueSection's dialogue_finished, except
## if it's boolean comparison is found to be false, the dialogue
## automatically is declared to be finished.
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

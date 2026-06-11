## Dialogue lines act as the actual text part of dialogue. 
## They provide all of their lines from an array of strings,
## in order. This is the only dialogue piece that adds text.
class_name DialogueLines
extends Dialogue

## The actual lines of dialogue
@export var lines: Array[String]
## DEPRECATED Speed that the letters display at
@export var display_speed: float = 0.01
## A value that adds a name to the start of the dialogue, 
## reading it from game_data. This allows easily changing names across
## all dialogue scripts.
@export var name_id: int = 0
## Which line we're currently on
var index: int = 0
## Reference to the game data
const game_data: GameData = preload("res://resources/game data/gameData.tres")

## provides the current line 
func line() -> Array[String]:
	game_data.set_data("letters",roundi(100*display_speed))
	if dialogue_finished():
		return []
	return [game_data.name(name_id) + lines[index]]

## goes up one line
func A_reaction():
	index += 1


## does nothing on select
func select_reaction():
	pass

## The dialogue is finished if our index isn't in the array of strings
func dialogue_finished(_current: bool = false) -> bool:
	return (index >= lines.size() or index < 0)

## resetting dialogue sets the index back to 0.
func reset_dialogue() -> void:
	index = 0

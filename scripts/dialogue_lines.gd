## Dialogue lines act as the actual text part of dialogue. 
## They provide all of their lines from an array of strings,
## in order. This is the only dialogue piece that adds text.
class_name DialogueLines
extends Dialogue

## The actual lines of dialogue
@export var lines: Array[String]
## Which line we're currently on
var index: int = 0


## provides the current line 
func line() -> Array[String]:
	if dialogue_finished():
		return []
	return [lines[index]]

## goes up one line
func A_reaction():
	index += 1


## does nothing on select
func select_reaction():
	pass

## The dialogue is finished if our index isn't in the array of strings
func dialogue_finished() -> bool:
	return (index >= lines.size() or index < 0)

## resetting dialogue sets the index back to 0.
func reset_dialogue() -> void:
	index = 0

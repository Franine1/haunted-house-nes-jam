class_name DialogueLines
extends Dialogue


@export var lines: Array[String]
var index: int = 0



func line() -> Array[String]:
	if dialogue_finished():
		return []
	return [lines[index]]


func A_reaction():
	index += 1



func select_reaction():
	pass


func dialogue_finished() -> bool:
	return (index >= lines.size() or index < 0)


func reset_dialogue() -> void:
	index = 0

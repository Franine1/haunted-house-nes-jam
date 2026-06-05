## The DialogueSection class is a container for other dialogue.
## Its role is to have multiple Dialogue nodes as its children,
## and read all of them, in order, even if they're different kinds of dialogue.
## Generally this will be the parent node of a dialogue scene if
## your dialogue isn't exclusively text, like if there's options,
## sections that might not show in some cases, or cues to the game world.
class_name DialogueSection
extends Dialogue


var sections: Array[Dialogue]
var index: int = 0


## returns the current line in the current section
func line() -> Array[String]:
	if dialogue_finished():
		return []
	return sections[index].line()

## pass down the A interaction to the current section,
## then if the current section is finished, 
## go to the next unfinished section
func A_reaction():
	if dialogue_finished():
		return
	
	sections[index].A_reaction()
	if sections[index].dialogue_finished():
		index += 1
		if dialogue_finished():
			return
		sections[index].reset_dialogue()
		while !dialogue_finished() and sections[index].dialogue_finished():
			index += 1
			sections[index].reset_dialogue()

## passes down the interaction to the current section
func select_reaction():
	if dialogue_finished():
		return
	sections[index].select_reaction()

## dialogue is finished if every single section's dialogue is finished.
func dialogue_finished() -> bool:
	while index < sections.size()-1 and sections[index].dialogue_finished():
		index += 1
	return (index >= sections.size() or index < 0 or (index == (sections.size()-1) and sections[index].dialogue_finished()))


func reset_dialogue() -> void:
	index = 0
	
	sections = []
	
	for child in get_children():
		if child is Dialogue:
			sections.append(child)
			child.reset_dialogue()
	
	#sections[index].reset_dialogue()

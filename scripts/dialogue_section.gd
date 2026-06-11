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
	while sections[index].dialogue_finished():
		index += 1
		if dialogue_finished(true):
			return []
		sections[index].reset_dialogue()
	return sections[index].line()

## pass down the A interaction to the current section,
## then if the current section is finished, 
## go to the next unfinished section
func A_reaction():
	if dialogue_finished(true):
		return
	
	sections[index].A_reaction()
	while sections[index].dialogue_finished():
		index += 1
		if dialogue_finished(true):
			return
		sections[index].reset_dialogue()

## passes down the interaction to the current section
func select_reaction():
	if dialogue_finished():
		dialogue_finished(true)
		return
	sections[index].select_reaction()

## dialogue is finished if every single section's dialogue is finished.
func dialogue_finished(current: bool = false) -> bool:
	var temp = index
	while index < sections.size()-1 and sections[index].dialogue_finished():
		sections[index].dialogue_finished(current)
		index += 1
	var ans = (index >= sections.size() or index < 0)
	if (index == (sections.size()-1) and sections[index].dialogue_finished()):
		ans = true
		sections[index].dialogue_finished(current)
	
	if !current and false:
		index = temp
	
	return ans


func reset_dialogue() -> void:
	index = 0
	
	sections = []
	
	for child in get_children():
		if child is Dialogue:
			sections.append(child)
			child.reset_dialogue()
	
	#sections[index].reset_dialogue()

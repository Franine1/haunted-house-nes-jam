class_name DialogueSection
extends Dialogue


var sections: Array[Dialogue]
var index: int = 0



func line() -> Array[String]:
	if dialogue_finished():
		return []
	return sections[index].line()


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


func select_reaction():
	if dialogue_finished():
		return
	sections[index].select_reaction()


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

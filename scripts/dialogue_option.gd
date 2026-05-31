class_name DialogueOption
extends Dialogue


@export var choices: Array[Dialogue]
var index: int = 0
var choice_made: bool = false



func line() -> Array[String]:
	if dialogue_finished():
		return []
	if !choice_made:
		
		while choices[index].line().size() == 0:
			index += 1
			index %= choices.size()
		
		var ans = []
		for i in choices.size():
			var choice: Dialogue = choices[i]
			var temp: Array[String] = choice.line()
			if temp.size() == 0:
				continue
			if i == index:
				temp[0] = "> " + temp[0]
			ans.append(temp[0])
		return ans
	else:
		return choices[index].line()


func A_reaction():
	if dialogue_finished():
		return
	if !choice_made:
		choice_made = true
		choices[index].reset_dialogue()
	else:
		choices[index].A_reaction()


func B_reaction():
	if dialogue_finished():
		return
	if choice_made:
		choices[index].B_reaction()


func select_reaction():
	if dialogue_finished():
		return
	if !choice_made:
		index += 1
		index %= choices.size()
		while choices[index].line().size() == 0:
			index += 1
			index %= choices.size()
	else:
		choices[index].select_reaction()


func dialogue_finished() -> bool:
	return (index >= choices.size() or index < 0 or (choices[index].dialogue_finished() and choice_made))


func reset_dialogue() -> void:
	index = 0
	
	choice_made = false
	for choice in choices:
		choice.reset_dialogue()
	

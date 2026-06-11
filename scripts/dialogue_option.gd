## Dialogue options are a container of other dialogue, 
## and a branch point for conversations. The way it works
## is, you give it child nodes that are of type Dialogue. 
## Then, it gets the first line from each of them and displays
## it as one of the options. Unlike other dialogue containers,
## rather than reading all of its child dialogue nodes one by
## one, it only reads the one for the selected choice.
class_name DialogueOption
extends Dialogue

## All the dialogue choices
var choices: Array[Dialogue] = []
## Which choice is currently/was selected
var index: int = 0
## Whether or not we already selected our choice
var choice_made: bool = false


## Either provides an array of all choices for the player,
## or the next line of whichever choice was selected.
func line() -> Array[String]:
	if dialogue_finished():
		dialogue_finished(true)
		return []
	if !choice_made:
		# skip any choices without dialogue
		while choices[index].line().size() == 0:
			index += 1
			index %= choices.size()
		
		# get the first line of every choice
		var ans: Array[String] = []
		for i in choices.size():
			var choice: Dialogue = choices[i]
			var temp: Array[String] = choice.line()
			if temp.size() == 0:
				continue
			if i == index:
				# add an indicator for the currently selected choice
				temp[0] = ">" + temp[0]
			ans.append(temp[0])
		return ans
	else:
		# otherwise, just return the next line for what was chosen.
		return choices[index].line()


func A_reaction():
	if dialogue_finished(true):
		return
	if !choice_made:
		# approve the currently selected choice
		choice_made = true
		choices[index].reset_dialogue()
		choices[index].A_reaction()
	else:
		# pass down the A interaction to the chosen dialogue path
		choices[index].A_reaction()


func select_reaction():
	if dialogue_finished():
		dialogue_finished(true)
		return
	if !choice_made:
		# move through the available choices
		index += 1
		index %= choices.size()
		while choices[index].line().size() == 0:
			index += 1
			index %= choices.size()
	else:
		# pass down the select interaction to the chosen dialogue path
		choices[index].select_reaction()


func dialogue_finished(current: bool = false) -> bool:
	# if the index is invalid or the selected choice has its dialogue finished, this dialogue path ends
	var ans = (index >= choices.size() or index < 0)
	
	if (choices[index].dialogue_finished() and choice_made):
		ans = true
		choices[index].dialogue_finished(current)
	return ans


## Resets itself alongside every choice in its children.
func reset_dialogue() -> void:
	index = 0
	
	choice_made = false
	
	choices = []
	
	for child in get_children():
		if child is Dialogue:
			choices.append(child)
	
	for choice in choices:
		choice.reset_dialogue()
	

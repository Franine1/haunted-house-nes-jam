## dialogue loops are intended for sections of dialogue that 
## continue to repeat while their condition remains true. 
## This comes with the DANGER of infinite loops of dialogue
## when an exit condition is lacking, especially when no dialogue
## lines are in the loop. Exercise with caution due to this.
class_name DialogueLoop
extends DialogueToggle



## continues to loop through its dialogue sections
## as long as the activation condition remains true
func A_reaction():
	if dialogue_finished():
		return
	
	sections[index].A_reaction()
	while sections[index].dialogue_finished():
		index += 1
		if index >= sections.size():
			index = 0
		sections[index].reset_dialogue()



## Same as a DialogueToggle's dialogue_finished, except
## it doesn't care about whether its sections are finished or
## not, and is solely based on the activation condition.
func dialogue_finished() -> bool:
	
	var temp: int = game_data.get_data(cue)
	var valid: bool = false
	if temp == value:
		if [compare.EQUAL,compare.LESS_OR_EQUAL,compare.GREATER_OR_EQUAL].has(compare_type):
			valid = true
	else:
		if [compare.NOT_EQUAL].has(compare_type):
			valid = true
		
	if temp < value:
		if [compare.LESS,compare.LESS_OR_EQUAL].has(compare_type):
			valid = true
	
	if temp > value:
		if [compare.GREATER,compare.GREATER_OR_EQUAL].has(compare_type):
			valid = true
	
	if !valid:
		return true
	
	return (index >= sections.size() or index < 0)

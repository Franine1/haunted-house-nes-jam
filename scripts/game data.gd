## This resource is intended to store variables and data
## global to all nodes. Rather than an absurdly complex web
## of signals for all possible reactions, it's simpler to just
## add a data point to the game_data class and have the other
## node check for it. the GameCue class was written to expedite
## this process and keep the scripts that check for datapoint changes
## from having redundant code.
class_name GameData
extends Resource

## emits any time any data point changes. I do not recommend
## connecting this directly to any node, and instead use GameCues
## as a middleman.
signal data_change(key: String, value: int)
## all the global data points. They're identified with a string and always
## return an int.
var data: Dictionary[String,int] = {}
## List of currently queued dialogue.
var dialogue_queue: Array[Dialogue] = []



## IMPORTANT: data values with meaning
## 
## INFO: "level": sets the level
## INFO: "x_shift", "y_shift": moves the player that many tiles
## INFO: "x_set", "y_set": teleports the player to that spot in world coordinates
## INFO: "reposition": the x and y shift and set parameters are only checked if this value is not zero
## 
## INFO: "forced": meant to indicate the current level of progression in scripted scenes.
## this value decreases by 1 every time the next scripted sequence is performed.
## 
## INFO: "letters": this indicates the speed at which letters should appear at.
## The min speed is 0.01, and this value is multiplied by that for the resulting speed.
## INFO: "skip": The value of this int is the number of times the game will automatically finish dialogue.


## sets a data point in the data library
func set_data(key: String, value: int) -> void:
	data[key] = value
	data_change.emit(key,data[key])

## adds an inputted value to a data point in the data library
func change_data(key: String, value: int) -> void:
	if !data.has(key):
		data[key] = 0
	data[key] += value
	data_change.emit(key,data[key])

## checks if there is a value for the requested data point
func has_data(key: String) -> bool:
	return data.has(key)

## gets a data point from the data libary
func get_data(key: String) -> int:
	if !data.has(key):
		return 0
	return data[key]

## removes a data entry from the data library
func remove_data(key: String) -> void:
	data.erase(key)

## queues a new dialogue script to be read through.
## Note that the queue is in reverse order, with the
## last elements in the array being first on the queue.
## This is for optimization purposes.
func queue_dialogue(input: Dialogue) -> void:
	var temp: Array[Dialogue] = [input]
	temp.append_array(dialogue_queue)
	dialogue_queue = temp

## Queues an entire array of dialogue. Like the regular 
## dialogue queue, the dialogue is stored in reverse order,
## but the input is automatically converted into the proper format.
func queue_dialogue_array(input: Array[Dialogue]) -> void:
	var temp: Array[Dialogue] = []
	for i in range(input.size()-1,-1,-1):
		temp.append(input[i])
	temp.append_array(dialogue_queue)
	dialogue_queue = temp

## Gets the next dialogue script on the dialogue queue,
## and removes it from the queue.
func next_dialogue() -> Dialogue:
	return dialogue_queue.pop_back()

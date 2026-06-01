class_name GameData
extends Resource


var data: Dictionary[String,int] = {}
var dialogue_queue: Array[Dialogue] = []

func set_data(key: String, value: int) -> void:
	data[key] = value

func change_data(key: String, value: int) -> void:
	if !data.has(key):
		data[key] = 0
	data[key] += value

func has_data(key: String) -> bool:
	return data.has(key)

func get_data(key: String) -> int:
	if !data.has(key):
		return 0
	return data[key]

func queue_dialogue(input: Dialogue) -> void:
	var temp: Array[Dialogue] = [input]
	temp.append_array(dialogue_queue)
	dialogue_queue = temp

func queue_dialogue_array(input: Array[Dialogue]) -> void:
	var temp: Array[Dialogue] = []
	for i in range(input.size()-1,-1,-1):
		temp.append(input[i])
	temp.append_array(dialogue_queue)
	dialogue_queue = temp

func next_dialogue() -> Dialogue:
	return dialogue_queue.pop_back()

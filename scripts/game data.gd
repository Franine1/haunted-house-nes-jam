class_name GameData
extends Resource


var data: Dictionary[String,int] = {}


func set_data(key: String, value: int) -> void:
	data[key] = value

func change_data(key: String, value: int) -> void:
	if !data.has(key):
		data[key] = 0
	data[key] += value

func has_data(key: String) -> bool:
	return data.has(key)

func get_data(key: String) -> int:
	return data[key]

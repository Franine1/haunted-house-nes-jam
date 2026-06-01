class_name GameData
extends Resource


var data: Dictionary[String,Variant] = {}


func set_data(key: String, value) -> void:
	data[key] = value

func get_data(key: String) -> Variant:
	return data[key]

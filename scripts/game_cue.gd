class_name GameCue
extends Node

const game_data: GameData = preload("res://resources/game data/gameData.tres")

var cues: Dictionary[String,Callable] = {}



func _init() -> void:
	cues.clear()
	game_data.data_change.connect(check_cues)


func check_cues(key: String, value: int) -> void:
	if cues.has(key):
		cues[key].call(value)


func add_cue(key: String, function: Callable) -> void:
	
	cues[key] = function

func remove_cue(key: String) -> void:
	if cues.has(key):
		cues.erase(key)

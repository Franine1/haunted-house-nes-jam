## GameCues are designed to "filter" through the changes
## in the GameData library so that you can choose which changes
## you actually care about. A different GameCue node is expected
## for each thing reacting to game data changes, and they are expected
## to be a child node of what they are alerting. To set up a cue,
## the parent class should call 
## GameCue.add_cue(datapoint_to_check,function_to_call_in_response) 
## and the GameCue will simply call the correct function from its parent
## when that datapoint changes. 
class_name GameCue
extends Node

const game_data: GameData = preload("res://resources/game data/gameData.tres")

var cues: Dictionary[String,Callable] = {}



func _init() -> void:
	cues.clear()
	game_data.data_change.connect(check_cues)


func check_cues(key: String, value: int) -> void:
	if cues.has(key):
		print(key + ": " + str(value))
		cues[key].call(value)


func add_cue(key: String, function: Callable) -> void:
	
	cues[key] = function

func remove_cue(key: String) -> void:
	if cues.has(key):
		cues.erase(key)

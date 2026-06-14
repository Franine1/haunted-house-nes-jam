class_name SaveSlot
extends Control


const game_data: GameData = preload("res://resources/game data/gameData.tres")
const level_names: Array[String] = [
	"Driveway"
	,"Lea's House"
	,"Washing Machine"
	,"Liminal House"
	,"Backyard"
	,"Second Floor"
	,"Master Bedroom"
]


@onready var title: RichTextLabel = %title
@onready var level: RichTextLabel = %game_level
@onready var play_time: RichTextLabel = %play_time
@onready var new_game: RichTextLabel = %richtextlabel
@onready var back: Panel = $Panel


func display(slot_id: int) -> void:
	var info: Dictionary[GameData.variables,Dictionary] = game_data.get_game(slot_id)
	var data: Dictionary[String,int] = {}
	
	if info.has(GameData.variables.DATA):
		data = info[GameData.variables.DATA]
	
	title.text = "Slot " + str(slot_id+1)
	
	if data.has("level") and data["level"] >= 0 and data["level"] < level_names.size():
		new_game.hide()
		level.text = level_names[data["level"]]
		level.show()
	
	
		if info.has(GameData.variables.TIME):
			play_time.text = convert_time(info[GameData.variables.TIME]["default"])
			play_time.show()


func display_from_text(input: String, slot: int) -> void:
	display(slot)
	
	var read_text: String = input
	var select: bool = read_text[0] == ">"
	if select:
		read_text = read_text.substr(1)
		pass
	
	back.theme_type_variation = "Panel"
	if select:
		back.theme_type_variation = "SelectedPanel"


func convert_time(input: float) -> String:
	var temp = input / 3600.0
	
	var h = floor(temp)
	
	temp = 60.0 * (temp - h)
	
	var m = floor(temp)
	
	temp = 60.0 * (temp - m)
	
	var quarter_minute = floor(temp)
	
	var s = 1.0 * quarter_minute
	
	
	var second_string: String = str(snapped(s,1)) + "s"
	
	var minute_string: String = str(snapped(m,1)) + "m"
	
	var hour_string: String = str(snapped(h,1)) + "h"
	
	var ans: String = ""
	
	if h >= 1.0:
		ans = hour_string + " " + minute_string
	elif m >= 1.0:
		ans = minute_string + " " + second_string
	else:
		ans = second_string
	
	return ans

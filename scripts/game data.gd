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
var data: Dictionary[String,int] = {
	"level": 2
}
## List of currently queued dialogue.
var dialogue_queue: Array[Dialogue] = []
## List of the movement queues listed for different NPC IDs
var movement_queues: Dictionary[int,Array] = {}
## initial player transformation
var player_position: Vector4 = Vector4.ZERO
## initial astral position
var astral_position: Vector2 = Vector2.ZERO
## path to save files to
const savepath: String = "user://savedgames/"


## TODO: fully implement this
## used to request redundant dialogue scenes or changing scenes
@export var saved_dialogue: Dictionary[String,PackedScene] = {}


## IMPORTANT: data values with meaning
## 
##
## INFO: "menu": used to determine what menu section we're in. 
## 0: Main menu | 1: Pause menu | 2: game saves | 3: options | 4: exiting game | 5: starting game 
## INFO: "confirm", "slot", "saved": used to organize the game menu properly
##
## INFO: "exit_banned": while this isn't zero, the player cannot reach the menu
##
##
## INFO: "level": sets the level
## INFO: "x_shift", "y_shift": moves the player that many tiles
## INFO: "x_set", "y_set": teleports the player to that spot in world coordinates
## INFO: "reposition": the x and y shift and set parameters are only checked if this value is not zero
## 
## INFO: "forced": meant to indicate the current level of progression in scripted scenes.
## this value decreases by 1 every time the next scripted sequence is performed.
## 
## INFO: "lettering": this indicates the speed at which letters should appear at.
## The min speed is 0.01, and this value is multiplied by that for the resulting speed.
## INFO: "skip": The value of this int is the number of times the game will automatically finish dialogue.
## INFO: "delay": forces the game manager to wait a certain amount of time before resuming dialogue. 
## These are measured in tenths of seconds.
##
##
##
## INFO: "host": meant to indicate different stages of progression for the host, who
## invited the player.
## INFO: "sink": indicates when the sink is running, and which one.
##
##
##
## INFO: "omen", "wonder", "ominous": these tags are meant for limited time interactions



const names: Array[String] = [
	""
	,"You"
	,"Lea"
	,"Window Person"
]

const tooltips: Array[Array] = [
	[""]
	,["~1 / 3"]
	,["~2 / 3"]
	,["~3 / 3"]
	,["~Hold B to close your eyes"]
]




## returns the current tooltip being displayed
func next_tooltip() -> Array[String]:
	if data["tooltip"] > 0 and tooltips.size() > data["tooltip"]:
		var t = tooltips[data["tooltip"]]
		var ans: Array[String] = []
		for item in t:
			if item is String:
				ans.append(item)
		return ans
	return []


## returns the preset name of an NPC
func name(input: int) -> String:
	if input >= names.size() or input < 0:
		return ""
	var ans: String = names[input]
	if ans.length() > 0:
		ans = ans + ":  "
	return ans

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


## This function queues NPC nodes with the corresponding NPC ID
## to navigate the requested movement directions
func queue_movement(input: CutscenePath, npc_id: int) -> void:
	var sub: Array[CutscenePath] = [input]
	if !movement_queues.has(npc_id):
		movement_queues[npc_id] = sub
	else:
		var temp = movement_queues[npc_id]
		movement_queues[npc_id] = sub
		movement_queues[npc_id].append_array(temp)


## Same as above, except it queues an array of CutscenePaths
func queue_movement_array(input: Array[CutscenePath], npc_id: int) -> void:
	if !movement_queues.has(npc_id):
		movement_queues[npc_id] = input
	else:
		var temp = movement_queues[npc_id]
		movement_queues[npc_id] = input
		movement_queues[npc_id].append_array(temp)


func accept_movement(npc_id: int) -> Array[CutscenePath]:
	var ans: Array[CutscenePath] = []
	if movement_queues.has(npc_id):
		ans = movement_queues[npc_id]
		movement_queues.erase(npc_id)
	return ans


## resets the game data
func reset_game() -> void:
	data.clear()
	player_position = Vector4.ZERO
	set_data("music",1)


## saves the game data to a slot
func save_game(slot: int) -> void:
	ensure_folder()
	
	var file: FileAccess = FileAccess.open(get_slot_name(slot),FileAccess.WRITE)
	
	var temp = [player_position[0],player_position[1],player_position[2],player_position[3],astral_position[0],astral_position[1]]
	file.store_csv_line(prepare_csv(temp))
	
	for key in data.keys():
		file.store_csv_line(prepare_csv([key,data[key]]))
	
	file.close() 


## loads a save slot into game data
func load_game(slot: int) -> bool:
	ensure_folder()
	reset_game()
	
	var file: FileAccess = FileAccess.open(get_slot_name(slot),FileAccess.READ)
	if file == null:
		return false
	
	var repos: bool = false
	
	while !file.eof_reached():
		var next: PackedStringArray = file.get_csv_line()
		
		if !repos:
			repos = true
			var result: Array[float] = []
			for i in range(6):
				if i < next.size():
					result.append(float(next.get(i)))
				else:
					result.append(0.0)
			
			player_position = Vector4(result[0],result[1],result[2],result[3])
			astral_position = Vector2(result[4],result[5])
			
		else:
			if next.size() >= 2:
				var key: String = next.get(0)
				var result: int = int(next.get(1))
				
				data[key] = result
	
	file.close() 
	
	data_change.emit("music",data["music"])
	data_change.emit("volume",data["volume"])
	
	return true


## deletes a save slot
func delete_game(slot: int) -> void:
	ensure_folder()
	if DirAccess.dir_exists_absolute(get_slot_name(slot)):
		DirAccess.remove_absolute(get_slot_name(slot))
	





## ensures the save folder exists
func ensure_folder() -> void:
	if !DirAccess.dir_exists_absolute((savepath)):
		DirAccess.make_dir_recursive_absolute(savepath)


## gets the file name for a specific slot
func get_slot_name(slot: int) -> String:
	return savepath + "save_" + str(slot) + ".csv"



## prepares an array of data to become a CSV line
func prepare_csv(input: Array) -> PackedStringArray:
	var temp: Array[String] = []
	
	for i in input:
		temp.append(str(i))
	
	var ans: PackedStringArray = PackedStringArray(temp)
	
	return ans
	

## lets the player upload their position and camera snap axis
func accept_player_position(pos: Vector2, snap: Vector2) -> void:
	player_position = Vector4(pos.x,pos.y,snap.x,snap.y)

## lets the player upload their position and camera snap axis
func accept_astral_position(pos: Vector2, snap: Vector2) -> void:
	astral_position = Vector2(pos.x,pos.y)
	player_position = Vector4(player_position[0],player_position[1],snap.x,snap.y)


## returns the global position of the player
func get_player_position() -> Vector2:
	return Vector2(player_position[0],player_position[1])

## returns the global position of the player
func get_astral_position() -> Vector2:
	return astral_position

## returns the camera snap axis of the player
func get_player_camera() -> Vector2:
	return Vector2(player_position[2],player_position[3])

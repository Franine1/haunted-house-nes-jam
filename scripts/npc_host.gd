## This is the script for the NPC inviting the player to
## their house. 
extends NPC

var cue: GameCue



func ready_behavior() -> void:
	cue = GameCue.new()
	add_child(cue)
	
	cue.add_cue("host",host_cue)


func process_behavior(delta: float) -> void:
	if [-4,-5].has(game_data.get_data("forced")) and game_data.get_data("host") != 2:
		global_position = Vector2(72.0,24.0)

func host_cue(input: int) -> void:
	
	match input:
		1:
			global_position = Vector2(216.0,88.0)

func interact(by: Player) -> void:
	if interact_allowed:
		movement_queue.append(CutscenePath.compile_look_direction(by.global_position - global_position))
		send_dialogue()

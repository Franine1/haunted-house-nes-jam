## This is the script for the NPC inviting the player to
## their house. 
extends NPC

var cue: GameCue



func ready_behavior() -> void:
	cue = GameCue.new()
	add_child(cue)
	
	cue.add_cue("host",host_cue)


func host_cue(input: int) -> void:
	
	match input:
		1:
			global_position = Vector2(216.0,88.0)

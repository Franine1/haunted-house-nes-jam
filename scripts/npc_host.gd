## This is the script for the NPC inviting the player to
## their house. 
extends NPC

var cue: GameCue

@export_range(0.0,1.0) var opacity_max: float = 1.0

func ready_behavior() -> void:
	cue = GameCue.new()
	add_child(cue)
	
	cue.add_cue("host",host_cue)


func process_behavior(_delta: float) -> void:
	if [-4,-5].has(game_data.get_data("forced")) and game_data.get_data("host") != 2:
		global_position = Vector2(88.0,120.0)
	elif [3,6].has(game_data.get_data("host")):
		global_position = Vector2(-1440.0,-16.0)
	elif game_data.get_data("host") == 4:
		global_position = Vector2(232.0,40.0)
		

func host_cue(input: int) -> void:
	
	match input:
		1:
			global_position = Vector2(232.0,184.0)
		3:
			global_position = Vector2(-1440.0,-16.0)
		6:
			global_position = Vector2(-1440.0,-16.0)
		7:
			global_position = Vector2(1684.0,-988.0)
			turn(Vector2.LEFT)

func interact(by: Player) -> void:
	if interact_allowed:
		movement_queue.append(CutscenePath.compile_look_direction(by.global_position - global_position))
		send_dialogue()



func progress_animation(delta: float, opacity: float = -1.0) -> void:
	
	var do_opacity: bool = opacity >= 0.0
	var result_opacity: float = opacity if do_opacity else 1.0
	
	result_opacity *= opacity_max
	
	# ensure the character is visible
	for sprite in sprites:
		if sprite.material is ShaderMaterial:
			sprite.material.set_shader_parameter("opacity",result_opacity)
			sprite.material.set_shader_parameter("opacity_enabled",do_opacity)
	
	# determine the correct frame in our animation
	if walk_time <= 0.0:
		walk_time = 0.0
		for sprite in sprites:
			sprite.frame = 0
	else:
		walk_time -= delta
		const anim_speed = 0.9
		for sprite in sprites:
			sprite.frame = (floori((initial_walk_time - walk_time)*speed_scale * anim_speed) % 2) + 1

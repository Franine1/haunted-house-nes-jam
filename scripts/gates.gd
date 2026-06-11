extends Blockade



func update_activity() -> void:
	active = (compare_type == compare.ALWAYS)
	if (game_data.get_data(cue) == value):
		active = active or [compare.EQUAL,compare.LESS_OR_EQUAL,compare.GREATER_OR_EQUAL].has(compare_type)
	else:
		active = active or [compare.NOT_EQUAL].has(compare_type)
	if (game_data.get_data(cue) < value):
		active = active or [compare.LESS,compare.LESS_OR_EQUAL].has(compare_type)
	if (game_data.get_data(cue) > value):
		active = active or [compare.GREATER,compare.GREATER_OR_EQUAL].has(compare_type)
		
	
	active = active and (game_data.get_data("hide_color_gates") == 0)


## overridden
func progress_animation(_delta: float, opacity: float = -1.0) -> void:
	
	var do_opacity: bool = (opacity >= 0.0) and ![mode.ALWAYS,mode.WHILE_ACTIVE].has(visibility_type)
	do_opacity = do_opacity and !(visibility_type == mode.ROOM_VISIBLE_OR_ACTIVE and active)
	var result_opacity: float = opacity if do_opacity else 1.0
	if !active and [mode.WHILE_ACTIVE,mode.ROOM_VISIBLE_AND_ACTIVE].has(visibility_type):
		result_opacity = 0.33
	
	# ensure the blockade is visible
	for sprite in sprites:
		if sprite.material is ShaderMaterial:
			sprite.material.set_shader_parameter("opacity",result_opacity)
	
	if false:
		print(str(fade_in_checks.size()) + " | " + str(result_opacity))

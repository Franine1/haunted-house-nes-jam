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

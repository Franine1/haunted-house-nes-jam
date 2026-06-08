extends InteractionZone





func _process(delta: float) -> void:
	var best: float = 0.0 if fade_in_checks.size() > 0 else 1.0
	for layout in fade_in_checks:
		if layout.overlaps(self):
			best = max(best,layout.recent_opacity)
	
	if (game_data.get_data("hide_color_gates") != 0):
		best = 0.0
	
	progress_animation(delta, best)

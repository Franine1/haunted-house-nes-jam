extends NPC


var cue: GameCue
var player_target: Player = null
var do_warp: bool = false


## Changes its interaction ray into a scanner for if the player can leave the boat.
## Sets up cues and correctly interprets its position from game data.
func ready_behavior() -> void:
	interaction.target_position = Vector2(32.0,0.0)
	interaction.collision_mask = 128
	
	cue = GameCue.new()
	add_child(cue)
	
	var temp: Vector2i = get_pos_data(global_position)
	
	
	if game_data.get_data("in_boat") == 0:
		if game_data.has_data("boat_x"):
			temp.x = game_data.get_data("boat_x")
		if game_data.has_data("boat_y"):
			temp.y = game_data.get_data("boat_y")
	else:
		do_warp = true
		global_position = game_data.get_player_position()
	
	set_pos_data(temp)
	
	cue.add_cue("boat_cutscene",boat_cutscene)
	cue.add_cue("in_boat",boat_leave_or_enter)
	finished_movement.connect(exit_mode_changed)
	

## activates when the boat is supposed to move on its own
func boat_cutscene(input: int) -> void:
	
	if input > 0:
		send_dialogue()

## Used to order the boat to update its position when exiting the
## game becomes allowed
func exit_mode_changed() -> void:
	game_data.set_data("exit_banned",0)
	game_data.set_data("boat_cutscene",0)
	update_position()

## Used to get the player to enter or leave the boat
func boat_leave_or_enter(input: int) -> void:
	if input == 0:
		pass
	elif input == -1:
		interaction.rotation = player_target.interaction.rotation
		interaction.force_raycast_update()
		if !interaction.is_colliding() and false:
			interaction.rotate(PI)
			interaction.force_raycast_update()
		var able = interaction.is_colliding()
		if able:
			game_data.set_data("in_boat",0)
			player_target.global_position = interaction.target_position.rotated(interaction.rotation) + global_position
			update_position()
	else:
		player_target.global_position = global_position
	
	
	do_warp = (input != 0)


## Scans for the player, and if the player is in the boat,
## follow their position
func process_behavior(_delta: float) -> void:
	collision_mask = 0
	
	for body in $player_scan.get_overlapping_bodies():
		if body is Player:
			player_target = body
	
	
	if game_data.get_data("in_boat") != 0 and do_warp:
		global_position = game_data.get_player_position()


## Snaps the position correctly into the world
func correct_position() -> void:
	if game_data.get_data("in_boat") == 0:
		global_position = (16.0 * ((global_position-Vector2(8.0,8.0))/16.0).round()) + Vector2(8.0,8.0)

## Updates the game data's version of its position
func update_position() -> void:
	var temp: Vector2i = get_pos_data(global_position)
	game_data.set_data("boat_x",temp.x)
	game_data.set_data("boat_y",temp.y)

## Gets the player upon interaction
func interact(by: Player) -> void:
	player_target = by
	if interact_allowed:
		send_dialogue()

## returns a suitable vector2i to send to game data
func get_pos_data(input: Vector2) -> Vector2i:
	var ans: Vector2 = (input-Vector2(8.0,8.0))/16.0
	ans = ans.round()
	
	return Vector2i(ans)

## sets positioning based on an input vector2i
func set_pos_data(input: Vector2i) -> void:
	global_position = Vector2(8.0,8.0) + Vector2(input * 16)
	update_position()

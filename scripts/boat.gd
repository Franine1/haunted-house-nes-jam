extends NPC


var cue: GameCue
var player_target: Player = null
var do_warp: bool = false
var refresh_spot: bool = false
const checks: Array[String] = ["spot1","spot2","spot3","spot4"]

## Changes its interaction ray into a scanner for if the player can leave the boat.
## Sets up cues and correctly interprets its position from game data.
func ready_behavior() -> void:
	reset_interaction()
	
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
	cue.add_cue("spot1",check_spots.bind(0))
	cue.add_cue("spot2",check_spots.bind(1))
	cue.add_cue("spot3",check_spots.bind(2))
	cue.add_cue("spot4",check_spots.bind(3))
	finished_movement.connect(exit_mode_changed)


## resets the interaction ray to the default
func reset_interaction() -> void:
	interaction.target_position = Vector2(32.0,0.0)
	interaction.collision_mask = 128
	interaction.rotation = 0

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
			
			for i in range(checks.size()):
				game_data.set_data(checks[i],0)
			refresh_spot = true
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


## Determines whether or not the boat can go to a set spot
func check_spots(input: int, source: int) -> void:
	if input != 1:
		return
	if game_data.get_data("boat_cutscene") != 0:
		return
	if refresh_spot:
		game_data.set_data("spot",source)
		refresh_spot = false
	
	
	const y_checks: Array[float] = [-920.0,-968.0,-1016.0,-1064.0]
	
	reset_interaction()
	interaction.collision_mask = 33
	

	for i in range(4):
		if i != source:
			game_data.set_data(checks[i],0)
	
	if source != game_data.get_data("spot"):
		if game_data.get_data(checks[source]) == 1:
			interaction.target_position = Vector2(0.0,y_checks[source]-y_checks[game_data.get_data("spot")])
			interaction.force_raycast_update()
			if interaction.is_colliding():
				game_data.set_data(checks[source],0)
			else:
				game_data.set_data(checks[source],2)
				game_data.set_data("spot",source)
				game_data.set_data("exit_banned",1)
				game_data.set_data("boat_cutscene",3)
	
	reset_interaction()
	

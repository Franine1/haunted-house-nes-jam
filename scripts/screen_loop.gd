class_name ScreenLoop
extends ReflectionZone



const game_data: GameData = preload("res://resources/game data/gameData.tres")

var previous_RID: RID
var reusable_timer: Timer
var rid_usable: bool = true

func reflect(_input: int) -> void:
	pass


func ready_behavior() -> void:
	reusable_timer = Timer.new()
	add_child(reusable_timer)
	reusable_timer.one_shot = true
	reusable_timer.timeout.connect(clear_rid)
	
	body_shape_entered.connect(scan_bodies.unbind(4))
	pass


func clear_rid() -> void:
	rid_usable = true


func enforce_distances(_player_container: PlayerContainer, active_player: Player, _inactive_player: Player):
	
	if !rid_usable and previous_RID.is_valid() and previous_RID == active_player.get_rid():
		return
	
	rid_usable = false
	
	previous_RID = active_player.get_rid()
	
	var source_pos: Vector2 = active_player.final_position() / 16.0
	source_pos += 0.5 * Vector2.ONE
	
	var final: Vector2 = reflect_point(source_pos)
	
	reusable_timer.start(0.1)
	
	active_player.global_position += final * 16
	
	var plr_spd: float = active_player.default_speed
	
	var path: CutscenePath = CutscenePath.compile([Vector2i(active_player.facing_direction())],plr_spd)
	
	set_input_allowed(active_player,false)
	
	
	
	get_tree().create_timer(1.0 / plr_spd).timeout.connect(player_set_input_allowed.bind(active_player,true))
	
	game_data.queue_movement(path,-1)



func set_input_allowed(target: Player, value: bool) -> void:
	target.input_allowed = value



func player_set_input_allowed(target: Player, value: bool) -> void:
	set_input_allowed(target, value)
	if target.finished_movement.is_connected(player_set_input_allowed):
		target.finished_movement.disconnect(player_set_input_allowed)

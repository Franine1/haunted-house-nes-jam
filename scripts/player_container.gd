## The PlayerContainer is used to store both the player and
## the player camera. It's used to prevent them moving with each other.
class_name PlayerContainer
extends Node2D

@onready var pl: Player = %Player
@onready var ast: Player = %astral_projection
@onready var cm: Camera2D = %Camera2D
@onready var shadow: AnimatedSprite2D = %shadow
var cue: GameCue
@export var camera_snap_axis: Vector2 = Vector2.ZERO:
	set(value):
		camera_snap_axis = value
		if is_node_ready():
			set_snap_axis(camera_snap_axis)
@export var speed_scale: float = 5.0:
	set(value):
		speed_scale = value
		if is_node_ready():
			set_speed_scale(speed_scale)

## Whether the player container is initially astral projecting or not
@export var astral_mode: bool = true

@export var astral_version: astral = astral.DEFAULT
	

enum astral {
	DEFAULT
	,POLTERGEIST
	,MIRRORS
}

const game_data: GameData = preload("res://resources/game data/gameData.tres")

signal astral_projection(input: bool, chr: Player)

const astral_offset: Vector2 = Vector2(0.0,8.0)

var astral_recently_enforced: Timer

func _ready() -> void:
	cue = GameCue.new()
	add_child(cue)
	cue.add_cue("restart",restart_puzzle)
	cue.add_cue("restart_ghost",reset_ghost)
	
	astral_recently_enforced = Timer.new()
	add_child(astral_recently_enforced)
	astral_recently_enforced.one_shot = true
	set_snap_axis(camera_snap_axis)
	set_speed_scale(speed_scale)
	astral_mode = (game_data.get_data("astral") <= 0)
	pl.astral_changed.connect(react_to_astral_projection)
	ast.astral_changed.connect(react_to_astral_projection)

	if !astral_mode:
		react_to_astral_projection(false,true)
	else:
		correct_focus()


func set_snap_axis(value: Vector2) -> void:
	if pl != null and pl.is_node_ready():
		pl.camera_snap_axis = value
		pl.fix_camera(true)
	else:
		get_tree().create_timer(0.1).timeout.connect(set_snap_axis.bind(value))

func set_speed_scale(value: float) -> void:
	if pl != null and pl.is_node_ready():
		pl.speed_scale = value
	else:
		get_tree().create_timer(0.1).timeout.connect(set_speed_scale.bind(value))

## ensures we're focused on the correct character
func correct_focus() -> void:
	var chrs: Array[Player] = [pl,ast]
	
	for chr in chrs:
		var enable = (chr.astral_mode == astral_mode)
		
		chr.visible = enable
		chr.toggle = enable
	

## Switches player characters accordingly when the player astral projects
func react_to_astral_projection(input: bool, override: bool = false) -> void:
	
	if input != astral_mode or override:
		astral_mode = input
		
		if game_data.get_data("tooltip") == 4:
			game_data.set_data("tooltip",0)
		
		
		var source: Player = ast if astral_mode else pl
		var endpoint: Player = pl if astral_mode else ast
		
		
		correct_focus()
		
		if astral_mode:
			pass
		else:
			if astral_recently_enforced.is_stopped() and ![astral.MIRRORS].has(astral_version):
				ast.global_position = pl.global_position + (Vector2(16.0,14.0) * 16.0 * astral_offset)
			if [astral.MIRRORS].has(astral_version):
				ast.global_position = shadow.global_position
			
			if [astral.POLTERGEIST].has(astral_version):
				endpoint.turn(source.facing_direction())
		
		
		
		var difference: Vector2 = endpoint.global_position - source.global_position
		endpoint.camera_snap_axis = source.camera_snap_axis
		if !astral_mode and false:
			endpoint.camera_snap_axis = source.camera_snap_axis + difference/16.0 
		
		cm.blackout_transition()
		cm.shift(difference)
		endpoint.finish_camera_glide()
		
		#print([(endpoint.position / Vector2(256.0,224.0)),(source.position / Vector2(256.0,224.0))])
		
		if [astral.MIRRORS].has(astral_version):
			summon_shadow.call_deferred()
		if [astral.POLTERGEIST].has(astral_version):
			summon_shadow.call_deferred(true)
		
		
		
		astral_projection.emit(astral_mode,current_player())

## returns the current player
func current_player(active: bool = true) -> Player:
	if (astral_mode == active):
		return pl
	else:
		return ast

## Forces a certain offset between astral projections
func adjust_player_distances(input: Vector2 = astral_offset) -> void:
	if astral_recently_enforced.time_left > 0.1 and !astral_recently_enforced.is_stopped():
		return # ignore the command
	var difference: Vector2 = (Vector2(16.0,14.0) * 16.0 * input)
	current_player(false).global_position = current_player().global_position + difference
	if astral_mode and false:
		ast.camera_snap_axis = pl.camera_snap_axis + difference/16.0 
	astral_recently_enforced.start(0.2)
	
	
	if [astral.MIRRORS].has(astral_version) and astral_version:
		summon_shadow.call_deferred()
	


func _process(_delta: float) -> void:
	#astral_version = clamp(game_data.get_data("version"),0,astral.keys().size()-1)
	
	var ans: Player.astral = Player.astral.values()[astral_version]
	
	pl.astral_version = ans
	ast.astral_version = ans
	
	if astral_mode:
		shadow.visible = [astral.MIRRORS].has(astral_version)
	else:
		shadow.visible = [astral.POLTERGEIST,astral.MIRRORS].has(astral_version)
	
	pass

## Resets positions of the player and astral projection
func restart_puzzle(input: int = 1) -> void:
	if input != 0:
		cm.blackout_transition()
		pl.global_position = game_data.get_restart_position()
		ast.global_position = game_data.get_ghost_restart_position()
		current_player().finish_camera_glide()
		#react_to_astral_projection(true,true)
		
		summon_shadow()
		
		game_data.set_data("restart",0)
	


func summon_shadow(activity: bool = false) -> void:
	var target: Player = current_player(activity)
	shadow.global_position = target.global_position
	shadow.animation = target.sprites[0].animation


func reset_ghost(input: int = 1) -> void:
	if input != 0:
		game_data.set_data("restart_ghost",0)
		ast.global_position = game_data.get_ghost_restart_position()
		
		summon_shadow()

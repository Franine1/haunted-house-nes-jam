## Blockades are fields on the map that the player cannot enter. 
## They are meant to be given boolean data that determines whether
## or not they are active. You may also set up dialogue that they read
## when interacted with or collided into
class_name Blockade
extends StaticBody2D

@export_category("Interaction Modes")
## Whether you can interact with this with the A action
@export var interact_activation: bool = false
## Whether you can interact with this by colliding with it
@export var collide_activation: bool = false

@export_category("Activation Cue")
@export var cue: String
@export var value: int
## This toggle only activates if the "CUE" is "COMPARE_TYPE" compared to "VALUE".
@export var compare_type: compare = compare.ALWAYS
const game_data: GameData = preload("res://resources/game data/gameData.tres")
var active: bool = false

var interact_allowed: bool = true

@export_category("Visibility")
## Any animated sprites linked to this node
var sprites: Array[CanvasItem]
## Used as a list for NPCs to check for whether to be visible or not
var fade_in_checks: Array[Layout] = []
## used to keep track of the layer this object is in for the color palettes
@export var material_layer: int = 0
## the blockade's visibility mode
@export var visibility_type: mode = mode.ROOM_VISIBLE_AND_ACTIVE


enum mode {
	ALWAYS ## Always visible
	,WHILE_ACTIVE ## Visible if it's cue condition is true
	,WHILE_ROOM_IS_VISIBLE ## Visible if in contact with a visible room
	,ROOM_VISIBLE_AND_ACTIVE ## Visible if both in a visible room and the cue condition is true
	,ROOM_VISIBLE_OR_ACTIVE ## Visible if either in a visible room and the cue condition is true
}

enum compare {
	EQUAL ## The values must be equivalent
	,NOT_EQUAL ## The values must not be equivalent
	,LESS ## The cue must be less than the value
	,GREATER ## The cue must be greater than the value
	,LESS_OR_EQUAL ## The cue must not be greater than the value
	,GREATER_OR_EQUAL ## The cue must not be less than the value
	,ALWAYS ## This blockade is always active
}

## progressess animations and updates activity
func _process(delta: float) -> void:
	update_activity()
	
	collision_layer = 33 if active else 0
	if interact_activation and active:
		collision_layer += 8
	collision_mask = 2
	
	
	var best: float = 0.0 if fade_in_checks.size() > 0 else 1.0
	for layout in fade_in_checks:
		if layout.overlaps(self):
			best = max(best,layout.recent_opacity)
	progress_animation(delta, best)


## Updates the node's active var
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


## Changes the color scheme of child sprite2Ds accordingly
func change_palette(input: Dictionary[int,ShaderMaterial], clear_non_included: bool = true) -> void:
	for sprite in sprites:
		if input.has(material_layer):
			sprite.material = input[material_layer].duplicate()
			if sprite.material is ShaderMaterial:
				sprite.material.set_shader_parameter("opacity_enabled",true)
		elif clear_non_included:
			sprite.material = null
	


## when the player presses A on it, sends its dialogue if interact_Activation is true
func interact() -> void:
	if interact_activation and interact_allowed and active:
		send_dialogue()

## Gathers any child Dialogue nodes and queues them up to be read.
func send_dialogue() -> void:
	if !interact_allowed:
		return
	interact_allowed = false
	get_tree().create_timer(0.5).timeout.connect(set_interaction)
	var temp: Array[Dialogue]
	for child in get_children():
		if child is Dialogue:
			temp.append(child.duplicate())
	
	game_data.queue_dialogue_array(temp)
	
## when the player bumps into it, sends its dialogue if collide_Activation is true
func bump(source: NPC = null) -> void:
	if source is Player and collide_activation and interact_allowed and active:
		if source.toggle:
			if source != null:
				source.delay_interaction()
			send_dialogue()

func set_interaction(input: bool = true) -> void:
	interact_allowed = input

func progress_animation(_delta: float, opacity: float = -1.0) -> void:
	
	var do_opacity: bool = (opacity >= 0.0) and ![mode.ALWAYS,mode.WHILE_ACTIVE].has(visibility_type)
	do_opacity = do_opacity and !(visibility_type == mode.ROOM_VISIBLE_OR_ACTIVE and active)
	var result_opacity: float = opacity if do_opacity else 1.0
	if !active and [mode.WHILE_ACTIVE,mode.ROOM_VISIBLE_AND_ACTIVE].has(visibility_type):
		result_opacity = 0.0
	
	# ensure the blockade is visible
	for sprite in sprites:
		if sprite.material is ShaderMaterial:
			sprite.material.set_shader_parameter("opacity",result_opacity)
	
	if false:
		print(str(fade_in_checks.size()) + " | " + str(result_opacity))



func _ready() -> void:
	sprites = []
	for child in get_children():
		if child is CanvasItem:
			sprites.append(child)
			child.z_index = 2

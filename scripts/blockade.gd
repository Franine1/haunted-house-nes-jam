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


enum compare {
	EQUAL
	,LESS
	,GREATER
	,LESS_OR_EQUAL
	,GREATER_OR_EQUAL
	,ALWAYS
}

func _process(delta: float) -> void:
	active = (compare_type == compare.ALWAYS)
	if (game_data.get_data(cue) == value):
		active = active or [compare.EQUAL,compare.LESS_OR_EQUAL,compare.GREATER_OR_EQUAL].has(compare_type)
	if (game_data.get_data(cue) < value):
		active = active or [compare.LESS,compare.LESS_OR_EQUAL].has(compare_type)
	if (game_data.get_data(cue) > value):
		active = active or [compare.GREATER,compare.GREATER_OR_EQUAL].has(compare_type)
	
	collision_layer = 1 if active else 0
	if interact_activation:
		collision_layer += 8
	collision_mask = 0

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
			temp.append(child)
	
	game_data.queue_dialogue_array(temp)
	
## when the player bumps into it, sends its dialogue if collide_Activation is true
func bump(source: Player = null) -> void:
	if collide_activation and interact_allowed and active:
		if source != null:
			source.delay_interaction()
		send_dialogue()

func set_interaction(input: bool = true) -> void:
	interact_allowed = input

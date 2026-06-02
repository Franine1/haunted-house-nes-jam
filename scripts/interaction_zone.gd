## Interaction zones are invisible, non-physical areas
## That can be interacted with either by walking into them
## Or pressing the interact button while looking at them. They
## can already perform any action with DialogueCues, so all they
## do is queue up their child Dialogue nodes to either create dialogue
## or change any variable in the GameData. 
class_name InteractionZone
extends Area2D
## Whether or not the player can interact to activate it
@export var interact_activation: bool = true
## Whether or not the player cen enter to activate it
@export var entry_activation: bool = false
## Set to a negative number if there is no interaction limit
@export var max_interactions: int = -1
var interactions: int = 0
var interact_allowed: bool = true

## path to the GameData resource
const game_data: GameData = preload("res://resources/game data/gameData.tres")



## when the player presses A on it, sends its dialogue if interact_Activation is true
func interact() -> void:
	if interact_activation and interact_allowed and (max_interactions < 0 or interactions < max_interactions):
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
	
	interactions += 1

func _ready() -> void:
	# overrides its collision layer and collision mask,
	# and connects player collisions to the detected_player
	# function.
	body_shape_entered.connect(detected_player.unbind(2))
	collision_layer = 8
	collision_mask = 4

## when the player walks into it, send its dialogue if entry_activation is true
func detected_player(body_rid: RID, body: Node2D) -> void:
	if entry_activation and interact_allowed and (max_interactions < 0 or interactions < max_interactions):
		send_dialogue()

func set_interaction(input: bool = true) -> void:
	interact_allowed = input

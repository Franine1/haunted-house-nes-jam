class_name InteractionZone
extends Area2D
## Whether or not the player can interact to activate it
@export var interact_activation: bool = true
## Whether or not the player cen enter to activate it
@export var entry_activation: bool = false
## Set to a negative number if there is no interaction limit
@export var max_interactions: int = -1
var interactions: int = 0

const game_data: GameData = preload("res://resources/game data/gameData.tres")




func interact() -> void:
	if interact_activation and (max_interactions < 0 or interactions < max_interactions):
		send_dialogue()

func send_dialogue() -> void:
	var temp: Array[Dialogue]
	for child in get_children():
		if child is Dialogue:
			temp.append(child)
	
	game_data.queue_dialogue_array(temp)
	
	interactions += 1

func _ready() -> void:
	body_shape_entered.connect(detected_player.unbind(2))
	collision_layer = 8
	collision_mask = 4

func detected_player(body_rid: RID, body: Node2D) -> void:
	if entry_activation and (max_interactions < 0 or interactions < max_interactions):
		send_dialogue()

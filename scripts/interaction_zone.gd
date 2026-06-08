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

## DEPRECATED: These two values are not advised to use since
## They reset if the level changes
var interactions: int = 0
var interact_allowed: bool = true

## path to the GameData resource
const game_data: GameData = preload("res://resources/game data/gameData.tres")

## Any animated sprites linked to this node
var sprites: Array[CanvasItem]
## Used as a list for NPCs to check for whether to be visible or not
var fade_in_checks: Array[Layout] = []
## used to keep track of the layer this object is in for the color palettes
@export var material_layer: int = 0


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
	collision_layer = 40 if interact_activation else 32
	collision_mask = 6
	
	
	sprites = []
	for child in get_children():
		if child is CanvasItem:
			sprites.append(child)
			child.z_index = 3

## when the player walks into it, send its dialogue if entry_activation is true
func detected_player(_body_rid: RID, body: Node2D) -> void:
	if entry_activation and interact_allowed and body is Player and (max_interactions < 0 or interactions < max_interactions):
		send_dialogue()

func set_interaction(input: bool = true) -> void:
	interact_allowed = input


func progress_animation(_delta: float, opacity: float = -1.0) -> void:
	
	var do_opacity: bool = opacity >= 0.0
	var result_opacity: float = opacity if do_opacity else 1.0
	if !monitoring:
		result_opacity = 0.0
	# ensure the blockade is visible
	for sprite in sprites:
		if sprite.material is ShaderMaterial:
			sprite.material.set_shader_parameter("opacity",result_opacity)
	
	if false:
		print(str(fade_in_checks.size()) + " | " + str(result_opacity))


func _process(delta: float) -> void:
	var best: float = 0.0 if fade_in_checks.size() > 0 else 1.0
	for layout in fade_in_checks:
		if layout.overlaps(self):
			best = max(best,layout.recent_opacity)
	progress_animation(delta, best)


func change_palette(input: Dictionary[int,ShaderMaterial], clear_non_included: bool = true) -> void:
	for sprite in sprites:
		if input.has(material_layer):
			sprite.material = input[material_layer].duplicate()
			if sprite.material is ShaderMaterial:
				sprite.material.set_shader_parameter("opacity_enabled",true)
		elif clear_non_included:
			sprite.material = null
	

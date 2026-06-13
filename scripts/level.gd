## A level is meant to contain a collection of rooms and a player.
## Portals and interaction zones are also expected to be children
## of the currently active level and would be managed by it.
## Levels should perform any logic that does not persist between
## Level transitions.
class_name Level
extends Node2D

@export var default_palette: Dictionary[int,ShaderMaterial] = {}



func _ready() -> void:
	get_tree().create_timer(0.01).timeout.connect(distribute_palette.bind(default_palette))
	pass

func distribute_palette(input: Dictionary[int,ShaderMaterial], clear_non_included: bool = true) -> void:
	var reflections: Array[ReflectionZone] = []
	var mirrors: Array[Mirror] = []
	
	for child in get_children():
		if child is Layout:
			child.change_palette(input, clear_non_included)
		elif child is Room:
			child.distribute_palette(input, clear_non_included)
		elif child is Blockade:
			child.change_palette(input,clear_non_included)
		elif child is InteractionZone:
			child.change_palette(input,clear_non_included)
		
		if child is ReflectionZone:
			reflections.append(child)
		if child is Mirror:
			mirrors.append(child)
	
	
	for reflection in reflections:
		for mirror in mirrors:
			if !mirror.request_reflection.is_connected(reflection.reflect):
				mirror.request_reflection.connect(reflection.reflect)

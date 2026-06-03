## A room is meant to batch multiple layouts into the same
## show area. Any layouts that could potentially have different
## palettes, positions, or anything else but should show and
## hide at the same time should be in the same room.
## One useful application is when teleporting the player to an
## identical room, if they are both considered the same "room" 
## then they will show and hide together.
class_name Room
extends Area2D

@export var initial_fade_mode: bool = false
@export var show_layer: int = 0

func _ready() -> void:
	##for child in get_children():
	##	if child is Layout:
	##		child.instant_fade.call_deferred(initial_fade_mode)
	##		child.set_show_area.call_deferred(self)
	
	collision_layer = 2
	collision_mask = 4
	z_index = show_layer

func distribute_palette(input: Dictionary[int,ShaderMaterial], clear_non_included: bool = true) -> void:
	for child in get_children():
		if child is Layout:
			child.change_palette(input, clear_non_included)

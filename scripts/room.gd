class_name Room
extends Area2D

@export var initial_fade_mode: bool = false
@export var show_layer: int = 0

func _ready() -> void:
	for child in get_children():
		if child is Layout:
			child.instant_fade.call_deferred(initial_fade_mode)
			child.set_show_area.call_deferred(self)
	
	collision_layer = 2
	collision_mask = 4
	z_index = show_layer

func distribute_palette(input: Dictionary[int,ShaderMaterial], clear_non_included: bool = true) -> void:
	for child in get_children():
		if child is Layout:
			child.change_palette(input, clear_non_included)

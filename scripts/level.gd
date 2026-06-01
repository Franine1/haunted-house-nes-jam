class_name Level
extends Node2D

@export var default_palette: Dictionary[int,ShaderMaterial] = {}



func _ready() -> void:
	get_tree().create_timer(0.1).timeout.connect(distribute_palette.bind(default_palette))
	pass

func distribute_palette(input: Dictionary[int,ShaderMaterial], clear_non_included: bool = true) -> void:
	for child in get_children():
		if child is Room:
			child.distribute_palette(input, clear_non_included)

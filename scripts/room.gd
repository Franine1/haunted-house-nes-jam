class_name Room
extends Area2D

@export var initial_fade_mode: bool = false

func _ready() -> void:
	for child in get_children():
		if child is Layout:
			child.instant_fade.call_deferred(initial_fade_mode)
			child.set_show_area.call_deferred(self)

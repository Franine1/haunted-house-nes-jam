class_name PlayerContainer
extends Node2D

@onready var pl: Player = %Player
@export var camera_snap_axis: Vector2 = Vector2.ZERO:
	set(value):
		camera_snap_axis = value
		if is_node_ready():
			set_snap_axis(camera_snap_axis)


func _ready() -> void:
	set_snap_axis(camera_snap_axis)

func get_player() -> Player:
	return pl

func set_snap_axis(value: Vector2) -> void:
	if pl != null and pl.is_node_ready():
		print(value)
		pl.camera_snap_axis = value
	else:
		print("fail")
		get_tree().create_timer(0.1).timeout.connect(set_snap_axis.bind(value))

#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("A button"):
	#	camera_snap_axis += Vector2.ONE

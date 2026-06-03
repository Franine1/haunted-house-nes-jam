## The PlayerContainer is used to store both the player and
## the player camera. It's used to prevent them moving with each other.
class_name PlayerContainer
extends Node2D

@onready var pl: Player = %Player
@onready var cm: Camera2D = %Camera2D
@export var camera_snap_axis: Vector2 = Vector2.ZERO:
	set(value):
		camera_snap_axis = value
		if is_node_ready():
			set_snap_axis(camera_snap_axis)
@export var speed_scale: float = 5.0:
	set(value):
		speed_scale = value
		if is_node_ready():
			set_speed_scale(speed_scale)


func _ready() -> void:
	set_snap_axis(camera_snap_axis)
	set_speed_scale(speed_scale)

func get_player() -> Player:
	return pl

func set_snap_axis(value: Vector2) -> void:
	if pl != null and pl.is_node_ready():
		pl.camera_snap_axis = value
		pl.fix_camera(true)
	else:
		get_tree().create_timer(0.1).timeout.connect(set_snap_axis.bind(value))

func set_speed_scale(value: float) -> void:
	if pl != null and pl.is_node_ready():
		pl.speed_scale = value
	else:
		get_tree().create_timer(0.1).timeout.connect(set_speed_scale.bind(value))

#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("A button"):
	#	camera_snap_axis += Vector2.ONE

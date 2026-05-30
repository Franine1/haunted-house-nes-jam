class_name Player
extends CharacterBody2D


var current_axis: Vector2 = Vector2.RIGHT
const SPEED: float = 16.0
@onready var input_delay: Timer = %"input delay"
@export var speed_scale: float = 4.0
var axis_shift: float = 0.0

func _ready() -> void:
	input_delay.one_shot = true
	input_delay.timeout.connect(shift_axis)
	shift_axis()

func _physics_process(delta: float) -> void:
	if input_delay.is_stopped():
		var mvm = Input.get_vector("Move Left","Move Right","Move Up","Move Down")
		if !mvm:
			return
		
		var snapped: Vector2 = mvm.round()
		
		var move: Vector2 = current_axis * snapped
		
		if move.length_squared() <= 0.1:
			shift_axis()
			move = current_axis * snapped
		
		if move.length_squared() <= 0.1:
			move = Vector2.ZERO
		else:
			move = move.normalized()
		
		velocity = move * SPEED * speed_scale
		
		input_delay.start(1.0/speed_scale)
	
	move_and_slide()



func shift_axis() -> void:
	current_axis = (current_axis.orthogonal()).abs()
	position = (16.0 * ((position-Vector2(8.0,8.0))/16.0).round()) + Vector2(8.0,8.0)

class_name Player
extends CharacterBody2D


var current_axis: Vector2 = Vector2.RIGHT
const SPEED: float = 16.0
@onready var input_delay: Timer = %"input delay"
@export var speed_scale: float = 4.0
@export var room_id: String = ""
var axis_shift: float = 0.0
var seamless: bool = false

signal update_fading()

func _ready() -> void:
	input_delay.one_shot = true
	input_delay.timeout.connect(shift_axis)
	shift_axis()
	z_index = 5

#i have no idea what bro was smoking to make this movement code
func _physics_process(delta: float) -> void:
	var direct: int
	if Input.is_action_just_pressed("Move Down"):
		direct = 1
		%playSprite.frame = 0
	if Input.is_action_just_pressed("Move Up"):
		direct = 2
		%playSprite.frame = 3
	if Input.is_action_just_pressed("Move Left"):
		direct = 3
		%playSprite.frame = 6
	if Input.is_action_just_pressed("Move Right"):
		direct = 4
		%playSprite.frame = 9
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
		#match direct:
		#	1:
		#		%playerAnim.play("down")
		#	2:
		#		%playerAnim.play("up")
		#	3:
		#		%playerAnim.play("left")
		#	4:
		#		%playerAnim.play("right")
	move_and_slide()



func shift_axis() -> void:
	current_axis = (current_axis.orthogonal()).abs()
	position = (16.0 * ((position-Vector2(8.0,8.0))/16.0).round()) + Vector2(8.0,8.0)

func seamless_warp() -> void:
	seamless = true
	get_tree().create_timer(0.05).timeout.connect(set_seamless.bind(false))
	update_fading.emit()
	pass

func set_seamless(input: bool) -> void:
	seamless = input
	update_fading.emit()

func get_seamless() -> bool:
	return seamless

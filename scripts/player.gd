class_name Player
extends CharacterBody2D


var current_axis: Vector2 = Vector2.RIGHT
@export var camera_snap_axis: Vector2 = Vector2.ZERO
const SPEED: float = 16.0
@onready var input_delay: Timer = %"input delay"
@onready var camera: Camera2D = %Camera2D
@export var speed_scale: float = 5.0
@export var room_id: String = ""
var axis_shift: float = 0.0
var seamless: bool = false

signal update_fading()

func _ready() -> void:
	input_delay.one_shot = true
	input_delay.timeout.connect(shift_axis)
	shift_axis()
	
	z_index = 5
	seamless_warp()

func _physics_process(delta: float) -> void:
	if input_delay.is_stopped():
		var mvm = Input.get_vector("Move Left","Move Right","Move Up","Move Down")
		if mvm:
		
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
			
		else:
			velocity = Vector2.ZERO
	
	fix_camera()
	move_and_slide()


func fix_camera() -> void:
	var translate: Vector2 = global_position
	translate /= 16.0
	translate -= camera_snap_axis
	translate = Vector2(round(translate.x/16.0),round(translate.y/14.0))
	translate = Vector2(translate.x * 16.0,translate.y * 14.0)
	translate = translate.round()
	translate += camera_snap_axis
	translate *= 16.0
	camera.global_position = translate

func shift_axis() -> void:
	current_axis = (current_axis.orthogonal()).abs()
	global_position = (16.0 * ((global_position-Vector2(8.0,8.0))/16.0).round()) + Vector2(8.0,8.0)

func seamless_warp() -> void:
	seamless = true
	get_tree().create_timer(0.05).timeout.connect(set_seamless.bind(false))
	update_fading.emit()
	pass

func final_position() -> Vector2:
	var ans: Vector2 = (global_position + (velocity * input_delay.time_left))/16.0
	ans = (ans - Vector2(0.5,0.5)).round()
	
	ans *= 16.0
	
	return ans

func teleport(target: Vector2) -> void:
	var difference: Vector2 = target - global_position
	camera_snap_axis += difference/16.0 
	global_position += difference

func set_seamless(input: bool) -> void:
	seamless = input
	update_fading.emit()

func get_seamless() -> bool:
	return seamless

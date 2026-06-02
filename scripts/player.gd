## The player node itself. Not congruent with the player scene.
class_name Player
extends CharacterBody2D

const game_data: GameData = preload("res://resources/game data/gameData.tres")

## Which axis the player will move on if two are pressed at once
var current_axis: Vector2 = Vector2.RIGHT
## The offset for the camera snapping zones
@export var camera_snap_axis: Vector2 = Vector2.ZERO
## The size of a tile to the player
const SPEED: float = 16.0
## Delay between inputs to force the player to wait for the 
## previous input to complete
@onready var input_delay: Timer = %"input delay"
## The camera of the player
@onready var camera: Camera2D = %Camera2D
## The sprite of the player
@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D
## The ray that checks what the player is interacting with
@onready var interaction: RayCast2D = %interaction_ray
## A modifier to the player speed
@export var speed_scale: float = 5.0
## Forces rooms to instantly fade in or out when active
var seamless: bool = false
## Used to determine what frame the animation should be on
var walk_time: float = 0.0
## Used to continue the current animation if the player is holding down a movement direction
var initial_walk_time: float = 0.0

signal update_fading()

func _ready() -> void:
	input_delay.one_shot = true
	input_delay.timeout.connect(shift_axis)
	shift_axis()
	
	z_index = 5
	seamless_warp()
	fix_camera(true)

func _physics_process(delta: float) -> void:
	# determine the correct frame in our animation
	if walk_time <= 0.0:
		walk_time = 0.0
		sprite.frame = 0
	else:
		walk_time -= delta
		const anim_speed = 0.9
		sprite.frame = (floori((initial_walk_time - walk_time)*speed_scale * anim_speed) % 2) + 1
	
	
	if input_delay.is_stopped():
		# movement inputs are allowed
		correct_position()
		
		var mvm = Input.get_vector("Move Left","Move Right","Move Up","Move Down")
		if mvm:
			# rounds all components of the movement vector
			var snapped: Vector2 = mvm.round()
			
			# snaps the vector to the currect axis
			var move: Vector2 = current_axis * snapped
			
			var axis_swapped: bool = false
			
			if move.length_squared() <= 0.1:
				# if the axis snapping set movement to 0, snap to the opposite axis instead
				shift_axis()
				axis_swapped = true
				move = current_axis * snapped
			
			if move.length_squared() <= 0.1:
				move = Vector2.ZERO
			else:
				move = move.normalized()
			
			# check if our movement will lead to a collision
			var collision: KinematicCollision2D = move_and_collide(move * SPEED, true)
			
			const directions: Dictionary[Vector2,String] = {
				Vector2.LEFT: "left"
				,Vector2.RIGHT: "right"
				,Vector2.UP: "up"
				,Vector2.DOWN: "down"
			}
			
			# set the interaction direction to our movement direction
			interaction.rotation = move.angle()
			
			# skips setting the animation if we move at an angle against a wall
			if directions.has(move) and (axis_swapped or !collision):
				sprite.animation = directions[move]
			
			if collision:
				# don't move if we would have collided
				velocity = Vector2.ZERO
				shift_axis()
			else:
				# move if the target position is free
				velocity = move * SPEED * speed_scale
				var dur: float = 1.0/speed_scale
				if walk_time <= 0:
					initial_walk_time = dur + 0.04
				else:
					initial_walk_time += dur
				walk_time = dur + 0.04
				input_delay.start(dur)
			
			
			
		else:
			# if we aren't moving, allow the player to interact
			velocity = Vector2.ZERO
			if Input.is_action_just_pressed("A button"):
				if interaction.is_colliding():
					var target = interaction.get_collider()
					if target is InteractionZone:
						target.interact()
						toggle_interaction(false)
						get_tree().create_timer(0.5).timeout.connect(toggle_interaction.bind(true))
			
	
	fix_camera()
	move_and_slide()

## toggles interaction
func toggle_interaction(mode: bool = !interaction.enabled) -> void:
	interaction.enabled = mode

## Ensures the camera is snapped in the proper room space
func fix_camera(instant: bool = false) -> void:
	var translate: Vector2 = global_position
	translate /= 16.0
	translate -= camera_snap_axis
	translate = Vector2(round(translate.x/16.0),round(translate.y/14.0))
	translate = Vector2(translate.x * 16.0,translate.y * 14.0)
	translate = translate.round()
	translate += camera_snap_axis
	translate *= 16.0
	if instant:
		camera.warp(translate)
	elif camera.target != translate:
		camera.glide(translate)

## changes the axis preference when moving at an angle
func shift_axis() -> void:
	current_axis = (current_axis.orthogonal()).abs()
	correct_position()

## Snaps the position correctly into the world
func correct_position() -> void:
	global_position = (16.0 * ((global_position-Vector2(8.0,8.0))/16.0).round()) + Vector2(8.0,8.0)

## forces rooms the player is in to instantly fade in when warping
func seamless_warp() -> void:
	seamless = true
	get_tree().create_timer(0.05).timeout.connect(set_seamless.bind(false))
	update_fading.emit()
	pass

## determines where the player will arrive at when all actions are completed
func final_position() -> Vector2:
	var ans: Vector2 = (global_position + (velocity * input_delay.time_left))/16.0
	ans = (ans - Vector2(0.5,0.5)).round()
	
	ans *= 16.0
	
	return ans

## teleports the player and shifts the camera accordingly
func teleport(target: Vector2) -> void:
	var difference: Vector2 = target - global_position
	camera_snap_axis += difference/16.0 
	camera.shift(difference)
	global_position = target

## changes the value of "seamless"
func set_seamless(input: bool) -> void:
	seamless = input
	update_fading.emit()

## returns the value of seamless
func get_seamless() -> bool:
	return seamless

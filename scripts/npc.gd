## NPC nodes contain movement rules and interaction and collision
## logic that is true for both the player and non player characters.
class_name NPC
extends CharacterBody2D

const game_data: GameData = preload("res://resources/game data/gameData.tres")

## Which axis the character will move on if two are pressed at once
var current_axis: Vector2 = Vector2.RIGHT
## The offset for the camera snapping zones
@export var camera_snap_axis: Vector2 = Vector2.ZERO
## The size of a tile to the character
const SPEED: float = 16.0
## Delay between inputs to force the player to wait for the 
## previous input to complete
var input_delay: Timer
## Cooldown for player interaction
var interact_delay: Timer
## The sprite of the character
var sprite: AnimatedSprite2D
## The ray that checks what the character is interacting with
var interaction: RayCast2D
## A modifier to the player speed
@export var speed_scale: float = 5.0


## the ID the game uses to specifically identify this NPC
@export var NPC_ID: int = 0


## Forces rooms to instantly fade in or out when active
var seamless: bool = false
## Used to determine what frame the animation should be on
var walk_time: float = 0.0
## Used to continue the current animation if the character is holding down a movement direction
var initial_walk_time: float = 0.0

var input_allowed: bool = true
## list of movements to perform
var movement_queue: Array[Vector2i] = []


signal update_fading()

func _ready() -> void:
	interaction = RayCast2D.new()
	interaction.target_position = Vector2(16.0,0.0)
	add_child(interaction)
	interaction.collide_with_areas = true
	interaction.collision_mask = 8
	
	input_delay = Timer.new()
	input_delay.one_shot = true
	add_child(input_delay)
	interact_delay = Timer.new()
	interact_delay.one_shot = true
	add_child(interact_delay)
	input_delay.timeout.connect(shift_axis)
	interact_delay.timeout.connect(toggle_interaction.bind(true))
	shift_axis()
	
	sprite = AnimatedSprite2D.new()
	add_child(sprite)
	for child in get_children():
		if child is AnimatedSprite2D:
			remove_child(sprite)
			sprite.queue_free()
			sprite = child
			break
	
	z_index = 5
	interaction.rotation = PI/2
	

func progress_animation(delta: float) -> void:
	# ensure the character is visible
	if material is ShaderMaterial:
		material.set_shader_parameter("opacity",1.0)
		material.set_shader_parameter("opacity_enabled",false)
	
	# determine the correct frame in our animation
	if walk_time <= 0.0:
		walk_time = 0.0
		sprite.frame = 0
	else:
		walk_time -= delta
		const anim_speed = 0.9
		sprite.frame = (floori((initial_walk_time - walk_time)*speed_scale * anim_speed) % 2) + 1


func _physics_process(delta: float) -> void:
	collision_layer = 0
	collision_mask = 5
	interact_delay.paused = !input_allowed
	
	
	
	progress_animation(delta)
	
	if input_delay.is_stopped():
		# movement inputs are allowed
		correct_position()
		
		var mvm = movement_queue.front() if movement_queue.size() > 0 else Vector2.ZERO
		if mvm:
			
			var reduce: Vector2i = enact_movement(mvm)
			
			movement_queue[0] -= reduce
			
			if !movement_queue[0]:
				movement_queue.pop_front()
			
		else:
			# if we aren't moving, allow the player to interact
			velocity = Vector2.ZERO
	
	
	move_and_slide()


func enact_movement(mvm: Vector2) -> Vector2i:
	# rounds all components of the movement vector
	var snapped: Vector2 = mvm.normalized().round()
	
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
		var wall = collision.get_collider()
		if wall is Blockade:
			wall.bump(self)
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
	
	var ans: Vector2i = Vector2i(velocity)
	return ans



## toggles interaction
func toggle_interaction(mode: bool = !interaction.enabled) -> void:
	interaction.enabled = mode


## changes the axis preference when moving at an angle
func shift_axis() -> void:
	current_axis = (current_axis.orthogonal()).abs()
	correct_position()


## Snaps the position correctly into the world
func correct_position() -> void:
	global_position = (16.0 * ((global_position-Vector2(8.0,8.0))/16.0).round()) + Vector2(8.0,8.0)




## determines where the character will arrive at when all actions are completed
func final_position() -> Vector2:
	var ans: Vector2 = (global_position + (velocity * input_delay.time_left))/16.0
	ans = (ans - Vector2(0.5,0.5)).round()
	
	ans *= 16.0
	
	return ans


func delay_interaction() -> void:
	if interaction:
		toggle_interaction(false)
		interact_delay.start(0.25)

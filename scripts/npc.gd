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
var sprites: Array[AnimatedSprite2D]
## The ray that checks what the character is interacting with
var interaction: RayCast2D
## A modifier to the player speed
var speed_scale: float = 5.0
## An exported default speed value for NPCs
@export var default_speed: float = 5.0

## the ID the game uses to specifically identify this NPC
@export var NPC_ID: int = 0


## Forces rooms to instantly fade in or out when active
var seamless: bool = false
## Used to determine what frame the animation should be on
var walk_time: float = 0.0
## Used to continue the current animation if the character is holding down a movement direction
var initial_walk_time: float = 0.0
## Used as a list for NPCs to check for whether to be visible or not
var fade_in_checks: Array[Layout] = []

var input_allowed: bool = true
## list of movements to perform
var movement_queue: Array[CutscenePath] = []
## current mode of movement. Makes movement look uglier but better at arriving.
var movement_mode_switch: bool = false


## NPC specific variable determining if the player can interact with them
var interact_allowed: bool = true


signal update_fading()

func _ready() -> void:
	interaction = RayCast2D.new()
	interaction.target_position = Vector2(16.0,0.0)
	add_child(interaction)
	interaction.collide_with_areas = true
	interaction.collision_mask = 24
	
	input_delay = Timer.new()
	input_delay.one_shot = true
	add_child(input_delay)
	interact_delay = Timer.new()
	interact_delay.one_shot = true
	add_child(interact_delay)
	input_delay.timeout.connect(shift_axis)
	interact_delay.timeout.connect(toggle_interaction.bind(true))
	shift_axis()
	
	sprites = []
	for child in get_children():
		if child is AnimatedSprite2D:
			sprites.append(child)
	
	z_index = 5
	interaction.rotation = PI/2
	
	ready_behavior()

## Used to add logic after _ready without overriding important behavior
func ready_behavior() -> void:
	pass


## Used to add logic during _physics_process without overriding important behavior
func process_behavior(_delta: float) -> void:
	pass


func set_interaction(input: bool = true) -> void:
	interact_allowed = input


func interact(_by: Player) -> void:
	if interact_allowed:
		send_dialogue()


## Gathers any child Dialogue nodes and queues them up to be read.
func send_dialogue() -> void:
	if !interact_allowed:
		return
	interact_allowed = false
	get_tree().create_timer(0.5).timeout.connect(set_interaction)
	var temp: Array[Dialogue]
	for child in get_children():
		if child is Dialogue:
			temp.append(child)
	
	game_data.queue_dialogue_array(temp)
	


func progress_animation(delta: float, opacity: float = -1.0) -> void:
	
	var do_opacity: bool = opacity >= 0.0
	var result_opacity: float = opacity if do_opacity else 1.0
	# ensure the character is visible
	for sprite in sprites:
		if sprite.material is ShaderMaterial:
			sprite.material.set_shader_parameter("opacity",result_opacity)
			sprite.material.set_shader_parameter("opacity_enabled",do_opacity)
	
	# determine the correct frame in our animation
	if walk_time <= 0.0:
		walk_time = 0.0
		for sprite in sprites:
			sprite.frame = 0
	else:
		walk_time -= delta
		const anim_speed = 0.9
		for sprite in sprites:
			sprite.frame = (floori((initial_walk_time - walk_time)*speed_scale * anim_speed) % 2) + 1


func upkeep(_delta: float) -> void:
	interact_delay.paused = !input_allowed
	var temp: Array[CutscenePath] = game_data.accept_movement(NPC_ID)
	temp.append_array(movement_queue)
	movement_queue = temp
	
	

func _physics_process(delta: float) -> void:
	collision_layer = 16
	collision_mask = 5
	
	process_behavior(delta)
	
	upkeep(delta)
	
	
	var best: float = 0.0
	for layout in fade_in_checks:
		if layout.overlaps(self):
			best = max(best,layout.recent_opacity)
	progress_animation(delta, best)
	
	if input_delay.is_stopped():
		# movement inputs are allowed
		correct_position()
		
		var mvm = compile_movement_queue()
		
		if !mvm:
			# if we aren't moving, stay still
			velocity = Vector2.ZERO
	
	
	move_and_slide()


func compile_movement_queue() -> Vector2:
	var mvm = Vector2.ZERO
	var dir = Vector2.ZERO
	var local: Vector2i = Vector2i((global_position/16.0).floor())
	var relative_shift: bool = false
	if movement_queue.size() > 0:
		if movement_queue.back().direction(local):
			mvm = Vector2(movement_queue.back().direction(local))
			relative_shift = !movement_queue.back().relative
			dir = movement_queue.back().look_direction
			speed_scale = movement_queue.back().speed
		elif movement_queue.back().look_direction:
			dir = movement_queue.back().look_direction
		else:
			if !movement_queue.back().next_pathway():
				movement_queue.pop_back()
	if mvm or dir:
		
		var reduce: Vector2i = enact_movement(mvm, dir, movement_mode_switch) 
		movement_mode_switch = !reduce
		if relative_shift:
			reduce = local
		
		
		movement_queue.back().reduce(reduce)
	
	return mvm


func enact_movement(mvm: Vector2, dir_override: Vector2 = Vector2.ZERO, accept_any: bool = false) -> Vector2i:
	# rounds all components of the movement vector
	var snap: Vector2
	if accept_any:
		snap = mvm.sign()
	else:
		snap = mvm.normalized().round()
	
	# snaps the vector to the currect axis
	var move: Vector2 = current_axis * snap
	
	var axis_swapped: bool = false
	
	if move.length_squared() <= 0.1:
		# if the axis snapping set movement to 0, snap to the opposite axis instead
		shift_axis()
		axis_swapped = true
		move = current_axis * snap
	
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
	
	
	# skips setting the animation if we move at an angle against a wall
	if (axis_swapped or !collision):
		if directions.has(move):
			for sprite in sprites:
				sprite.animation = directions[move]
			# set the interaction direction to our movement direction
			interaction.rotation = move.angle()
		if directions.has(dir_override):
			for sprite in sprites:
				sprite.animation = directions[dir_override]
			# set the interaction direction to our movement direction
			interaction.rotation = dir_override.angle()
			
	
	
	
	if collision:
		# don't move if we would have collided
		move = Vector2.ZERO
		velocity = Vector2.ZERO
		shift_axis()
		var wall = collision.get_collider()
		if wall is Blockade:
			if input_allowed and wall.collide_activation:
				var temp: Vector2 = (collision.get_position()-global_position).normalized().round()
				if directions.has(temp):
					for sprite in sprites:
						sprite.animation = directions[temp]
					# set the interaction direction to our movement direction
					interaction.rotation = temp.angle()
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
	
	
	var ans: Vector2i = Vector2i(move)
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

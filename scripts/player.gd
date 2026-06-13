## The player node itself. Not congruent with the player scene.
class_name Player
extends NPC


## The camera of the player
@onready var camera: Camera2D = %Camera2D
## Determines if this is the physical player node or the spiritual one
@export var astral_mode: bool = true

## whether or not the camera is teleporting to the player
var camera_instant: bool = false
## Time B button has been held
var projection_time: float = 0.0
## overrride for whether this node is able to interact
var toggle: bool = astral_mode
## Time needed to hold the B button to astral project
const max_projection_time: float = 0.4

var astral_version: astral = astral.DEFAULT
	

enum astral {
	DEFAULT
	,POLTERGEIST
	,MIRRORS
}




signal request_pause()

signal astral_changed(input: bool)


func ready_behavior() -> void:
	toggle = astral_mode


func _physics_process(delta: float) -> void:
	interact_delay.paused = !input_allowed
	
	if astral_mode:
		game_data.accept_player_position(global_position,camera_snap_axis)
	else:
		game_data.accept_astral_position(global_position,camera_snap_axis)
		
	
	
	progress_animation(delta)
	
	var has_moved: bool = false
	
	var increasing_projection_time: bool = false
	
	var stagnant: bool = false
	
	match astral_version:
		astral.POLTERGEIST:
			stagnant = !toggle
		astral.MIRRORS:
			stagnant = !toggle
	
	if input_delay.is_stopped() and !stagnant:
		
		upkeep(delta)
		
		# movement inputs are allowed
		correct_position()
		
		var mvm: Vector2 = Input.get_vector("Move Left","Move Right","Move Up","Move Down")
		if !input_allowed:
			mvm = compile_movement_queue()
		else:
			if movement_queue.size() > 0 and false:
				get_tree().create_timer(0.1).timeout.connect(erase_movement_queue_attempt)
			
			speed_scale = default_speed
			
			if mvm:
				has_moved = (enact_movement(mvm) != Vector2i.ZERO)
			
		if !mvm:
			# if we aren't moving, allow the player to interact
			velocity = Vector2.ZERO
		if input_allowed and toggle and interact_delay.is_stopped() and !has_moved:
			if Input.is_action_just_pressed("A button"):
				erase_movement_queue_attempt()
				if interaction.is_colliding():
					var target = interaction.get_collider()
					if target is InteractionZone:
						target.interact()
						delay_interaction()
					elif target is Blockade:
						target.interact()
						delay_interaction()
					elif target is Player:
						pass
					elif target is NPC:
						target.interact(self)
						
						delay_interaction()
			elif Input.is_action_just_pressed("Start button"):
				if game_data.get_data("exit_banned") == 0:
					request_pause.emit()
					delay_interaction()
			elif Input.is_action_pressed("B button"):
				increasing_projection_time = true
	
	if increasing_projection_time:
		projection_time += delta
		if projection_time >= max_projection_time:
			projection_time = 0.0
			var last_astral = game_data.get_data("astral")
			if last_astral == 2:
				game_data.add_tooltip(15,5.0,self)
			game_data.set_data("astral",swap_astral(last_astral))
			astral_changed.emit((game_data.get_data("astral") <= 0))
	else:
		projection_time = clamp(projection_time - delta,0.0,max_projection_time)
	
	if toggle:
		fix_camera(camera_instant)
	move_and_slide()


## Ensures the camera is snapped in the proper room space
func fix_camera(instant: bool = false) -> void:
	var transl: Vector2 = global_position
	transl /= 16.0
	transl -= camera_snap_axis
	transl = Vector2(round(transl.x/16.0),round(transl.y/14.0))
	transl = Vector2(transl.x * 16.0,transl.y * 14.0)
	transl = transl.round()
	transl += camera_snap_axis
	transl *= 16.0
	if toggle:
		if instant:
			camera.warp(transl)
		elif camera.target != transl:
			camera.glide(transl)


## forces rooms the player is in to instantly fade in when warping
func seamless_warp() -> void:
	seamless = true
	get_tree().create_timer(0.05).timeout.connect(set_seamless.bind(false))
	update_fading.emit()
	pass


## teleports the player and shifts the camera accordingly
func teleport(target: Vector2) -> void:
	var difference: Vector2 = target - global_position
	camera_snap_axis += difference/16.0 
	if toggle:
		camera.shift(difference)
	global_position = target

## changes the value of "seamless"
func set_seamless(input: bool) -> void:
	seamless = input
	update_fading.emit()

## returns the value of seamless
func get_seamless() -> bool:
	return seamless

## allows the camera to temporarily become instant
func finish_camera_glide(input: bool = true) -> void:
	camera_instant = input
	if camera_instant:
		get_tree().create_timer(0.1).timeout.connect(finish_camera_glide.bind(false))


func erase_movement_queue_attempt() -> void:
	if interact_allowed:
		movement_queue.clear()


func swap_astral(input: int) -> int:
	return abs(input) * ((input ** 2) - input - 1)

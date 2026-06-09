## The player node itself. Not congruent with the player scene.
class_name Player
extends NPC


## The camera of the player
@onready var camera: Camera2D = %Camera2D

## whether or not the camera is teleporting to the player
var camera_instant: bool = false

signal request_pause()

func _physics_process(delta: float) -> void:
	
	game_data.accept_player_position(global_position,camera_snap_axis)
	
	upkeep(delta)
	
	progress_animation(delta)
	
	var has_moved: bool = false
	
	if input_delay.is_stopped():
		# movement inputs are allowed
		correct_position()
		
		var mvm: Vector2 = Input.get_vector("Move Left","Move Right","Move Up","Move Down")
		if !input_allowed:
			mvm = compile_movement_queue()
		else:
			speed_scale = default_speed
			
			if mvm:
				has_moved = (enact_movement(mvm) != Vector2i.ZERO)
			
		if !mvm:
			# if we aren't moving, allow the player to interact
			velocity = Vector2.ZERO
		if Input.is_action_just_pressed("A button") and input_allowed and interact_delay.is_stopped() and !has_moved:
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
		elif Input.is_action_just_pressed("Start button") and input_allowed and interact_delay.is_stopped():
			if game_data.get_data("exit_banned") == 0:
				request_pause.emit()
				delay_interaction()
			
	
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

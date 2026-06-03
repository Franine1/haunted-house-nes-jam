## The player node itself. Not congruent with the player scene.
class_name Player
extends NPC


## The camera of the player
@onready var camera: Camera2D = %Camera2D

## whether or not the camera is teleporting to the player
var camera_instant: bool = false

func _physics_process(delta: float) -> void:
	
	upkeep(delta)
	
	progress_animation(delta)
	
	
	if input_delay.is_stopped():
		# movement inputs are allowed
		correct_position()
		
		var mvm: Vector2 = Input.get_vector("Move Left","Move Right","Move Up","Move Down")
		var dir = Vector2.ZERO
		if !input_allowed:
			mvm = Vector2.ZERO
			if movement_queue.size() > 0:
				if movement_queue.back().direction():
					mvm = movement_queue.back().direction()
					dir = movement_queue.back().look_direction
					speed_scale = movement_queue.back().speed
				else:
					movement_queue.pop_back()
		else:
			speed_scale = default_speed
		if mvm:
			
			var reduce: Vector2i = enact_movement(mvm, dir)
			
			if !input_allowed:
				movement_queue.back().reduce(reduce)
			
		else:
			# if we aren't moving, allow the player to interact
			velocity = Vector2.ZERO
			if Input.is_action_just_pressed("A button") and input_allowed and interact_delay.is_stopped():
				if interaction.is_colliding():
					var target = interaction.get_collider()
					if target is InteractionZone:
						target.interact()
						delay_interaction()
					elif target is Blockade:
						target.interact()
						delay_interaction()
						
			
	
	fix_camera(camera_instant)
	move_and_slide()


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

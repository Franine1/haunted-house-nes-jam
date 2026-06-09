extends Camera2D

## emits when the camrea's none travelling, but currently does nothing
signal glide_finished()

## delay after gliding finishes before unpausing
@onready var glide_timer: Timer = %"glide delay"
## The sprite used to black out the screen
@onready var blackout_sprite: Sprite2D = %Sprite2D

var target: Vector2 = Vector2.ZERO:
	set(value):
		target = value
		arrived = false

## Whether or not we are currently at our target position
var arrived: bool = false
## Whether or not the screen is blacked out
var blackout: bool = true

## the delay between pausing the game and starting to glide,
## along with finishing the glide and resuming
const glide_delay: float = 0.15

func _ready() -> void:
	# connects the timer to the try_unpause function
	blackout_transition()
	glide_timer.timeout.connect(try_unpause)


func blackout_transition() -> void:
	blackout_sprite.z_index = 1000
	blackout = true
	get_tree().create_timer(0.1).timeout.connect(set_blackout.bind(false))

## glides to a target position and pauses the game
func glide(t: Vector2 = target) -> void:
	target = t
	glide_timer.start(glide_delay)
	arrived = false

## instantly moves to its target by setting "arrived" to true
func warp(t: Vector2 = target) -> void:
	global_position = t
	target = t
	arrived = true

## modifies its pposition and target to combine cleanly with player teleports
func shift(t: Vector2) -> void:
	global_position += t
	target += t
	arrived = true

func _process(delta: float) -> void:
	var blackout_layer: int = 1000 if blackout else -1000
	blackout_sprite.z_index = blackout_layer
	
	if !arrived:
		# if we're still gliding, then move to the position over time
		get_tree().paused = true
		# screen size times three, so we move three screen lengths a second
		const speed: Vector2 = Vector2(256.0,224.0) * 3.0
		# distance to travel
		var diff: Vector2 = target - global_position
		# divide by speed so it takes the same time for vertical and horizontal transitions
		diff /= speed
		if diff.length_squared() <= (delta ** 2):
			# teleport to the target if it's in range
			glide_timer.start(glide_delay)
			warp(target)
			glide_finished.emit()
		else:
			# glide towards it otherwise
			diff = diff.normalized() * delta
			diff *= speed
			if glide_timer.is_stopped():
				global_position += diff
	else:
		# if we're not gliding, snap onto the target
		global_position = target
	

## Unpauses the game if the camera's at its destination
func try_unpause() -> void:
	if arrived:
		get_tree().paused = false

## Sets the value of blackout
func set_blackout(input: bool) -> void:
	blackout = input

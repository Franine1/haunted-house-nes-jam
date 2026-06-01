extends Camera2D

signal glide_finished()

@onready var glide_timer: Timer = %"glide delay"

var target: Vector2 = Vector2.ZERO:
	set(value):
		target = value
		arrived = false
var arrived: bool = false

const glide_delay: float = 0.15

func _ready() -> void:
	glide_timer.timeout.connect(try_unpause)

func glide(t: Vector2) -> void:
	target = t
	glide_timer.start(glide_delay)
	arrived = false

func warp(t: Vector2) -> void:
	target = t
	arrived = true

func shift(t: Vector2) -> void:
	global_position += t
	target += t
	arrived = true

func _process(delta: float) -> void:
	if !arrived:
		get_tree().paused = true
		const speed: Vector2 = Vector2(256.0,224.0) * 3.0
		var diff: Vector2 = target - global_position
		diff /= speed
		if diff.length_squared() <= (delta ** 2):
			glide_timer.start(glide_delay)
			warp(target)
			glide_finished.emit()
		else:
			diff = diff.normalized() * delta
			diff *= speed
			if glide_timer.is_stopped():
				global_position += diff
	else:
		global_position = target
	

func try_unpause() -> void:
	if arrived:
		get_tree().paused = false

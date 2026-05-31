extends Camera2D

signal glide_finished()

var target: Vector2 = Vector2.ZERO:
	set(value):
		target = value
		arrived = false
var arrived: bool = false

func glide(t: Vector2) -> void:
	target = t
	arrived = false

func warp(t: Vector2) -> void:
	target = t
	arrived = true

func shift(t: Vector2) -> void:
	global_position += t
	target += t

func _process(delta: float) -> void:
	if !arrived:
		
		const speed: Vector2 = Vector2(256.0,224.0) * 3.0
		var diff: Vector2 = target - global_position
		diff /= speed
		if diff.length_squared() <= (delta ** 2):
			warp(target)
			glide_finished.emit()
		else:
			diff = diff.normalized() * delta
			diff *= speed
			global_position += diff
	else:
		global_position = target
	

class_name Layout
extends TileMapLayer

var fade_time: Timer 
@export var fade_mode: bool = false
@export var show_area: Area2D = null:
	set(value):
		if is_instance_valid(show_area) and show_area != null:
			if show_area.body_shape_entered.is_connected(fade):
				show_area.body_shape_entered.disconnect(fade)
			if show_area.body_shape_exited.is_connected(fade):
				show_area.body_shape_exited.disconnect(fade)
		show_area = value
		if is_instance_valid(show_area) and show_area != null:
			show_area.body_shape_entered.connect(fade.bind(true).unbind(4))
			show_area.body_shape_exited.connect(fade.bind(false).unbind(4))
		else:
			fade(false)
const base_time: float = 0.5

func _ready() -> void:
	fade_time = Timer.new()
	fade_time.one_shot = true
	fade_time.wait_time = base_time
	add_child(fade_time)
	fade_time.timeout.connect(on_fadeout)
	if show_area != null:
		set_show_area(show_area)

func _process(delta: float) -> void:
	
	if !fade_time.is_stopped():
		var goal: float = 1.0 if fade_mode else 0.0
		var denom: float = -0.5 if fade_mode else 0.5
		var fadeout: Color = Color(1.0,1.0,1.0,goal + (fade_time.time_left/denom))
		
		modulate = fadeout


func fade(in_or_out: bool) -> void:
	if fade_mode == in_or_out:
		return
	var tt = base_time - fade_time.time_left
	fade_mode = in_or_out
	fade_time.start(tt)

func on_fadeout() -> void:
	var goal: float = 1.0 if fade_mode else 0.0
	modulate = Color(1.0,1.0,1.0,goal)

func set_show_area(input: Area2D = null) -> void:
	show_area = input
	

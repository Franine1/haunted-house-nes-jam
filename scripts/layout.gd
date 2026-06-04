## A Layout is a TileMapLayer with additional code that allows it to
## be shown and hidden with a fadeout and definable show areas, meant
## to be preset pieces that can be connected to create rooms and levels.
class_name Layout
extends TileMapLayer

var fade_time: Timer 
var recent_opacity: float = 1.0
@export var material_layer: int = 0
@export var fade_mode: bool = false
@export var show_area: Area2D = null:
	set(value):
		show_area = value
		if !is_instance_valid(show_area) or show_area != null:
			fade(false)

## This determines how long it takes for layouts and rooms to fade in or out
const base_time: float = 0.25

func _ready() -> void:
	fade_time = Timer.new()
	fade_time.one_shot = true
	fade_time.wait_time = base_time
	add_child(fade_time)
	fade_time.timeout.connect(on_fadeout)
	if show_area != null:
		set_show_area(show_area)
		
	
	
	for child in get_children():
		if child is CanvasItem:
			child.material = child.material.duplicate()
			if child.material is ShaderMaterial:
				material.set_shader_parameter("opacity_enabled",true)

func _process(delta: float) -> void:
	
	if !fade_time.is_stopped():
		var goal: float = 1.0 if fade_mode else 0.0
		var denom: float = -base_time if fade_mode else base_time
		var opacity: float = goal + (fade_time.time_left/denom)
		
		correct_opacity(opacity)
		
		
	
	update_fading_mode()


func update_fading_mode(instant_override: bool = false):
	if is_instance_valid(show_area) and show_area != null:
		var c: Array[Node2D] = show_area.get_overlapping_bodies()
		
		var check: bool = false
		var instant_fading: bool = instant_override and fade_time.is_stopped()
		
		
		for node in c:
			
			
			if node is Player:
				check = true
				if !node.update_fading.is_connected(update_fading_mode):
					node.update_fading.connect(update_fading_mode.bind(true))
			elif node is NPC:
				if !node.update_fading.is_connected(empty_function):
					node.update_fading.connect(empty_function)
					node.fade_in_checks.append(self)
			elif node is Blockade:
				#print("detected blockade")
				if!node.empty_signal.is_connected(empty_function):
					#print("connecting blockade")
					node.empty_signal.connect(empty_function)
					node.fade_in_checks.append(self)
			
			#if node.has_method("get_seamless") and !instant_fading:
			#	instant_fading = node.get_seamless()
			
		
		if instant_fading:
			instant_fade(check)
		else:
			fade(check)


func overlaps(input: Node2D) -> bool:
	var spots: Array[Vector2i] = get_used_cells()
	var approximate: Vector2i = Vector2i(((input.global_position-global_position) / 16.0).floor())
	return spots.has(approximate)


func fade(in_or_out: bool) -> void:
	if fade_mode == in_or_out:
		return
	enabled = true
	visible = true
	var tt = base_time - fade_time.time_left
	fade_mode = in_or_out
	fade_time.start(tt)

func on_fadeout() -> void:
	var goal: float = 1.0 if fade_mode else 0.0
	correct_opacity(goal)
	enabled = fade_mode

func set_show_area(input: Area2D = null) -> void:
	show_area = input

func instant_fade(input: bool) -> void:
	fade_mode = input
	fade_time.stop()
	on_fadeout.call_deferred()

func change_palette(input: Dictionary[int,ShaderMaterial], clear_non_included: bool = true) -> void:
	if input.has(material_layer):
		material = input[material_layer].duplicate()
		if material is ShaderMaterial:
			material.set_shader_parameter("opacity_enabled",true)
	elif clear_non_included:
		material = null
	
	

## sets this node and all child nodes to the correct opacity
func correct_opacity(input: float) -> void:
	recent_opacity = input
	
	modulate = Color(1.0,1.0,1.0,input)
	if material is ShaderMaterial:
		material.set_shader_parameter("opacity",input)
	
	for child in get_children():
		if child is CanvasItem:
			child.modulate = modulate
			if child.material is ShaderMaterial:
				material.set_shader_parameter("opacity",input)

## intentionally does nothing
func empty_function() -> void:
	pass

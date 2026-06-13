class_name ReflectionZone
extends AstralZone


## Whether or not to reflect across 
@export var reflect_X: bool = false
@export var reflect_Y: bool = false

## The position of the bounding rectangle in screen lengths
@export var target_screen_position: Vector2i = Vector2i.ZERO
## The position of the bounding rectangle in tiles
@export var target_tile_position: Vector2i = Vector2i.ZERO


## The size of the bounding rectangle in screen lengths
@export var target_screen_size: Vector2i = Vector2i.ZERO
## The size of the bounding rectangle in tiles
@export var target_tile_size: Vector2i = Vector2i.ZERO

## Used to cull warping if desired. 0 means never culled
@export var reflection_ID: int = 0

## if active, the reflector will attempt to automatically reflect nodes
@export var auto_bound: bool = true

var cue: GameCue



func ready_behavior() -> void:
	cue = GameCue.new()
	add_child(cue)
	
	cue.add_cue("mirror",mirror_changed)


func enforce_distances(player_container: PlayerContainer, active_player: Player, inactive_player: Player):
	if !active_player.astral_mode:
		return
	
	var source_pos: Vector2 = active_player.final_position() / 16.0
	source_pos += 0.5 * Vector2.ONE
	var reflect_vector: Vector2 = Vector2.LEFT if reflect_X else Vector2.RIGHT
	reflect_vector += Vector2.UP if reflect_Y else Vector2.DOWN
	
	
	var bounds_position: Vector2 = (Vector2(target_screen_position) * screen) + Vector2(target_tile_position)
	var bounds_size: Vector2 = (Vector2(target_screen_size) * screen) + Vector2(target_tile_size)
	var offset: Vector2 = bounds_position + (bounds_size/2.0)
	if auto_bound:
		offset = (global_position/16.0)
	var target_pos: Vector2 = source_pos - offset
	
	var bounds: Rect2 = Rect2(-(bounds_size/2.0), bounds_size)
	
	
	
	var best_pos: Vector2 = target_pos if auto_bound else clamp_position(target_pos,bounds)
	best_pos *= reflect_vector
	best_pos += offset
	
	
	var final: Vector2 = best_pos - source_pos
	player_container.adjust_player_distances(final/screen)
	
	
	inactive_player.turn(active_player.facing_direction() * -1)


func _process(_delta: float) -> void:
	pass


func reflect(input: int) -> void:
	if input == 0 or reflection_ID == 0 or input == reflection_ID:
		scan_bodies()


func clamp_position(pos: Vector2,bounds: Rect2) -> Vector2:
	return Vector2(clamp(pos.x,bounds.position.x,bounds.end.x),clamp(pos.y,bounds.position.y,bounds.end.y))


func mirror_changed(input: int) -> void:
	if input == 1:
		scan_bodies()

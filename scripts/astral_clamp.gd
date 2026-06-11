## Astral clamps are used to map an area2D directly onto a rectangular bound
## elsewhere in the level. This has extra functionality that an astral anchor
## would not because it is better suited for mapping a combination of dynamic
## and predetermined coordinate positions.
class_name AstralClamp
extends AstralZone

## The position of the bounding rectangle in screen lengths
@export var target_screen_position: Vector2i = Vector2i.ZERO
## The position of the bounding rectangle in tiles
@export var target_tile_position: Vector2i = Vector2i.ZERO


## The size of the bounding rectangle in screen lengths
@export var target_screen_size: Vector2i = Vector2i.ZERO
## The size of the bounding rectangle in tiles
@export var target_tile_size: Vector2i = Vector2i.ZERO

## The offset to the target bounds in screen lengths, enforced on the input position.
## Used so if we're 8 screens below the target, we're not forced to the maximum Y.
@export var screen_offset: Vector2i = Vector2i.ZERO
## THe offset to the target bounds in tiles, enforced on the input position.
## Used so if we're 800 tiles below the target, we're not forced to the maximum Y.
@export var tile_offset: Vector2i = Vector2i.ZERO


func enforce_distances(player_container: PlayerContainer, active_player: Player, _inactive_player: Player):

	var source_pos: Vector2 = active_player.final_position() / 16.0
	
	var offset: Vector2 = (Vector2(tile_offset) + (Vector2(screen_offset) * screen))
	
	var target_pos: Vector2 = source_pos + offset
	var bounds_position: Vector2 = (Vector2(target_screen_position) * screen) + Vector2(target_tile_position)
	var bounds_size: Vector2 = (Vector2(target_screen_size) * screen) + Vector2(target_tile_size)
	
	var bounds: Rect2 = Rect2(bounds_position, bounds_size)
	
	var best_pos: Vector2 = Vector2(clamp(target_pos.x,bounds.position.x,bounds.end.x),clamp(target_pos.y,bounds.position.y,bounds.end.y))
	
	var final: Vector2 = best_pos - source_pos
	
	player_container.adjust_player_distances(final/screen)
	
	#print(final/screen)

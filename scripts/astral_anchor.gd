## An astral zone capable of teleporting the inactive player either
## Upon the x axis, y axis, both, or neither. You can also choose whether
## It accepts data from the active player's position, which can be used
## to offset the result position if both the enforce and copy booleans are true.
## ENFORCE: sets an axis to the chosen value
## COPY: sets an axis to the value of the active player
## BOTH: sets an axis to the value of the active player, then offsets it by the chosen value
## NEITHER: retain the original value of this axis
class_name AstralAnchor
extends AstralZone

## whether or not to add the replacement X value
@export var enforce_X: bool = true
## whether or not to add the replacement Y value
@export var enforce_Y: bool = true
## whether or not to add the original X value
@export var copy_X: bool = false
## whether or not to add the original Y value
@export var copy_Y: bool = false
@export var target_screen: Vector2i = Vector2i.ZERO
@export var target_tile: Vector2i = Vector2i.ZERO




func enforce_distances(player_container: PlayerContainer, active_player: Player, inactive_player: Player):
	var enforce_axis: Vector2 = Vector2.ZERO
	if enforce_X:
		enforce_axis += Vector2.RIGHT
	if enforce_Y:
		enforce_axis += Vector2.DOWN
	
	var copy_axis: Vector2 = Vector2.ONE
	if copy_X:
		copy_axis -= Vector2.RIGHT
	if copy_Y:
		copy_axis -= Vector2.DOWN
	
	var retain_axis: Vector2 = Vector2.ONE
	if enforce_X or copy_X:
		retain_axis -= Vector2.RIGHT
	if enforce_Y or copy_Y:
		retain_axis -= Vector2.DOWN
	
	var source_pos: Vector2 = active_player.final_position() / 16.0
	
	var retained_pos: Vector2 = inactive_player.final_position() / 16.0
	retained_pos -= source_pos
	
	var enforced_vector: Vector2 = Vector2(target_screen) + (Vector2(target_tile) / screen)
	
	var unchanged_vector: Vector2 = source_pos / screen
	
	var retained_vector: Vector2 = retained_pos / screen
	
	var final: Vector2 = (enforce_axis * enforced_vector) - (copy_axis * unchanged_vector) + (retain_axis * retained_vector)
	
	player_container.adjust_player_distances(final)

## The AstralTranslation node forces the offset of the astral tether to
## Be the value it provides
class_name AstralTranslation
extends AstralZone

@export var screen_offset: Vector2i = Vector2i(0,8)
@export var tile_offset: Vector2i = Vector2i.ZERO


func enforce_distances(player_container: PlayerContainer, _active_player: Player, _inactive_player: Player):
	var ans: Vector2 = Vector2(screen_offset) + (Vector2(tile_offset) / screen)
	player_container.adjust_player_distances(ans)

## This isn't related to astral zones but is instead used to
## force a restart position for puzzles
class_name RestartZone
extends AstralZone

## Screen to warp to
@export var warp_screen: Vector2i = Vector2i.ZERO
## Tile to warp to
@export var warp_tile: Vector2i = Vector2i.ZERO


const game_data: GameData = preload("res://resources/game data/gameData.tres")


func enforce_distances(_player_container: PlayerContainer, _active_player: Player, _inactive_player: Player):
	var ans: Vector2 = (screen * Vector2(warp_screen)) + Vector2(warp_tile) + Vector2(0.5,0.5)
	ans *= 16.0
	
	game_data.set_restart_position(ans)

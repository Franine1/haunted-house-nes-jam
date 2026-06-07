## The DialogueMovement node sends CutscenePath resources to the
## GameData resource which will automatically alert the corresponding
## NPCs or player. You can define a list of Vector2i travel paths the
## target will follow, along with a travel speed in tiles per second
## and the NPC ID of which NPC you're targetting.
class_name DialogueMovement
extends Dialogue

## The list of vector paths the target character should take
@export var directions: Array[Vector2i] = []
## The NPC ID of the target character. -1 is the player.
@export var NPC_ID: int = -1
## The speed of travel. 5 tiles per second is the default
@export var speed: float = 5.0
## An aim direction override, if needed for the cutscene
@export var look_direction: direction = direction.DONT_OVERRIDE
## In case we want to delay the point in time that we send the movement request
@export var delay: float = 0.0
## determines whether or not the target is relative to the NPC or exact in the world
@export var relative: bool = true

## reference to the game data
const game_data: GameData = preload("res://resources/game data/gameData.tres")

enum direction {
	DONT_OVERRIDE
	,UP
	,DOWN
	,LEFT
	,RIGHT
}


## This dialogue piece is empty, so no lines
## are returned.
func line() -> Array[String]:
	return []

## no A reaction
func A_reaction():
	pass

## no select reaction
func select_reaction():
	pass

## When we check if this dialogue is finished, it requests its
## movement from the game data, then returns
## that the dialogue is finished.
func dialogue_finished() -> bool:
	var look_aim: Vector2i = [Vector2i.ZERO,Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT][look_direction]
	
	var ans: CutscenePath = CutscenePath.compile(directions,speed,look_aim,relative)
	if delay <= 0:
		game_data.queue_movement(ans,NPC_ID)
	else:
		var source = get_tree().current_scene
		source.get_tree().create_timer(delay).timeout.connect(game_data.queue_movement.bind(ans,NPC_ID))
	
	return true

## No resetting needs to be done.
func reset_dialogue() -> void:
	pass

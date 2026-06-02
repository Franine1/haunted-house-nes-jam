## Dialogue cues are empty dialogue pieces that
## change a variable in the GameData resource. They 
## can be used to signal to the game what choices a 
## player made, or enable/disable other dialogue options.
class_name DialogueCue
extends Dialogue

## The string name of the value to set
@export var cue: String
## what value we'll set it to
@export var value: int
## In case we want to delay the point in time that we change this value
@export var delay: float = 0.0
## whether we set the parameter, or add var "value" to it
@export var additive: bool = true
## path to the game data
const game_data: GameData = preload("res://resources/game data/gameData.tres")

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

## When we check if this dialogue is finished, it performs its
## cue and sets the correct parameter in game data, then returns
## that the dialogue is finished.
func dialogue_finished() -> bool:
	if delay <= 0:
		if !additive:
			game_data.set_data(cue,value)
		else:
			game_data.change_data(cue,value)
	else:
		var source = get_tree().current_scene
		if !additive:
			source.get_tree().create_timer(delay).timeout.connect(game_data.set_data.bind(cue,value))
		else:
			source.get_tree().create_timer(delay).timeout.connect(game_data.change_data.bind(cue,value))
	return true

## No resetting needs to be done.
func reset_dialogue() -> void:
	pass

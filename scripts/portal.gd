## Portals are area2Ds specifically meant to telepor
## the player, but have the capacity to teleport other
## things as well. This is an abstract class with the
## common functionality between different types of portals.
@abstract class_name Portal
extends Area2D

## This is measured in the size of tilemap tiles.
## Fractional tiles are not allowed.
@export var warp_offset: Vector2i = Vector2i.ZERO

## The cue this portal checks for. 
## Changing this value from its initial value is not recommended.
@export var cue: String
## the value the cue is compared against
@export var value: int
## The comparison type of this portal
@export var compare_type: compare = compare.ALWAYS


## Game cue to signal this node when its checked value changes
var g_cue: GameCue

## Comparison types for portal activation
enum compare {
	EQUAL ## The values must be equivalent
	,NOT_EQUAL ## The values must not be equivalent
	,LESS ## The cue must be less than the value
	,GREATER ## The cue must be greater than the value
	,LESS_OR_EQUAL ## The cue must not be greater than the value
	,GREATER_OR_EQUAL ## The cue must not be less than the value
	,ALWAYS ## This blockade is always active
}

## Reference to game data
const game_data: GameData = preload("res://resources/game data/gameData.tres")

func _ready() -> void:
	collision_layer = 0
	collision_mask = 4
	body_shape_entered.connect(activate.unbind(2))
	g_cue = GameCue.new()
	add_child(g_cue)
	
	g_cue.add_cue(cue,update_activity)
	
	update_activity()

func is_active() -> bool:
	var active = (compare_type == compare.ALWAYS)
	if (game_data.get_data(cue) == value):
		active = active or [compare.EQUAL,compare.LESS_OR_EQUAL,compare.GREATER_OR_EQUAL].has(compare_type)
	else:
		active = active or [compare.NOT_EQUAL].has(compare_type)
	if (game_data.get_data(cue) < value):
		active = active or [compare.LESS,compare.LESS_OR_EQUAL].has(compare_type)
	if (game_data.get_data(cue) > value):
		active = active or [compare.GREATER,compare.GREATER_OR_EQUAL].has(compare_type)
		
	
	return active

func update_activity(_input: int = 0) -> void:
	var a = is_active()
	if a != monitoring:
		monitoring = a
		if a:
			for body in get_overlapping_bodies():
				if body is CollisionObject2D:
					var r: RID = body.get_rid()
					activate(r,body)

@abstract func activate(body_rid: RID, body: Node2D) -> void

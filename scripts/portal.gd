## Portals are area2Ds specifically meant to telepor
## the player, but have the capacity to teleport other
## things as well. This is an abstract class with the
## common functionality between different types of portals.
@abstract class_name Portal
extends Area2D

## This is measured in the size of tilemap tiles.
## Fractional tiles are not allowed.
@export var warp_offset: Vector2i = Vector2i.ZERO

func _ready() -> void:
	collision_layer = 0
	collision_mask = 4
	body_shape_entered.connect(activate.unbind(2))

@abstract func activate(body_rid: RID, body: Node2D) -> void

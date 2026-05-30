## Node portals have specific nodes
## they bring their target to. This
## node can be any Node2D. This is
## useful for targetting moving
## locations or anything that you
## may move in the level without
## having to rewrite code. The offset
## value is now an additional positional 
## modifier.
class_name NodePortal
extends Portal

@export var target_node: Node2D

func activate(body_rid: RID, body: Node2D) -> void:
	body.global_position = target_node.global_position.round() + (16.0 * warp_offset) + Vector2(8.0,8.0)
	if body.has_method("seamless_warp"):
		body.seamless_warp()

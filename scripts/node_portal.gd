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
	var source_pos: Vector2 = body.global_position
	if body.has_method("final_position"):
		source_pos = body.final_position()
	var diff = (((target_node.global_position/16.0).round() + Vector2(warp_offset)) * 16.0) - (source_pos/16.0).round()
	
	if body.has_method("seamless_warp"):
		body.seamless_warp()
	if body.has_method("teleport"):
		body.teleport(body.global_position + diff)
	else:
		body.global_position += diff

## Teleportation portals bring their 
## target directly to their stored 
## position. This is useful for going
## to known locations without having to 
## track relative distances as with
## translation portals.
class_name TeleportationPortal
extends Portal

func activate(body_rid: RID, body: Node2D) -> void:
	var source_pos: Vector2 = body.global_position
	if body.has_method("final_position"):
		source_pos = body.final_position()
	var diff = (warp_offset * 16.0) - (source_pos/16.0).round()
	
	if body.has_method("seamless_warp"):
		body.seamless_warp()
	if body.has_method("teleport"):
		body.teleport(body.global_position + diff)
	else:
		body.global_position += diff

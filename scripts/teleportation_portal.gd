## Teleportation portals bring their 
## target directly to their stored 
## position. This is useful for going
## to known locations without having to 
## track relative distances as with
## translation portals.
class_name TeleportationPortal
extends Portal

func activate(body_rid: RID, body: Node2D) -> void:
	body.global_position = (warp_offset * 16.0) + Vector2(8.0,8.0)
	if body.has_method("seamless_warp"):
		body.seamless_warp()

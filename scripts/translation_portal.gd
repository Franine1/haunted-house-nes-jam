## Translation portals move their target relative 
## to where it's currently at. The target is simply
## moved a certain distance. No signals need to be
## emitted. 
##
## This could be used, for example, for an infinite
## hallway. A certain point has a translation portal
## that moves the player down slightly.
class_name TranslationPortal
extends Portal

func activate(body_rid: RID, body: Node2D) -> void:
	var diff = warp_offset * 16.0
	
	if body.has_method("seamless_warp"):
		body.seamless_warp()
	if body.has_method("teleport"):
		body.teleport(body.global_position + diff)
	else:
		body.global_position += diff

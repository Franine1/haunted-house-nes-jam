## Abstract class used for astral zones that affect warp distances for astral projection
@abstract class_name AstralZone
extends Area2D

const screen: Vector2 = Vector2(16.0,14.0)

func _ready() -> void:
	collision_layer = 256
	collision_mask = 4
	ready_behavior()

func ready_behavior() -> void:
	pass


## Automatically enforces distances on any overlapping, active player nodes
func _process(_delta: float) -> void:
	scan_bodies()


## seperate from process so inheritors can redefine behavior if needed
func scan_bodies() -> void:
	for body in get_overlapping_bodies():
		if body is Player:
			if body.toggle:
				var par = body.get_parent()
				assert((is_instance_valid(par) and par != null and par is PlayerContainer),"Player node not contained in a player container")
				if par is PlayerContainer:
					var a: Player = par.current_player()
					var b: Player = par.current_player(false)
					enforce_distances(par,a,b)


func get_shapes() -> Array[Node2D]:
	var ans: Array[Node2D] = []
	
	for child in get_children():
		if child is CollisionPolygon2D or child is CollisionShape2D:
			ans.append(child)
	
	return ans



## Different astral zones can define how they enfore distances independently
@abstract func enforce_distances(player_container: PlayerContainer, active_player: Player, inactive_player: Player)

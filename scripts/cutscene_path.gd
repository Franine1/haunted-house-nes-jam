## This class is meant as a data type that allows complex
## movement orders to be passed between nodes with ease. 
## This class generally is not meant to be saved as a file,
## it is more so expected to be commanded via DialogueMovement nodes.
class_name CutscenePath
extends Resource

@export var directions: Array[Vector2i]
@export var speed: float = 1.0
@export var look_direction: Vector2i = Vector2i.ZERO


static func compile(dir: Array[Vector2i], spd: float = 1.0, look_dir: Vector2i = Vector2i.ZERO) -> CutscenePath:
	var ans = CutscenePath.new()
	for i in range(dir.size()-1,-1,-1):
		if dir[i]:
			ans.directions.append(dir[i])
	ans.speed = spd
	ans.look_direction = look_dir
	return ans


static func compile_look_direction(input: Vector2i) -> CutscenePath:
	var ans = CutscenePath.new()
	ans.speed = 1.0
	ans.look_direction = input.sign()
	return ans


func direction() -> Vector2i:
	if directions.size() == 0:
		return Vector2i.ZERO
	return directions.back()


func reduce(input: Vector2i) -> void:
	if directions.size() > 0:
		directions[directions.size()-1] -= input
		if !directions.back():
			directions.pop_back()
	if directions.size() == 0:
		look_direction = Vector2i.ZERO

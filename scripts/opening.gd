extends Node2D

var a_presses = 0
var can_a = true

func _ready() -> void:
	$Nestitle.visible = true
	$Car.visible = false
	$Crawlone.visible = false
	$Parallax2D.visible = false
	$Pressa.visible = false
	

func _input(event: InputEvent) -> void:
		if event.is_action_pressed("A button") && can_a == true:
			a_presses += 1
			can_a = false
			print(a_presses)
			match a_presses:
				1:
					$Nestitle.visible = false
					await get_tree().create_timer(1.0).timeout
					$Parallax2D.visible = true
					await get_tree().create_timer(0.5).timeout
					$Car.visible = true
					await get_tree().create_timer(0.5).timeout
					$Crawlone.visible = true
					await get_tree().create_timer(2.0).timeout
					$Pressa.visible = true
					can_a = true
				2:
					$Crawlone.visible = false
					$Pressa.visible = false
					await get_tree().create_timer(2.0).timeout
					$Pressa.visible = true
					can_a = true
				3:
					$Pressa.visible = false
					await get_tree().create_timer(2.0).timeout
					$Pressa.visible = true
					can_a = true
				4:
					$Pressa.visible = false
					await get_tree().create_timer(2.0).timeout
					$Pressa.visible = true
					can_a = true
				5:
					$Pressa.visible = false
					await get_tree().create_timer(2.0).timeout
					$Pressa.visible = true
					can_a = true

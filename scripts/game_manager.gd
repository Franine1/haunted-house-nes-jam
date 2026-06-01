extends Control

@onready var text_holder: HBoxContainer = %HBoxContainer

const textbox: PackedScene = preload("res://scenes/UI/textbox.tscn")

var dialogue_script: Dialogue = null
var current_state: game_state = game_state.MENU
var stored_text: Array[String] = []


enum game_state {
	MENU,
	GAME,
	DIALOGUE,
	PAUSED
}

var substate: int = 0


func read_dialogue(input: Dialogue) -> void:
	current_state = game_state.DIALOGUE
	dialogue_script = input
	substate = 0

func _process(delta: float) -> void:
	
	match current_state:
		game_state.MENU:
			menu_behavior(delta)
		
		game_state.GAME:
			game_behavior(delta)
		
		game_state.DIALOGUE:
			dialogue_behavior(delta)
		
		game_state.PAUSED:
			paused_behavior(delta)
		
	
	

func _ready() -> void:
	read_dialogue(preload("res://resources/dialogue/sections/test_dialogue_section.tres"))


func menu_behavior(delta: float) -> void:
	pass
	
func game_behavior(delta: float) -> void:
	pass
	
func dialogue_behavior(delta: float) -> void:
	text_holder.show()
	match substate:
		0:
			dialogue_script.reset_state()
			substate = 1
		1:
			 
			fill_dialogue(0.01)
			
			substate = 2
		2:
			var read_a: bool = Input.is_action_just_pressed("A button")
			var read_b: bool = Input.is_action_just_pressed("B button")
			var read_s: bool = Input.is_action_just_pressed("Select button")
			
			if read_s:
				dialogue_script.select_reaction()
				var temp: Array[String] = dialogue_script.line()
				
				if temp.size() != stored_text.size():
					substate = 1
				else:
					for i in temp.size():
						if temp[i] != stored_text[i]:
							substate = 3
							break
			if read_b:
				for box in text_holder.get_children():
					if box is Textbox:
						box.finish_letters()
			if read_a:
				dialogue_script.A_reaction()
				substate = 1
		3:
			fill_dialogue(0.01,true)
			
			substate = 2
		_:
			substate = 0

func fill_dialogue(delay: float, cancel_delay: bool = false) -> void:
	for child in text_holder.get_children():
		text_holder.remove_child(child)
		child.queue_free()
	
	if dialogue_script.dialogue_finished():
		current_state = game_state.GAME
		return
	
	stored_text = dialogue_script.line()
	
	for line in stored_text:
		var temp: Textbox = textbox.instantiate()
		text_holder.add_child(temp)
		temp.display(line,delay)
		if cancel_delay:
			temp.finish_letters()

func paused_behavior(delta: float) -> void:
	pass

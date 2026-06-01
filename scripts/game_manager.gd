class_name GameManager
extends Control

@onready var text_holder: HBoxContainer = %HBoxContainer
@onready var game_world: SubViewport = %"game world"
@onready var cue: GameCue = %GameCue

const textbox: PackedScene = preload("res://scenes/UI/textbox.tscn")
const game_data: GameData = preload("res://resources/game data/gameData.tres")
const levels: Array[PackedScene] = [
	preload("res://scenes/levels/tetouse.tscn")
	,preload("res://scenes/levels/default_house.tscn")
]

var dialogue_script: Dialogue = null
var current_state: game_state = game_state.MENU
var stored_text: Array[String] = []
var textbox_delay: Timer

enum game_state {
	MENU,
	GAME,
	DIALOGUE,
	PAUSED
}

var substate: int = 0


func read_dialogue(input: Dialogue) -> void:
	current_state = game_state.DIALOGUE
	if dialogue_script != null and is_instance_valid(dialogue_script) and get_children().has(dialogue_script):
		remove_child(dialogue_script)
		dialogue_script.queue_free()
	dialogue_script = input
	if dialogue_script.get_parent() == null:
		add_child(dialogue_script)
	substate = 0

func _process(delta: float) -> void:
	
	match current_state:
		game_state.MENU:
			menu_behavior(delta)
		
		game_state.GAME:
			game_behavior(delta)
			
			var next_dialogue: Dialogue = game_data.next_dialogue()
			if next_dialogue != null:
				read_dialogue(next_dialogue)
		
		game_state.DIALOGUE:
			dialogue_behavior(delta)
		
		game_state.PAUSED:
			paused_behavior(delta)
		
	
	

func _ready() -> void:
	
	textbox_delay = Timer.new()
	add_child(textbox_delay)
	textbox_delay.one_shot = true
	
	cue.add_cue("level",Callable(self,"change_level"))


func change_level(input: int) -> void:
	if input < 0 or input >= levels.size():
		return
	
	for child in game_world.get_children():
		game_world.remove_child(child)
		child.queue_free()
	
	var temp = levels[input].instantiate()
	
	game_world.add_child(temp)




func menu_behavior(delta: float) -> void:
	text_holder.hide()
	get_tree().paused = true
	game_world.handle_input_locally = false
	
	current_state = game_state.GAME
	get_tree().paused = false
	var dia: Dialogue = load("res://scenes/dialogue/test_dialogue_2.tscn").instantiate()
	change_level(0)
	get_tree().create_timer(1.0).timeout.connect(read_dialogue.bind(dia))

func game_behavior(delta: float) -> void:
	text_holder.hide()
	game_world.handle_input_locally = true
	
func dialogue_behavior(delta: float) -> void:
	text_holder.show()
	get_tree().paused = true
	game_world.handle_input_locally = false
	
	match substate:
		0:
			dialogue_script.reset_dialogue()
			substate = 1
		1:
			 
			fill_dialogue(0.01)
			
			substate = 2
		2:
			var read_a: bool = Input.is_action_just_pressed("A button") or (textbox_delay.is_stopped() and Input.is_action_pressed("A button"))
			var read_b: bool = Input.is_action_pressed("B button")
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
				var possible: bool = true
				for child in text_holder.get_children():
					if child is Textbox:
						if !possible:
							break
						
						if !child.is_full():
							possible = false
							break
				if possible:
					dialogue_script.A_reaction()
					textbox_delay.start(0.5)
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
		get_tree().paused = false
		stored_text = []
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
	text_holder.hide()
	get_tree().paused = true
	game_world.handle_input_locally = true

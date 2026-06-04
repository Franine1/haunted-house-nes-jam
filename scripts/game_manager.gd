## The game manager is expected to be THE main scene. It contains all 
## of the game UI and lets the player interact with any game scenes
## through the medium of a viewport. It has the tools to change and load 
## levels, set up color palettes to the level, load and read dialogue, 
## manage the main menu and pause menu, and it should be the container
## with all of the arbitrary scripting the game requires for any ultra-specific
## interactions needed.
class_name GameManager
extends Control

@onready var text_holder: HBoxContainer = %HBoxContainer
@onready var game_world: SubViewport = %"game world"
@onready var cue: GameCue = %GameCue

## Used to create textboxes
const textbox: PackedScene = preload("res://scenes/UI/textbox.tscn")
## the GameData resource to read data changes from
const game_data: GameData = preload("res://resources/game data/gameData.tres")
## List of which levels it can switch between
const levels: Array[PackedScene] = [
	preload("res://scenes/levels/tetouse.tscn")
	,preload("res://scenes/levels/default_house.tscn")
]
## Current dialogue script
var dialogue_script: Dialogue = null
## Current state of the game
var current_state: game_state = game_state.MENU
## Current text from a dialogue script that's being displayed on screen
var stored_text: Array[String] = []
## Delay to prevent uncontrollable dialogue skipping
var textbox_delay: Timer
## Currently unused delay between multiple level switches
var level_change_delay: Timer
## Forces occassional color refreshed
var color_timer: Timer
## Tracks how long the level needs to wait before resuming dialogue.
var dialogue_timer: Timer
## a reference to the player
var player: Player
## whether to check for dialogue or not
var dialogue_enabled: bool = true

## A default palette that all levels are set to
var current_pallete: Dictionary[int,ShaderMaterial] = {
	0: preload("res://resources/palettes/brownpallete.tres")
	,1: preload("res://resources/palettes/grasspallete.tres")
	,2: preload("res://resources/palettes/playerpallete.tres")
	,3: preload("res://resources/palettes/bluepallete.tres")
	,4: preload("res://resources/palettes/redpallete.tres")
}

## The allowed game states
enum game_state {
	MENU,
	GAME,
	DIALOGUE,
	PAUSED
}

## A second measure of what is ocurring in the current game state
var substate: int = 0

## Sets up the input dialogue to be displayed on screen
func read_dialogue(input: Dialogue) -> void:
	input.reset_dialogue()
	if input.dialogue_finished():
		return
	
	dialogue_enabled = true
	if player != null:
		player.input_allowed = false
		if !player.input_delay.is_stopped():
			get_tree().create_timer(player.input_delay.time_left + 0.025).timeout.connect(read_dialogue.bind(input))
			dialogue_enabled = false
			return
	
	
	current_state = game_state.DIALOGUE
	if dialogue_script != null and is_instance_valid(dialogue_script) and get_children().has(dialogue_script):
		remove_child(dialogue_script)
		dialogue_script.queue_free()
	dialogue_script = input
	if dialogue_script.get_parent() == null:
		add_child(dialogue_script)
	substate = 0

func _process(delta: float) -> void:
	
	# swaps to the currect behavior based on the current game state
	match current_state:
		game_state.MENU:
			menu_behavior(delta)
		
		game_state.GAME:
			game_behavior(delta)
			
			# reads any queued dialogue from the game data
			if dialogue_enabled:
				var next_dialogue: Dialogue = game_data.next_dialogue()
				if next_dialogue != null:
					read_dialogue(next_dialogue)
		
		game_state.DIALOGUE:
			dialogue_behavior(delta)
		
		game_state.PAUSED:
			paused_behavior(delta)
		
	
	

func _ready() -> void:
	# sets up the level change and textbox timers
	textbox_delay = Timer.new()
	add_child(textbox_delay)
	textbox_delay.one_shot = true
	level_change_delay = Timer.new()
	add_child(level_change_delay)
	level_change_delay.one_shot = true
	color_timer = Timer.new()
	add_child(color_timer)
	color_timer.one_shot = true
	dialogue_timer = Timer.new()
	add_child(dialogue_timer)
	dialogue_timer.one_shot = true
	
	# sets up to receive a game cue when the level parameter changes
	cue.add_cue("level",Callable(change_level))
	cue.add_cue("delay",Callable(pause_dialogue))


func pause_dialogue(input: int) -> void:
	if dialogue_timer.is_stopped() and input > 0:
		dialogue_timer.start(0.1 * input)
		game_data.set_data("delay",0)


## deletes the old level and replaces it with the new one.
## Automatically activates if the "level" datapoint changes 
## in the GameData resource.
func change_level(input: int) -> void:
	if current_state == game_state.DIALOGUE:
		# waits until any open dialogue finishes
		get_tree().create_timer(0.02).timeout.connect(change_level.bind(input))
		return
	
	if !level_change_delay.is_stopped():
		# does nothing if it's on level change cooldown
		return
	
	# if the requested level isn't in the list of levels, do nothing
	if input < 0 or input >= levels.size():
		return
	
	# deletes the current game world
	for child in game_world.get_children():
		game_world.remove_child(child)
		child.queue_free()
	
	# creates the next game world and puts it in the same spot
	var temp = levels[input].instantiate()
	game_world.add_child(temp)
	#level_change_delay.start(0.1)
	
	# looks for the player and changes their position if the GameData requests it
	for child in temp.get_children():
		if child is PlayerContainer:
			if game_data.has_data("reposition") and (game_data.get_data("reposition") != 0):
				child.global_position = Vector2(game_data.get_data("x_set"),game_data.get_data("y_set"))
			child.global_position += 16.0 * Vector2(game_data.get_data("x_shift"),game_data.get_data("y_shift"))
			child.pl.finish_camera_glide()
			player = child.pl
	game_data.remove_data("x_set")
	game_data.remove_data("y_set")
	game_data.remove_data("x_shift")
	game_data.remove_data("y_shift")
	game_data.remove_data("reposition")
	
	# sets up the palette in the level after a brief delay
	if temp is Level:
		get_tree().create_timer(0.01).timeout.connect(temp.distribute_palette.bind(current_pallete))



## Right now it instantly starts the game, but this should later on
## be changed to include the expected options along with a few different
## save slots.
func menu_behavior(delta: float) -> void:
	text_holder.hide()
	get_tree().paused = true
	game_world.handle_input_locally = false
	
	current_state = game_state.GAME
	get_tree().paused = false
	change_level(0)

## Lets the player play in the game world. Any extra logic needed for
## the gameplay should be added here.
func game_behavior(delta: float) -> void:
	text_holder.hide()
	game_world.handle_input_locally = true
	
	# attempts to refresh the color pallete every so often
	if color_timer.is_stopped():
		for child in game_world.get_children():
			if child is Level:
				child.distribute_palette.bind(current_pallete)
		color_timer.start(2.5)

## performs all the logic for dialogue to display correctly. 
func dialogue_behavior(delta: float) -> void:
	text_holder.visible = dialogue_timer.is_stopped()
	game_world.handle_input_locally = false
	
	if !dialogue_timer.is_stopped():
		substate = 1
		return
	
	match substate:
		0: # starts the dialogue fresh
			
			dialogue_script.reset_dialogue()
			textbox_delay.start(0.5)
			substate = 1
			
		1: # requests the correct dialogue boxes to appear 
			
			fill_dialogue(0.01 * clamp(game_data.get_data("lettering"),1,1000))
			substate = 2
			
		2: # checks for player input while dialogue is filing/is completely filled
			
			# the textbox delay only kicks in if A is being held instead of pressed
			var read_a: bool = Input.is_action_just_pressed("A button") or (textbox_delay.is_stopped() and Input.is_action_pressed("A button"))
			# finishes filling dialogue, if possible
			var read_b: bool = Input.is_action_pressed("B button")
			# tabs through options in an option menu
			var read_s: bool = Input.is_action_just_pressed("Select button")
			
			# determines whether or not the text boxes are all full
			var possible: bool = true
			for child in text_holder.get_children():
				if child is Textbox:
					if !possible:
						break
					
					if !child.is_full():
						possible = false
						break
			
			
			if game_data.get_data("skip") > 0 and !possible:
				game_data.change_data("skip",-1)
				read_b = true
			
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
				possible = true
			if read_a:
				if possible:
					dialogue_script.A_reaction()
					textbox_delay.start(0.5)
					substate = 1
			
		3: # skips the delay between different letters
			fill_dialogue(0.01 * clamp(game_data.get_data("lettering"),1,1000),true)
			substate = 2
			
		_: # unknown substates redirect to the beginning of dialogue
			substate = 0

## deletes old dialogue boxes and adds in new ones based on the current needs
func fill_dialogue(delay: float, match_letters: bool = false) -> void:
	var let: Array[int] = []
	for child in text_holder.get_children():
		if match_letters and child is Textbox:
			var temp = let
			let = [child.visible_characters]
			let.append_array(temp)
		text_holder.remove_child(child)
		child.queue_free()
	
	# if the current dialogue is done, simply delete these old textboxes
	# and go back to the game instead. 
	if dialogue_script.dialogue_finished():
		stored_text = []
		player.input_allowed = true
		current_state = game_state.GAME
		return
	
	stored_text = dialogue_script.line()
	
	for line in stored_text:
		var temp: Textbox = textbox.instantiate()
		text_holder.add_child(temp)
		var initial: int = 0
		if let.size() > 0:
			initial = let.pop_back()
		temp.display(line,delay,initial)
		


## any logic done in the pause menu would go here.
func paused_behavior(delta: float) -> void:
	text_holder.hide()
	get_tree().paused = true
	game_world.handle_input_locally = true

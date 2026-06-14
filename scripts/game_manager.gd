## The game manager is expected to be THE main scene. It contains all 
## of the game UI and lets the player interact with any game scenes
## through the medium of a viewport. It has the tools to change and load 
## levels, set up color palettes to the level, load and read dialogue, 
## manage the main menu and pause menu, and it should be the container
## with all of the arbitrary scripting the game requires for any ultra-specific
## interactions needed.
class_name GameManager
extends Control

## Holds the dialogue popups
@onready var text_holder: HBoxContainer = %HBoxContainer
## Holds the game level
@onready var game_world: SubViewport = %"game world"
## Displays all pause-menu related icons
@onready var pause_menu: Control = %pause_menu
## Holds the pause menu options
@onready var pause_options: VBoxContainer = %pause_textbox
## Automatically signals the game when certain events occur
@onready var cue: GameCue = %GameCue
## Dialogue scripts used for the menu system
@onready var menu_system: Dialogue = %"menu system"
## holds tooltip popups
@onready var tooltip_holder: VBoxContainer = %tooltip_box





## Used to create textboxes
const textbox: PackedScene = preload("res://scenes/UI/textbox.tscn")
## Used to display save files
const save_slot: PackedScene = preload("res://scenes/UI/save_slot.tscn")

## the GameData resource to read data changes from
const game_data: GameData = preload("res://resources/game data/gameData.tres")
## List of which levels it can switch between
const levels: Array[PackedScene] = [
	preload("res://scenes/levels/tetouse.tscn")
	,preload("res://scenes/levels/default_house.tscn")
	,preload("res://scenes/levels/washer_level.tscn")
	,preload("res://scenes/levels/liminal_house.tscn")
	,preload("res://scenes/levels/backyard.tscn")
	,preload("res://scenes/levels/second_floor.tscn")
	,preload("res://scenes/levels/master_bedroom.tscn")
]
## Current dialogue script
var dialogue_script: Dialogue = null
## Current state of the game
var current_state: game_state = game_state.START
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


## determines whether the menu is a pause or main menu
var default_menu: int = 0


## A default palette that all levels are set to
var current_pallete: Dictionary[int,ShaderMaterial] = {
	0: preload("res://resources/palettes/brownpallete.tres")
	,1: preload("res://resources/palettes/grasspallete.tres")
	,2: preload("res://resources/palettes/playerpallete.tres")
	,3: preload("res://resources/palettes/bluepallete.tres")
	,4: preload("res://resources/palettes/redpallete.tres")
	,5: preload("res://resources/palettes/oceanpallette.tres")
	,6: preload("res://resources/palettes/ghostlypallette.tres")
	,7: preload("res://resources/palettes/grimepallette.tres")
	,8: preload("res://resources/palettes/tundrapallette.tres")
	,9: preload("res://resources/palettes/brickpallette.tres")
	,10: preload("res://resources/palettes/pinetree_pallette.tres")
	,11: preload("res://resources/palettes/player_ghost_pallette.tres")
	,12: preload("res://resources/palettes/snow_pallette.tres")
	,13: preload("res://resources/palettes/dusk_pallette.tres")
	,14: preload("res://resources/palettes/ethereal_pallette.tres")
	,15: preload("res://resources/palettes/moldy_pallette.tres")
	,16: preload("res://resources/palettes/transition_pallette_1.tres")
	,17: preload("res://resources/palettes/transition_pallette_2.tres")
	,18: preload("res://resources/palettes/danger_pallette.tres")
	,19: preload("res://resources/palettes/bizarre_pallette.tres")
	,20: preload("res://resources/palettes/mirror_pallette.tres")
	,21: preload("res://resources/palettes/gloomy_pallette.tres")
}

## The allowed game states
enum game_state {
	START,
	GAME,
	DIALOGUE,
	MENU
}

## A second measure of what is ocurring in the current game state
var substate: int = 0

## the tooltip currently being displayed
var current_tooltip: int = 0


## elapsed game time
var elapsed_time: float = 0.0

## Sets up the input dialogue to be displayed on screen
func read_dialogue(input: Dialogue) -> void:
	input.reset_dialogue()
	if input.dialogue_finished():
		input.dialogue_finished(true)
		return
	
	dialogue_enabled = true
	if player != null:
		player.input_allowed = false
		if !player.input_delay.is_stopped():
			get_tree().create_timer(player.input_delay.time_left + 0.025).timeout.connect(read_dialogue.bind(input))
			dialogue_enabled = false
			return
	
	
	current_state = game_state.DIALOGUE
	remove_textboxes(tooltip_holder)
	current_tooltip = -1
	
	if dialogue_script != null and is_instance_valid(dialogue_script) and (dialogue_script.get_parent() == null or dialogue_script.has_meta("deletable")):
		remove_child(dialogue_script)
		dialogue_script.queue_free()
	dialogue_script = input
	if dialogue_script.get_parent() == null:
		add_child(dialogue_script)
		dialogue_script.set_meta("deletable",true)
	substate = 0

func _process(delta: float) -> void:
	
	if [game_state.GAME,game_state.DIALOGUE].has(current_state):
		elapsed_time += delta
	
	
	# swaps to the currect behavior based on the current game state
	match current_state:
		game_state.START:
			start_behavior(delta)
		
		game_state.GAME:
			game_behavior(delta)
			
			# reads any queued dialogue from the game data
			if dialogue_enabled:
				var next_dialogue: Dialogue = game_data.next_dialogue()
				if next_dialogue != null:
					read_dialogue(next_dialogue)
			
			if current_tooltip != game_data.get_data("tooltip"):
				change_tooltips()
		
		game_state.DIALOGUE:
			remove_textboxes(tooltip_holder)
			current_tooltip = -1
			dialogue_behavior(delta)
		
		game_state.MENU:
			remove_textboxes(tooltip_holder)
			current_tooltip = -1
			menu_behavior(delta)
		

func change_tooltips() -> void:
	remove_textboxes(tooltip_holder)
	current_tooltip = game_data.get_data("tooltip")
	if current_tooltip > 0 or game_data.has_temporary_tooltips():
		add_textboxes(game_data.next_tooltip(),0.01,tooltip_holder)



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
	
	game_data.tooltip_modified.connect(change_tooltips)


## pauses the dialogue window for a specific amount of time
func pause_dialogue(input: int) -> void:
	if dialogue_timer.is_stopped() and input > 0:
		dialogue_timer.start(0.1 * input)
		game_data.set_data("delay",0)


## deletes the old level and replaces it with the new one.
## Automatically activates if the "level" datapoint changes 
## in the GameData resource.
func change_level(input: int, force_change: bool = false, use_gamedata_positioning: bool = false) -> void:
	if current_state == game_state.DIALOGUE:
		# waits until any open dialogue finishes
		get_tree().create_timer(0.02).timeout.connect(change_level.bind(input))
		return
	elif current_state != game_state.GAME and !force_change:
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
			child.astral_projection.connect(react_to_astral)
			if game_data.has_data("reposition") and (game_data.get_data("reposition") != 0):
				child.global_position = Vector2(game_data.get_data("x_set"),game_data.get_data("y_set"))
			child.global_position += 16.0 * Vector2(game_data.get_data("x_shift"),game_data.get_data("y_shift"))
			player = child.current_player()
			player.request_pause.connect(pause_requested)
			
			if use_gamedata_positioning:
				child.global_position = game_data.get_player_position()
				child.set_snap_axis(game_data.get_player_camera())
				child.ast.global_position = game_data.get_astral_position()
			
			child.current_player().finish_camera_glide()
	game_data.remove_data("x_set")
	game_data.remove_data("y_set")
	game_data.remove_data("x_shift")
	game_data.remove_data("y_shift")
	game_data.remove_data("reposition")
	
	# sets up the palette in the level after a brief delay
	if temp is Level:
		get_tree().create_timer(0.01).timeout.connect(temp.distribute_palette.bind(current_pallete))



func react_to_astral(_input: bool, _chr: Player) -> void:
	var child = player.get_parent()
	
	assert((is_instance_valid(child) and child != null and child is PlayerContainer),"Player node not contained in a valid player container")
	
	player = child.current_player()
	if !player.request_pause.is_connected(pause_requested):
		player.request_pause.connect(pause_requested)
	


## First thing the game does on startup, any code needed for this will go here
func start_behavior(_delta: float) -> void:
	pause_menu.hide()
	text_holder.hide()
	get_tree().paused = true
	game_world.handle_input_locally = false
	
	substate = 0
	dialogue_script = menu_system
	game_data.set_data("menu",default_menu)
	game_data.set_data("music",0)
	clear_menu_data()
	current_state = game_state.MENU



## Lets the player play in the game world. Any extra logic needed for
## the gameplay should be added here.
func game_behavior(_delta: float) -> void:
	pause_menu.hide()
	text_holder.hide()
	game_world.handle_input_locally = true
	
	
	# attempts to refresh the color pallete every so often
	if color_timer.is_stopped():
		for child in game_world.get_children():
			if child is Level:
				child.distribute_palette.bind(current_pallete)
		color_timer.start(2.5)

## performs all the logic for dialogue to display correctly. 
func dialogue_behavior(_delta: float) -> void:
	pause_menu.hide()
	text_holder.visible = dialogue_timer.is_stopped()
	game_world.handle_input_locally = false
	
	if !dialogue_timer.is_stopped():
		substate = 1
		return
	
	match substate:
		0: # starts the dialogue fresh
			
			#dialogue_script.reset_dialogue()
			textbox_delay.start(0.5)
			substate = 1
			
		1: # requests the correct dialogue boxes to appear 
			
			var more: bool = fill_dialogue(0.012 * clamp(game_data.get_data("lettering"),1,1000))
			if more:
				substate = 2
				#var extra: float = clamp(floor(3.0 * pow(stored_text.size(),0.333)),1.0,16.0) * 16.0
				#text_holder.custom_minimum_size = Vector2(0.0,extra)
					
			else:
				substate = 4
			
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
			var more: bool = fill_dialogue(0.012 * clamp(game_data.get_data("lettering"),1,1000),true)
			if more:
				substate = 2
			else:
				substate = 4
		4: # ends the dialogue and returns to the game
			stored_text = []
			player.input_allowed = true
			current_state = game_state.GAME
		_: # unknown substates redirect to the beginning of dialogue
			substate = 0


func remove_textboxes(target: Control) -> void:
	
	for child in target.get_children():
		if child is Textbox:
			target.remove_child(child)
			child.queue_free()
		if child is SaveSlot:
			target.remove_child(child)
			child.queue_free()
		


## deletes old dialogue boxes and adds in new ones based on the current needs
## return is whether or not there is more dialogue
func fill_dialogue(delay: float, match_letters: bool = false, target: Control = text_holder) -> bool:
	
	if !match_letters or dialogue_script.dialogue_finished():
		remove_textboxes(target)
	
	# if the current dialogue is done, simply delete these old textboxes
	# and go back to the game instead. 
	if dialogue_script.dialogue_finished():
		dialogue_script.dialogue_finished(true)
		return false
	
	stored_text = dialogue_script.line()
	
	if match_letters:
		var i = 0
		for child in target.get_children():
			if child is Textbox:
				child.replace_text(stored_text[i])
				i += 1
	else:
		add_textboxes(stored_text,delay,target)
	
	return true


## deletes old dialogue boxes and adds in new ones based on the current needs
## return is whether or not there is more dialogue
func fill_save_slots(target: Control = text_holder) -> bool:
	
	remove_textboxes(target)
	
	# if the current dialogue is done, simply delete these old textboxes
	# and go back to the game instead. 
	if dialogue_script.dialogue_finished():
		dialogue_script.dialogue_finished(true)
		return false
	
	stored_text = dialogue_script.line()
	
	var i: int = 0
	for line in stored_text:
		if line[0] == "*":
			add_textboxes([line.substr(1)],0.0,target)
		elif [">","`","~"].has(line[0]) and line[1] == "*":
			add_textboxes([line[0] + line.substr(2)],0.0,target)
			
		else:
			var temp: SaveSlot = save_slot.instantiate()
			target.add_child(temp)
			temp.display_from_text(line,i)
			i += 1
	
	return true



func add_textboxes(input: Array[String], delay: float, target: Control) -> void:
	for line in input:
			var temp: Textbox = textbox.instantiate()
			target.add_child(temp)
			temp.display(line,delay)


## any logic done in the main menu or pause menu would go here.
func menu_behavior(_delta: float) -> void:
	pause_menu.show()
	text_holder.hide()
	get_tree().paused = true
	game_world.handle_input_locally = false
	
	
	var use_save_slots: bool = (game_data.get_data("menu") == 2) and game_data.get_data("confirm") != -1
	
	%pause_header.size_flags_stretch_ratio = 0.3 if use_save_slots else 1.0
	$pause_menu/HBoxContainer/pause_all.size_flags_stretch_ratio = 5.0 if use_save_slots else 3.0
	
	var target: Control = pause_options
	
	%pause_header.visible = (default_menu == 1)
	
	if !dialogue_timer.is_stopped():
		substate = 1
		return
	elif textbox_delay.is_stopped() and substate != 0 and default_menu == 1:
		if Input.is_action_just_pressed("Start button"):
			substate = 4
	
	
	match substate:
		0: ## reset the dialogue
			dialogue_script.reset_dialogue()
			clear_menu_data()
			textbox_delay.start(0.25)
			substate = 1
			
		1: ## fill in dialogue into the chosen window
			var more: bool
			if use_save_slots:
				more = fill_save_slots(target)
			else:
				more = fill_dialogue(0.012,false,target)
			substate = 3
			## reset if the current dialogue tree ended, otherwise fill all letters
			if more:
				for box in target.get_children():
					if box is Textbox:
						box.finish_letters()
						box.set_centered()
				
		2:
			# whether the current option is chosen
			var read_a: bool = Input.is_action_just_pressed("A button")
			# tabs through options in an option menu
			var read_s: bool = Input.is_action_just_pressed("Select button")
			
			
			if read_s:
				dialogue_script.select_reaction()
				var temp: Array[String] = dialogue_script.line()
				
				if temp.size() != stored_text.size():
					substate = 1
				else:
					for i in temp.size():
						if temp[i] != stored_text[i]:
							if use_save_slots:
								fill_save_slots(target)
								for box in target.get_children():
									if box is Textbox:
										box.finish_letters()
										box.set_centered()
							else:
								fill_dialogue(0.012,true,target)
							break
			
			if read_a:
				dialogue_script.A_reaction()
				substate = 1
		3: ## interpreting the current choices made
			var default_mode: int = 0 if dialogue_script.dialogue_finished() else 2
			if default_mode == 0:
				dialogue_script.dialogue_finished(true)
			match game_data.get_data("menu"):
				0: ## main menu: no special behavior
					pass
				1: ## pause menu: no special behavior
					pass
				2: ## saving and loading
					if default_menu == 1:
						# save a game
						if game_data.get_data("confirm") == 1:
							game_data.set_data("saved",1)
							game_data.save_game(game_data.get_data("slot"))
							game_data.set_data("menu",default_menu)
						
					elif game_data.get_data("confirm") == -1:
						# load a game
						var ll: bool = game_data.load_game(game_data.get_data("slot"))
						if ll:
							default_mode = 6
						else:
							default_mode = 5
				4: ## exits current context
					if game_data.get_data("confirm") == 1:
						if default_menu == 1:
							# deletes the current game world, returns to menu
							for child in game_world.get_children():
								game_world.remove_child(child)
								child.queue_free()
							default_menu = 0
							default_mode = 0
							game_data.set_data("music",0)
							game_data.set_data("volume",0)
							remove_textboxes(tooltip_holder)
							current_tooltip = -1
							game_data.set_data("menu",default_menu)
						else:
							# exit the game
							get_tree().quit()
							
				5: ## start the game
					# resumes game
					if default_menu == 1: ## this is the pause menu
						default_mode = 4
					else: 
						# creates a new world
						game_data.reset_game()
						default_mode = 5
				
				_: ## if we haven't coded it in yet, go back to the default menu
					game_data.set_data("menu",default_menu)
			
			substate = default_mode
		4: ## end the menu stage
			stored_text = []
			pause_requested(false)
		
		5: ## create a new world
			stored_text = []
			start_game()
		
		6: ## load a world
			stored_text = []
			start_game(false)


## responds to player requests for pausing the game
func pause_requested(pausing: bool = true) -> void:
	default_menu = 1
	current_state = game_state.MENU if pausing else game_state.GAME
	player.input_allowed = !pausing
	get_tree().paused = pausing
	substate = 0
	dialogue_script = menu_system
	game_data.set_data("menu",default_menu)
	game_data.set_data("saved",0)
	clear_menu_data()
	
	game_data.store_play_time(elapsed_time)
	elapsed_time = 0.0


func clear_menu_data() -> void:
	
	game_data.set_data("slot",0)
	game_data.set_data("confirm",0)


func start_game(is_new: bool = true) -> void:
	current_state =  game_state.GAME
	get_tree().paused = false
	change_level(game_data.get_data("level"),true,!is_new)
	
	elapsed_time = 0.0

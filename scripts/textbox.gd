## Textbox Control nodes are meant to be instantiated from
## the textbox scene, and can display text data with all formatting
## prepackaged in the scene. They come with panels in the back
## and the ability to display their text letter by letter, 
## and can interpret when a textbox is supposed to be selected.
class_name Textbox
extends RichTextLabel



@onready var letters: Timer = %letter_timer
@onready var back: Panel = %Panel
var duration: float = 0.1

## This takes in an input string and time delay value between letters, then
## sets up the text box correctly from that
func display(input: String, speed: float = 0.01, initial_visible: int = 0) -> void:
	duration = speed
	#bbcode_enabled = true
	
	var read_text: String = input
	var select: bool = read_text[0] == ">"
	if select:
		read_text = read_text.substr(1)
		pass
	
	text = read_text
	
	if select:
		back.theme_type_variation = "SelectedPanel"
	else:
		back.theme_type_variation = "Panel"
	
	
	visible_characters = initial_visible
	
	if !letters.timeout.is_connected(next_letter):
		letters.timeout.connect(next_letter)
	
	letters.start(duration)

## This function is automatically executed by the textbox to
## fill out its letters over time
func next_letter() -> void:
	visible_characters += 1
	if visible_ratio < 1.0:
		letters.start(duration)

## This function can be used to order the textbox to finish filling letters
func finish_letters() -> void:
	letters.stop()
	visible_ratio = 1.0

## This function returns whether or not the textbox has completely filled.
func is_full() -> bool:
	return visible_ratio >= 1.0

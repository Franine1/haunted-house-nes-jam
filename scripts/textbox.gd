class_name Textbox
extends RichTextLabel



@onready var letters: Timer = %letter_timer
@onready var back: Panel = %Panel
var duration: float = 0.1

func display(input: String, speed: float = 0.1) -> void:
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
	
	
	visible_characters = 0
	
	if !letters.timeout.is_connected(next_letter):
		letters.timeout.connect(next_letter)
	
	letters.start(duration)

func next_letter() -> void:
	visible_characters += 1
	if visible_ratio < 1.0:
		letters.start(duration)

func finish_letters() -> void:
	letters.stop()
	visible_ratio = 1.0

func is_full() -> bool:
	return visible_ratio >= 1.0

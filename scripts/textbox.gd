## Textbox Control nodes are meant to be instantiated from
## the textbox scene, and can display text data with all formatting
## prepackaged in the scene. They come with panels in the back
## and the ability to display their text letter by letter, 
## and can interpret when a textbox is supposed to be selected.
class_name Textbox
extends RichTextLabel



@onready var letters: Timer = %letter_timer
@onready var scroller: Timer = %scroll_timer
@onready var back: Panel = %Panel
var duration: float = 0.1
var expected_size: float = 48.0

## This takes in an input string and time delay value between letters, then
## sets up the text box correctly from that
func display(input: String, speed: float = 0.01, initial_visible: int = 0, sze: float = 48.0) -> void:
	duration = speed
	expected_size = sze
	
	replace_text(input)
	
	
	visible_characters = initial_visible
	
	if !letters.timeout.is_connected(next_letter):
		letters.timeout.connect(next_letter)
	
	letters.start(duration)
	
	reset_scroll()
	
	


func replace_text(input: String) -> void:
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


## This looks like ass and I do NOT recommend using this function
func shrink() -> void:
	theme_type_variation = "small_textbox"


## sets the textbox as centered
func set_centered() -> void:
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER

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

## UNUSED
func _process(delta: float) -> void:
	if get_line_count() > get_visible_line_count() and false:
		var scroll: VScrollBar = get_v_scroll_bar()
		var speed = get_visible_line_count() / (1.0 * get_line_count()) * 5.0
		#print(speed)
		if scroll.value >= expected_size:
			if scroller.is_stopped():
				scroller.start(1.0 / speed)
		else:
			scroll.value = clamp(scroll.value + (delta * speed),0.0,1.0) * expected_size

## UNUSED
## used to scroll back to the top of the context window
func reset_scroll() -> void:
	get_v_scroll_bar().value = 0.0

## sets up the scroll timer to properly reset scrolling when it ends
func _ready() -> void:
	scroller.timeout.connect(reset_scroll)
	scroller.one_shot = true

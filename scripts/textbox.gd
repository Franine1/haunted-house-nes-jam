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
var start_time: float = 0.0
var fill_duration: float = 0.1

## This takes in an input string and time delay value between letters, then
## sets up the text box correctly from that
func display(input: String, speed: float = 0.01, initial_visible: int = 0, sze: float = 48.0) -> void:
	duration = speed
	expected_size = sze
	visible_characters = 0
	
	replace_text(input)
	
	visible_characters = initial_visible
	
	
	if !letters.timeout.is_connected(next_letter):
		letters.timeout.connect(next_letter)
	
	#letters.start(duration)
	
	
	reset_scroll()
	
	


func replace_text(input: String) -> void:
	
	var amount: float = visible_ratio * text.length() if text.length() > 0 else 0.0
	var full: bool = (visible_ratio >= 1.0) and (text.length() > 0)
	
	var read_text: String = input
	var select: bool = read_text[0] == ">"
	var cleared: bool = read_text[0] == "~"
	var fade: bool = read_text[0] == "`"
	if cleared or select or fade:
		read_text = read_text.substr(1)
		pass
	
	text = read_text
	
	back.theme_type_variation = "Panel"
	if select:
		back.theme_type_variation = "SelectedPanel"
	if cleared or fade:
		modulate = Color(1.0,1.0,1.0,0.5)
	if cleared:
		back.hide()
	
	fill_duration = read_text.length() * duration
	var new_ratio: float = amount / clamp(input.length(),1,INF)
	start_time = -(new_ratio * fill_duration - Time.get_unix_time_from_system())
	if full:
		finish_letters()


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
	fill_duration = 0.001
	visible_ratio = 1.0

## This function returns whether or not the textbox has completely filled.
func is_full() -> bool:
	return visible_ratio >= 1.0

## automatically scrolls through text: UNUSED
## Also now performs the letter filling
func _process(delta: float) -> void:
	
	visible_ratio = clamp((Time.get_unix_time_from_system() - start_time) / fill_duration,0.0,1.1)
	
	
	
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




static func modulus(source: float, mod: float) -> float:
	var sub = (1.0 * source)/(1.0 * mod) # -10, 3 -> -3.333
	var ans = source - (mod * floor(sub)) # -10, 3, -3.333 -> 2
	return ans

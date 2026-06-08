extends DialogueSection


## Starting from 4, the ID of the specific window in question. 
## Values before 4 are used to determine whether there is extra dialogue.
@export var knock_ID: int = 4
@onready var let_player_knock: DialogueToggle = %let_knock
@onready var change_knock: DialogueCue = %change_knock

func _ready() -> void:
	
	try_linking()


func try_linking() -> void:
	if (let_player_knock != null and change_knock != null) and let_player_knock.is_node_ready() and change_knock.is_node_ready():
		let_player_knock.value = knock_ID
		change_knock.value = knock_ID
		
	else:
		get_tree().create_timer(0.5).timeout.connect(try_linking)

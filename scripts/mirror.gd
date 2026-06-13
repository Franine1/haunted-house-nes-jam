class_name Mirror
extends Blockade



signal request_reflection(id: int)

@export var reflection_ID: int = 0

## when the player presses A on it, sends its dialogue if interact_Activation is true
func interact() -> void:
	if interact_activation and interact_allowed and active:
		mirror_interact()

## when the player bumps into it, sends its dialogue if collide_Activation is true
func bump(source: NPC = null) -> void:
	if source is Player and collide_activation and interact_allowed and active:
		if source.toggle:
			if source != null:
				source.delay_interaction()
				source.erase_movement_queue_attempt()
			mirror_interact()



func mirror_interact() -> void:
	if GameCue.get_cue("mirror") == 1:
		request_reflection.emit(reflection_ID)
	else:
		send_dialogue()

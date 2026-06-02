## abstract class that all dialogue inherits from.
## all dialogue can react to the A or select button,
## and can both be reset or know if it's finished.
## you can also get the next line from all dialogue.
@abstract class_name Dialogue
extends Node


@abstract func line() -> Array[String]
@abstract func A_reaction()
@abstract func select_reaction()
@abstract func dialogue_finished() -> bool
@abstract func reset_dialogue() -> void

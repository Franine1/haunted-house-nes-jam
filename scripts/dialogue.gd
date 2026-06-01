@abstract class_name Dialogue
extends Node


@abstract func line() -> Array[String]
@abstract func A_reaction()
@abstract func select_reaction()
@abstract func dialogue_finished() -> bool
@abstract func reset_dialogue() -> void

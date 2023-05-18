extends Node

signal load_program_pressed(path: String)
signal show_load_program_menu
signal program_loaded

signal cycle_changed
signal show_menu(value: bool)
signal close_menu

signal expand_stage(stage_number: int)
signal stage_tween_finished

## true if a window was closed on click outside it to prevent that same click expanding a stage
var close_window_handled: bool = false


var can_instantiate_load_menu: bool = true

var current_cycle: int = 0 :
	set(value):
		current_cycle = value
		cycle_changed.emit()

extends Node

signal load_program_pressed(path: String)
signal show_load_program_menu

signal cycle_changed

signal show_component_info(center, info)

var can_instantiate_load_menu: bool = true

var current_cycle: int = 0 :
	set(value):
		current_cycle = value
		cycle_changed.emit()

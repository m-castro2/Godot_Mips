extends Node

signal load_program_pressed(path: String)
signal show_load_program_menu

enum component_type { InstructionsMemory }
signal show_instructions_memory

var can_instantiate_load_menu: bool = true

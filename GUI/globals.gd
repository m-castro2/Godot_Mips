extends Node


# avoids breaking nodepath to cpu_pipeline when singleton number is modified: TURN INTO SINGLETON
var singleton_number: int = 4

enum STAGES {IF, ID, EX, MEM, WB}

signal load_program_pressed(path: String)
signal show_load_program_menu
signal program_loaded

signal show_settings_menu

signal cycle_changed
signal show_menu(value: bool)
signal close_menu

signal expand_stage(stage_number: int)
var current_expanded_stage: STAGES = -1
var is_stage_tweening: bool
signal stage_tween_finished(stage: STAGES)
signal components_tween_finished

## used by stages to get coords to other stages components
signal stage_component_requested(stage_number: int, component_name: String, caller_ref: NodePath)

## true if a window was closed on click outside it to prevent that same click expanding a stage
var close_window_handled: bool = false
signal recenter_window


var can_instantiate_load_menu: bool = true
var active_menu: String = ""

var current_cycle: int = 0 :
	set(value):
		current_cycle = value
		cycle_changed.emit()


# notify changes to color settings
signal stage_color_changed(index: int)
signal stage_color_mode_changed(mode: int)

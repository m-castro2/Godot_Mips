extends Node


# avoids breaking nodepath to cpu_pipeline when singleton number is modified: TURN INTO SINGLETON
var singleton_number: int = 4

enum STAGES {IF, ID, EX, MEM, WB}

signal load_program_pressed(path: String)
signal show_load_program_menu
signal program_loaded
var is_program_loaded: bool

signal show_settings_menu

signal cycle_changed
signal reset_button_pressed
signal show_menu(value: bool)
signal close_menu

signal expand_stage(stage_number: int)
var previous_expanded_stage: int
var current_expanded_stage: int = -1:
	set(value):
		previous_expanded_stage = current_expanded_stage
		current_expanded_stage = value
		current_expanded_stage_updated.emit()

signal current_expanded_stage_updated
var is_stage_tweening: bool = false
signal stage_tween_finished(stage: STAGES)
signal components_tween_finished
var is_components_tween_finished:= false
signal can_click_updated(value: bool)
var tweened_stage_sizes: Array[float] = []
var current_stage_sizes: Array[float] = [0,0,0,0,0]
signal current_stage_sizes_updated(stage:int)
var can_click:= true:
	set(value):
		if value == can_click:
			return
		if !value:
			if timer != null:
				timer.timeout.disconnect(_on_timer_timeout)
			timer = get_tree().create_timer(0.05)
			timer.timeout.connect(_on_timer_timeout)
		else:
			pass
		can_click = value
		can_click_updated.emit(value)

var timer: SceneTreeTimer = null

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
# notify changes to cpu settings
signal branch_stage_changed(value: int)
var branch_stage: int
signal branch_type_changed(value: int)
var branch_type: int # move to configManager keep copy of fields in memory?
signal hdu_available_changed(value: int)
signal fu_available_changed(value: int)
# notify changes to window scaling
signal window_scaling_changed(value: int)


func _ready():
	stage_tween_finished.connect(_on_stage_tween_finished)


func _on_stage_tween_finished(_stage):
	pass#can_click = true

func _on_timer_timeout():
	can_click = true


func update_current_stage_sizes(value: float, stage: int):
	var stage_size_type: int
	if Globals.current_expanded_stage == -1:
		stage_size_type = 0
	elif Globals.current_expanded_stage == stage:
		stage_size_type = 1 if stage != 4 else 3
	else:
		stage_size_type = 2
	if abs(value - tweened_stage_sizes[stage_size_type]) > 2:
		return
	current_stage_sizes[stage] = value
	current_stage_sizes_updated.emit(stage)

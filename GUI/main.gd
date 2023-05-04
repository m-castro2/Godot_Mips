extends Control

@onready var pipelinedWrapper: PipelinedWrapper = $PipelinedWrapper
@onready var pipeline: Control = %Pipeline
@onready var menu: Control = $Menu
var program_loaded: bool = false

const load_program_menu: PackedScene = preload("res://MenuInfo.tscn")
const component_info_window: PackedScene = preload("res://component_info_window.tscn")

func _ready() -> void:
	Globals.show_load_program_menu.connect(_on_show_load_program_menu)
	Globals.load_program_pressed.connect(_on_load_program_pressed)
	Globals.show_instructions_memory.connect(_on_show_instructions_memory)
	DisplayServer.window_set_min_size(Vector2(1152, 648))


func update_cpu_info() -> void:
	pass


func _on_load_program_pressed(file_path: String) -> void:
	if program_loaded:
		pipelinedWrapper.reset_cpu()
	
	program_loaded = pipelinedWrapper.load_program(ProjectSettings.globalize_path(file_path))
	if program_loaded and pipelinedWrapper.is_ready():
		%NextCycle.disabled = false
		%RunProgram.disabled = false
		%PreviousCycle.disabled = false
		%ShowMemory.disabled = false
		%Reset.disabled = false
		
		update_cpu_info()
		pipeline.add_instructions(pipelinedWrapper.instructions)
		StageControl.update_instruction_map(pipelinedWrapper.instructions, pipelinedWrapper.loaded_instructions, pipelinedWrapper.diagram)
	
	else:
		print("Error loading program")

func _on_next_cycle_pressed() -> void:
	pipelinedWrapper.next_cycle()
	update_cpu_info()
	Globals.current_cycle += 1
	StageControl.update_instruction_map(pipelinedWrapper.instructions, pipelinedWrapper.loaded_instructions, pipelinedWrapper.diagram)


func _on_run_program_pressed() -> void:
	while pipelinedWrapper.is_ready():
		pipelinedWrapper.next_cycle()
	update_cpu_info()
	Globals.current_cycle = pipelinedWrapper.cpu_info["Cycles"]
	StageControl.update_instruction_map(pipelinedWrapper.instructions, pipelinedWrapper.loaded_instructions, pipelinedWrapper.diagram)


func _on_reset_pressed() -> void:
	pipelinedWrapper.reset_cpu()
	pipeline.clear_instructions()
	update_cpu_info()


func _on_previous_cycle_pressed() -> void:
	pipelinedWrapper.previous_cycle()
	update_cpu_info()
	Globals.current_cycle -= 1
	StageControl.update_instruction_map(pipelinedWrapper.instructions, pipelinedWrapper.loaded_instructions, pipelinedWrapper.diagram)


func _on_show_memory_pressed() -> void:
	pipelinedWrapper.show_memory()


func _on_menu_button_pressed() -> void:
	menu.show_menu()


func _input(_event: InputEvent) -> void:
	if menu.visible and Input.is_action_just_pressed("Click") \
	and !is_mouse_in_node(menu.position, menu.size) and Globals.can_instantiate_load_menu:
		menu.hide_menu()


func is_mouse_in_node(p_position:Vector2, p_size:Vector2) -> bool:
	var mouse_position:Vector2 = get_global_mouse_position()
	if (p_position.x < mouse_position.x and mouse_position.x < (p_position.x + p_size.x)) \
	and (p_position.y < mouse_position.y and mouse_position.y < (p_position.y + p_size.y)):
		return true
	return false 


func _on_show_load_program_menu() -> void:
	if Globals.can_instantiate_load_menu:
		add_child(load_program_menu.instantiate())


func _on_show_instructions_memory() -> void:
	var window = component_info_window.instantiate()
	add_child(window)
	window.add_info(pipelinedWrapper.instructions, Globals.component_type.InstructionsMemory)

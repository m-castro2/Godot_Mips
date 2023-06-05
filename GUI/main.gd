extends Control

@onready var pipelinedWrapper: PipelinedWrapper = $PipelinedWrapper
@onready var pipeline: Control = %Pipeline
@onready var menu: Control = $Menu
var program_loaded: bool = false

const load_program_menu: PackedScene = preload("res://MenuInfo.tscn")
const settings_menu: PackedScene = preload("res://settings.tscn")
const component_info_window: PackedScene = preload("res://component_info_window.tscn")

func _ready() -> void:
	Globals.show_load_program_menu.connect(_on_show_load_program_menu)
	Globals.show_settings_menu.connect(_on_show_settings_menu)
	Globals.load_program_pressed.connect(_on_load_program_pressed)
	DisplayServer.window_set_min_size(Vector2(1152, 648))
	copy_test_files()


func copy_test_files():
	var path: String = OS.get_user_data_dir() + "testdata"
	var target: DirAccess = DirAccess.open(path)
	if target: # remove existing files in case theres been changes
		target.list_dir_begin()
		var filename: String = target.get_next()
		while filename != "":
			target.remove(filename)
			filename = target.get_next()
	DirAccess.open("user://").make_dir("user://testdata")
	
	var source: DirAccess = DirAccess.open("res://testdata")
	source.list_dir_begin()
	var filename: String = source.get_next()
	while filename != "":
		source.copy("res://testdata/" + filename, "user://testdata/" + filename)
		filename = source.get_next()


func update_cpu_info() -> void:
	pass


func _on_load_program_pressed(file_path: String) -> void:
	if program_loaded:
		_on_reset_pressed()
	
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
		Globals.program_loaded.emit()
	
	else:
		print("Error loading program")

func _on_next_cycle_pressed() -> void:
	if pipelinedWrapper.is_ready():
		pipelinedWrapper.next_cycle()
		update_cpu_info()
		Globals.current_cycle = pipelinedWrapper.cpu_info["Cycles"]
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
	Globals.current_cycle = 0
	StageControl.reset()


func _on_previous_cycle_pressed() -> void:
	if Globals.current_cycle > 0:
		pipelinedWrapper.previous_cycle()
		update_cpu_info()
		Globals.current_cycle = pipelinedWrapper.cpu_info["Cycles"]
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
	if Globals.active_menu != "load_program":
		add_child(load_program_menu.instantiate())
		var settings = get_node_or_null("/root/Control/Settings")
		if settings:
			remove_child(settings)

func _on_show_settings_menu() -> void:
	if Globals.active_menu != "settings":
		add_child(settings_menu.instantiate())
		var load_program = get_node_or_null("/root/Control/MenuInfo")
		if load_program:
			remove_child(load_program)


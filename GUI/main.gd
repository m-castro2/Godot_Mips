extends Control

@onready var pipelinedWrapper = PipelinedWrapper
@onready var pipeline: Control = %Pipeline
@onready var menu: Control = $Menu
@onready var exception_dialog = $AcceptDialog
var program_loaded: bool = false

#const load_program_menu: PackedScene = preload("res://MenuInfo.tscn")
#const settings_menu: PackedScene = preload("res://settings.tscn")
#const component_info_window: PackedScene = preload("res://component_info_window.tscn")


@onready var control_buttons_h_box_container = $VBoxContainer/ControlButtonsHBoxContainer
@onready var cycle_label: Label = $VBoxContainer/ControlButtonsHBoxContainer/CycleLabel
@onready var reset: Button = %Reset
@onready var previous_cycle: Button = %PreviousCycle
@onready var next_cycle: Button = %NextCycle
@onready var run_program: Button = %RunProgram

enum WindowScaling {IGNORE, SCALE}
var window_scaling: WindowScaling

const base_control_size:= 50
const base_button_size:= Vector2(150, 40)


func _ready() -> void:
	Globals.show_load_program_menu.connect(_on_show_load_program_menu)
	Globals.show_settings_menu.connect(_on_show_settings_menu)
	Globals.load_program_pressed.connect(_on_load_program_pressed)
	DisplayServer.window_set_min_size(Vector2(1152, 648))
	
	if !OS.has_feature("web") and !OS.has_feature("android"):
		restore_window_settings()
		copy_test_files()
	
	Globals.fu_available_changed.connect(_on_Globals_fu_available_changed)
	Globals.hdu_available_changed.connect(_on_Globals_hdu_available_changed)
	Globals.branch_stage_changed.connect(_on_Globals_branch_stage_changed)
	Globals.branch_type_changed.connect(_on_Globals_branch_type_changed)
	Globals.window_scaling_changed.connect(_on_Globals_window_scaling_changed)
	_on_Globals_window_scaling_changed(ConfigManager.get_value("Settings/UI", "scaling"))
	
	# Cycle label
	Globals.cycle_changed.connect(_on_Globals_cycle_changed)
	Globals.instructions_panel_resized.connect(_on_Globals_instructions_panel_resized)


func copy_test_files():
	var path: String = OS.get_user_data_dir() + "testdata"
	var target: DirAccess = DirAccess.open(path)
	var filename:String
	if target: # remove existing files in case theres been changes
		target.list_dir_begin()
		filename = target.get_next()
		while filename != "":
			target.remove(filename)
			filename = target.get_next()
	DirAccess.open("user://").make_dir("user://testdata")
	var source: DirAccess = DirAccess.open("res://testdata")
	source.list_dir_begin()
	filename = source.get_next()
	while filename != "":
		if filename.get_extension() not in ["s", "desc"]:
			filename = source.get_next()
			continue
		source.copy("res://testdata/" + filename, "user://testdata/" + filename)
		filename = source.get_next()


func update_cpu_info() -> void:
	pass


func _on_load_program_pressed(file_path: String) -> void:
	if program_loaded:
		_on_reset_pressed()
	
	if OS.has_feature("web") or OS.has_feature("android"):
		var resource: ProgramMemory = load("res://testdata/" + file_path.get_file().left(-2) + ".tres")
		resource.set_memory(resource.memory_string)
		program_loaded = pipelinedWrapper.load_program(file_path, false, resource.memory)
	else:
		program_loaded = pipelinedWrapper.load_program(ProjectSettings.globalize_path(file_path), true, {})
		if program_loaded and OS.has_feature("editor"): #if run from editor
			create_memory_backup(file_path)
	
	#set up cpu options
	configure_cpu()
	
	if program_loaded and pipelinedWrapper.is_ready():
		next_cycle.disabled = false
		run_program.disabled = false
		previous_cycle.disabled = true
		%ShowMemory.disabled = false
		reset.disabled = false
		
		update_cpu_info()
		var desc_file:= FileAccess.open(file_path.get_basename() + ".desc", FileAccess.READ)
		pipeline.add_instructions(pipelinedWrapper.instructions, desc_file.get_as_text() if desc_file else "")
		StageControl.update_instruction_map(pipelinedWrapper.instructions, \
			pipelinedWrapper.loaded_instructions, pipelinedWrapper.diagram)
		LineManager.activate_lines(pipelinedWrapper.stage_signals_map)
		Globals.is_program_loaded = true
		Globals.program_loaded.emit()
	
	else:
		pipeline.add_instructions([], "")
		next_cycle.disabled = true
		run_program.disabled = true
		previous_cycle.disabled = true
		%ShowMemory.disabled = true
		reset.disabled = true
		exception_dialog.add_info({"err_no": -1, "err_v": file_path})
		print("Error loading program")


func _on_next_cycle_pressed() -> void:
	pipelinedWrapper.next_cycle()
	if pipelinedWrapper.exception_info.is_empty():
		update_cpu_info()
		Globals.current_cycle = pipelinedWrapper.cpu_info["Cycles"]
		StageControl.update_instruction_map(pipelinedWrapper.instructions, \
			pipelinedWrapper.loaded_instructions, pipelinedWrapper.diagram)
		LineManager.activate_lines(pipelinedWrapper.stage_signals_map)
	
	else: # exception caught
		handle_exception()
		update_cpu_info()
		Globals.current_cycle = pipelinedWrapper.cpu_info["Cycles"]
		StageControl.update_instruction_map(pipelinedWrapper.instructions, \
			pipelinedWrapper.loaded_instructions, pipelinedWrapper.diagram)
		LineManager.activate_lines(pipelinedWrapper.stage_signals_map)
	
	if !pipelinedWrapper.is_ready():
		next_cycle.disabled = true
		run_program.disabled = true
	previous_cycle.disabled = false


func _on_run_program_pressed() -> void:
	while pipelinedWrapper.is_ready() and pipelinedWrapper.exception_info.is_empty():
		_on_next_cycle_pressed()
		#pipelinedWrapper.next_cycle()
		
	return # use gui's next cycle method to show stage colors and lines if exception is present?
	
	if pipelinedWrapper.exception_info.is_empty():
		update_cpu_info()
		Globals.current_cycle = pipelinedWrapper.cpu_info["Cycles"]
		StageControl.update_instruction_map(pipelinedWrapper.instructions, \
				pipelinedWrapper.loaded_instructions, pipelinedWrapper.diagram)
		LineManager.activate_lines(pipelinedWrapper.stage_signals_map)
	
	else: # exception caught
		handle_exception()
	
	if !pipelinedWrapper.is_ready():
		next_cycle.disabled = true
		run_program.disabled = true


func _on_reset_pressed() -> void:
	pipelinedWrapper.reset_cpu(true, false)
	update_cpu_info()
	Globals.current_cycle = 0
	StageControl.reset()
	Globals.reset_button_pressed.emit()
	
	previous_cycle.disabled = true
	next_cycle.disabled = false
	run_program.disabled = false


func _on_previous_cycle_pressed() -> void:
	if !pipelinedWrapper.is_ready():
		next_cycle.disabled = false
		run_program.disabled = false
	
	if Globals.current_cycle > 0:
		pipelinedWrapper.previous_cycle()
		update_cpu_info()
		Globals.current_cycle = pipelinedWrapper.cpu_info["Cycles"]
		StageControl.update_instruction_map(pipelinedWrapper.instructions, \
			pipelinedWrapper.loaded_instructions, pipelinedWrapper.diagram)
		LineManager.activate_lines(pipelinedWrapper.stage_signals_map)
	
	if !Globals.current_cycle:
		previous_cycle.disabled = true
	
	next_cycle.disabled = false
	run_program.disabled = false


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
	$BaseMenu.instantiate_load_program_menu()
	$BaseMenu.visible = true
	return
	#if Globals.active_menu != "load_program":
		#add_child(load_program_menu.instantiate())
		#var settings = get_node_or_null("/root/Control/Settings")
		#if settings:
			#remove_child(settings)


func _on_show_settings_menu() -> void:
	$BaseMenu.instantiate_settings_menu()
	$BaseMenu.visible = true
	return
	#if Globals.active_menu != "settings":
		#add_child(settings_menu.instantiate())
		#var load_program = get_node_or_null("/root/Control/MenuInfo")
		#if load_program:
			#remove_child(load_program)


func _on_Globals_fu_available_changed(value: int) -> void:
	if program_loaded:
		pipelinedWrapper.enable_forwarding_unit(value)
		_on_reset_pressed()


func _on_Globals_hdu_available_changed(value: int) -> void:
	if program_loaded:
		pipelinedWrapper.enable_hazard_detection_unit(value)
		_on_reset_pressed()


func _on_Globals_branch_stage_changed(value: int) -> void:
	if program_loaded:
		# value is optionButton index, 0 for ID, 1 for MEM
		pipelinedWrapper.change_branch_stage(3 if value else 1)
		_on_reset_pressed()
		Globals.branch_stage = value


func _on_Globals_branch_type_changed(value: int) -> void:
	if program_loaded:
		value += 1 # flush was removed so now non taken is 0 instead of 1
		pipelinedWrapper.change_branch_type(value)
		_on_reset_pressed()
		Globals.branch_type = value


func configure_cpu():
	_on_Globals_branch_stage_changed(ConfigManager.get_value("Settings/CPU", "branch_stage"))
	_on_Globals_branch_type_changed(ConfigManager.get_value("Settings/CPU", "branch_type"))
	_on_Globals_fu_available_changed(ConfigManager.get_value("Settings/CPU", "fu_enabled"))
	_on_Globals_hdu_available_changed(ConfigManager.get_value("Settings/CPU", "hdu_enabled"))


func _on_Globals_window_scaling_changed(value: int) -> void:
	window_scaling = value as WindowScaling
#	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS if value \
#			else Window.CONTENT_SCALE_MODE_DISABLED
	_resize_ui(size if value else Globals.base_viewport_size)


func handle_exception() -> void:
	#exception_dialog.add_info(pipelinedWrapper.exception_info)
	
	$AcceptDialog.add_info(pipelinedWrapper.exception_info)
	next_cycle.disabled = true
	run_program.disabled = true


func _on_Globals_cycle_changed() -> void:
	var cycle:= str(Globals.current_cycle)
	cycle_label.text = "Cycle " + cycle
	var space_padding_count:= 4
	while cycle.length() < space_padding_count:
		cycle_label.text += " "
		space_padding_count -= 1


func _on_Globals_instructions_panel_resized(width: int) -> void:
	cycle_label.custom_minimum_size.x = width


func _on_resized():
	if OS.has_feature("android"):
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP_HEIGHT
		return
	if !window_scaling:
		return
	_resize_ui(size)


func _resize_ui(viewport_size: Vector2) -> void:
	if (viewport_size.x / viewport_size.y >= (Globals.base_viewport_size.x / Globals.base_viewport_size.y)):
		#only update font size if viewport is at least as wide as original aspect ratio
		var font_size: int = max(12, 1.6 * viewport_size.y / 72)
		theme.set_font_size("font_size", "Label", font_size)
		theme.set_font_size("font_size", "Button", font_size)
		theme.set_font_size("font_size", "PopupMenu", font_size)
		theme.set_font_size("font_size", "TabContainer", font_size)
		theme.set_font_size("font_size", "CodeEdit", font_size)
		theme.set_font_size("normal_font_size", "RichTextLabel", font_size)
		theme.set_font_size("title_font_size", "Window", font_size)
		theme.set_font_size("font_size", "LineEdit", font_size)
	
	var mux_button_stylebox: StyleBoxFlat = theme.get_stylebox("disabled", "MuxButton")
	mux_button_stylebox.set_corner_radius_all(15 * min(viewport_size.x / Globals.base_viewport_size.x, viewport_size.y / Globals.base_viewport_size.y))
	theme.set_stylebox("disabled", "MuxButton", mux_button_stylebox)
	Globals.viewport_resized.emit(viewport_size)
	Globals.alu_update_svg.emit(viewport_size)
	
	resize_control_buttons(viewport_size)


func resize_control_buttons(viewport_size: Vector2) -> void:
	var new_scale:= viewport_size / Globals.base_viewport_size
	control_buttons_h_box_container.custom_minimum_size.y = base_control_size * new_scale.y
	reset.custom_minimum_size = base_button_size * new_scale
	previous_cycle.custom_minimum_size = base_button_size * new_scale
	next_cycle.custom_minimum_size = base_button_size * new_scale
	run_program.custom_minimum_size = base_button_size * new_scale


func _on_load_program_button_pressed():
	Globals.show_load_program_menu.emit()


func _on_settings_button_pressed():
	Globals.show_settings_menu.emit()

func create_memory_backup(file_path: String):
	if !Globals.program_loaded:
		return
	
	var memory_string:= PipelinedWrapper.create_memory_backup()
	var rows:= memory_string.split("\n")
	var output_string: String = ""
	
	for row in rows:
		if row == "":
			continue
		output_string += row + ","
	
	output_string = output_string.left(-1) #remove last ,
	
	var program_memory:= ProgramMemory.new()
	program_memory.memory_string = output_string
	program_memory.resource_path = "res://testdata/" + file_path.get_file().left(-2) + ".tres"
	var err = ResourceSaver.save(program_memory, program_memory.resource_path)


func _notification(what):
	if OS.has_feature("web") or OS.has_feature("android"):
		return
	
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		ConfigManager.update_value("Window", "screen_count", DisplayServer.get_screen_count())
		ConfigManager.update_value("Window", "screen", DisplayServer.window_get_current_screen())
		ConfigManager.update_value("Window", "size", DisplayServer.window_get_size())
		ConfigManager.update_value("Window", "position", DisplayServer.window_get_position())


func restore_window_settings():
	var screen_count: int = ConfigManager.get_value("Window", "screen_count")
	var screen: int = ConfigManager.get_value("Window", "screen")
	var win_size: Vector2i = ConfigManager.get_value("Window", "size")
	var win_position: Vector2i = ConfigManager.get_value("Window", "position")
	if screen_count == DisplayServer.get_screen_count():
		# if there is a different number of screens ignore settings
		DisplayServer.window_set_current_screen(screen)
		if win_size != Vector2i.ZERO:
			DisplayServer.window_set_size(ConfigManager.get_value("Window", "size"))
		if win_position != Vector2i.ZERO:
			DisplayServer.window_set_position(ConfigManager.get_value("Window", "position"))

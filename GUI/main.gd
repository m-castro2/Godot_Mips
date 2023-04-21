extends Control

@onready var pipelinedWrapper: PipelinedWrapper = $PipelinedWrapper
@onready var pipeline: Control = %Pipeline
@onready var menu: Control = $Menu
var program_loaded: bool = false

func _ready():
	Globals.load_program_pressed.connect(self._on_load_program_pressed)


func update_cpu_info():
	pass


func _on_load_program_pressed():
	if program_loaded:
		pipelinedWrapper.reset_cpu()
	
	program_loaded = pipelinedWrapper.load_program(ProjectSettings.globalize_path("res://testdata/asm1.s"))
	if program_loaded and pipelinedWrapper.is_ready():
		%NextCycle.disabled = false
		%RunProgram.disabled = false
		%PreviousCycle.disabled = false
		%ShowMemory.disabled = false
		%Reset.disabled = false
		
		update_cpu_info()
		pipeline.add_instructions(pipelinedWrapper.instructions)
	
	else:
		print("Error loading program")

func _on_next_cycle_pressed():
	pipelinedWrapper.next_cycle()
	update_cpu_info()


func _on_run_program_pressed():
	while pipelinedWrapper.is_ready():
		pipelinedWrapper.next_cycle()
	update_cpu_info()


func _on_reset_pressed():
	pipelinedWrapper.reset_cpu()
	pipeline.clear_instructions()
	update_cpu_info()


func _on_previous_cycle_pressed():
	pipelinedWrapper.previous_cycle()
	update_cpu_info()


func _on_show_memory_pressed():
	pipelinedWrapper.show_memory()


func _on_menu_button_pressed():
	menu.show_menu()

func _input(_event: InputEvent):
	if menu.visible and Input.is_action_just_pressed("Click") and !is_mouse_in_node(menu.position, menu.size):
		menu.hide_menu()


func is_mouse_in_node(p_position:Vector2, p_size:Vector2):
	var mouse_position = get_global_mouse_position()
	if (p_position.x < mouse_position.x and mouse_position.x < (p_position.x + p_size.x)) \
	and (p_position.y < mouse_position.y and mouse_position.y < (p_position.y + p_size.y)):
		return true
	return false 

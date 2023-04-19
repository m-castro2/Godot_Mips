extends Control

@onready var pipelinedWrapper: PipelinedWrapper = $PipelinedWrapper
var program_loaded: bool = false

func _ready():
	Globals.load_program_pressed.connect(self._on_load_program_pressed)


func update_cpu_info():
	$VBoxContainer/CpuInfoScrollContainer.update_cpu_info(pipelinedWrapper.cpu_info)


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
	update_cpu_info()


func _on_previous_cycle_pressed():
	pipelinedWrapper.previous_cycle()
	update_cpu_info()


func _on_show_memory_pressed():
	pipelinedWrapper.show_memory()

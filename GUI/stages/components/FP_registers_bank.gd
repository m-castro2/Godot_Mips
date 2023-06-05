extends MainComponent

@onready var pipelinedWrapper: PipelinedWrapper = get_tree().root.get_child(Globals.singleton_number).get_child(0)


func get_info():
	var info: Array
	for register in pipelinedWrapper.cpu_info["Registers"]["fRegisters"]:
		#TODO register name
		info.push_back(register)
	for register in pipelinedWrapper.cpu_info["Registers"]["dRegisters"]:
		#TODO register name
		info.push_back(register)
	return info


func show_info_window():
	if is_window_active:
		return
	var window = WINDOW.instantiate()
	add_child(window)
	window.show_info()

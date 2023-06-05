extends MainComponent

@onready var pipelinedWrapper: PipelinedWrapper = get_tree().root.get_child(Globals.singleton_number).get_child(0)

func get_info():
	var info: Array
	for instruction in pipelinedWrapper.instructions:
		info.push_back(instruction[1])
	return info

func show_info_window():
	if is_window_active:
		return
	var window = WINDOW.instantiate()
	add_child(window)
	window.show_info()

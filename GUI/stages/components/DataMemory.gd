extends MainComponent

#@onready var pipelinedWrapper: PipelinedWrapper = get_tree().root.get_child(Globals.singleton_number).get_child(0)


func get_info():
	if !Globals.is_program_loaded:
		return
	
	var info: Array = PipelinedWrapper.get_memory_data()
	return info


func show_info_window():
	if is_window_active:
		return
	var window = WINDOW.instantiate()
	add_child(window)
	window.show_info()

class_name PC extends MainComponent

var info


func _ready():
	Globals.cycle_changed.connect(_on_cycle_changed)
	info = PipelinedWrapper.cpu_info["PCValue"]
	super._ready()


func _on_cycle_changed():
	info = PipelinedWrapper.cpu_info["PCValue"]


func get_info():
	return ["PC: " + info]


func show_info_window():
	return
	#if is_window_active:
		#return
	#var window = WINDOW.instantiate()
	#add_child(window)
	#window.show_info()

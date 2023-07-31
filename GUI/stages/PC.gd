class_name PC extends MainComponent

var info

@onready var pipelinedWrapper = get_tree().root.get_child(Globals.singleton_number).get_child(0) ## adding singletons breaks this

func _ready():
	Globals.cycle_changed.connect(_on_cycle_changed)
	info = pipelinedWrapper.cpu_info["PCValue"]
	super._ready()


func _on_cycle_changed():
	info = pipelinedWrapper.cpu_info["PCValue"]


func get_info():
	return ["PC: " + info]


func show_info_window():
	if is_window_active:
		return
	var window = WINDOW.instantiate()
	add_child(window)
	window.show_info()

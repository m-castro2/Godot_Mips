extends ClickableComponent

var info

@onready var pipelinedWrapper = get_tree().root.get_child(3).get_child(0) ## adding singletons breaks this

func _ready():
	Globals.cycle_changed.connect(_on_cycle_changed)
	info = pipelinedWrapper.cpu_info["PCValue"]


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

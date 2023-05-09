extends Button

var info

@onready var pipelinedWrapper = get_tree().root.get_child(2).get_child(0)

func _ready():
	Globals.cycle_changed.connect(_on_cycle_changed)
	info = pipelinedWrapper.cpu_info["PCValue"]


func _on_cycle_changed():
	info = pipelinedWrapper.cpu_info["PCValue"]


func get_info():
	return ["PC: " + info]

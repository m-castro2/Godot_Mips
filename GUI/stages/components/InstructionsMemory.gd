extends MainComponent

@onready var pipelinedWrapper: PipelinedWrapper = get_tree().root.get_child(2).get_child(0)

func get_info():
	var info: Array
	for instruction in pipelinedWrapper.instructions:
				info.push_back(instruction[1])
	return info

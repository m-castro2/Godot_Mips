extends Button

@export var inputs_number: int
@export var sources: Array[NodePath]

var sources_info: Array

func get_info():
	sources_info.clear()
	for i in range(0, sources.size()):
		var node = get_node(sources[i])
		if node is Label:
			sources_info.append("Input " + str(i) +": " + node.text)
		else:
			sources_info.append("Input " + str(i) +": " + node.info)
	return sources_info

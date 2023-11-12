extends Resource
class_name ProgramMemory

@export var memory_string: String

@export var memory: Dictionary

func set_memory(memory_string: String) -> void:
	#remove brackets
	memory_string = memory_string.replace("[", "")
	memory_string = memory_string.replace("]", "")
	memory_string = memory_string.to_upper()
	#separate values
	var rows: PackedStringArray = memory_string.split(",")
	for row in rows:
		var values: PackedStringArray = row.split(" ")
		var arr: Array = []
		for i in range(values.size()):
			if (i > 0):
				arr.push_back(values[i])
		memory[values[0]] = arr

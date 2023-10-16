extends Window

@onready var grid_container = $ScrollContainer/GridContainer
var labels: Array[Label]

func _on_close_requested():
	visible = false


func _on_focus_exited():
	visible = false


func add_info():
	visible = true
	if !Globals.is_program_loaded:
		return
	
	var memory_data:= PipelinedWrapper.get_memory_data()
	while labels.size() != memory_data.size():
		var label:= Label.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		grid_container.add_child(label)
		labels.push_back(label)
	
	for label in labels:
		if label.get_index() % 5 == 0:
			label.text = "[" + memory_data[label.get_index()] + "]"
		else:
			label.text = memory_data[label.get_index()]

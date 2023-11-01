extends BaseWindow

@onready var grid_container = $PanelContainer/ScrollContainer/GridContainer
var labels: Array[Label]

#@onready var base_window_scale = Globals.base_viewport_size / Vector2(min_size)

#func _enter_tree():
#	super._enter_tree()

func _ready():
	
	base_window_scale = Globals.base_viewport_size / Vector2(min_size)
	super._ready()


func add_info():
	visible = true
	Globals.close_window_handled = false
	
	if !Globals.is_program_loaded:
		return
	
	var memory_data:= PipelinedWrapper.get_memory_data()
	if labels.size() < memory_data.size():
		while labels.size() != memory_data.size():
			var label:= Label.new()
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			grid_container.add_child(label)
			labels.push_back(label)
	
	for label in labels:
		if label.get_index() > memory_data.size()-1:
			label.text = ""
		elif label.get_index() % 5 == 0:
			label.text = "[" + memory_data[label.get_index()] + "]"
		else:
			label.text = memory_data[label.get_index()]

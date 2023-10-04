extends Window

@onready var v_box_container = $VBoxContainer
@onready var grid_container = $VBoxContainer/ScrollContainer/GridContainer

func _ready():
	_on_size_changed()
	var name_array: Array = PipelinedWrapper.get_register_names()
	for name in name_array:
		var name_label: Label = Label.new()
		var value_label: Label = Label.new()
		name_label.text = name
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.theme_type_variation = "GridLabel"
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		value_label.text = name
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value_label.theme_type_variation = "GridLabel"
		value_label.size_flags_stretch_ratio = 1.75
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		grid_container.add_child(name_label)
		grid_container.add_child(value_label)


func _on_size_changed():
	if v_box_container:
		v_box_container.size = size


func add_info():
	visible = true
	for i in range(1, 64, 2):
		grid_container.get_child(i).text = PipelinedWrapper.cpu_info["Registers"]["iRegisters"][ceil(i % 32)]
		


func _on_close_requested():
	visible = false


func _on_focus_exited():
	visible = false

extends Window

@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var grid_container: GridContainer = $VBoxContainer/ScrollContainer/GridContainer
@onready var parent: MainComponent = get_parent()

func _ready():
	Globals.recenter_window.connect(_on_recenter_window)
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
		
	position.x = clamp(parent.global_position.x + parent.size.x/2 - size.x/2, 0, DisplayServer.window_get_size().x - size.x -10) # -10 window border default theme
	position.y = clamp(parent.global_position.y + parent.size.y/2 - size.y/2, 40, DisplayServer.window_get_size().y - size.y -10)
	title = parent.window_title


func _on_size_changed():
	if v_box_container:
		v_box_container.size = size


func add_info():
	visible = true
	for i in range(1, 64, 2):
		var value: String = PipelinedWrapper.cpu_info["Registers"]["iRegisters"][i/2]
		grid_container.get_child(i).text = value
		if value == "00000000":
			(grid_container.get_child(i) as Label).add_theme_color_override("font_color", Color.DIM_GRAY)
			(grid_container.get_child(i-1) as Label).add_theme_color_override("font_color", Color.DIM_GRAY)
		else:
			(grid_container.get_child(i) as Label).remove_theme_color_override("font_color")
			(grid_container.get_child(i-1) as Label).remove_theme_color_override("font_color")
		


func _on_close_requested():
	visible = false


func _on_focus_exited():
	visible = false


func _on_recenter_window():
	position.x = clamp(parent.global_position.x + parent.size.x/2 - size.x/2, 0, DisplayServer.window_get_size().x - size.x -10) # -10 window border default theme
	position.y = clamp(parent.global_position.y + parent.size.y/2 - size.y/2, 40, DisplayServer.window_get_size().y - size.y -10)

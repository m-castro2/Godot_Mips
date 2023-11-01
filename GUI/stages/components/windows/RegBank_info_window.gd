extends BaseWindow

@onready var v_box_container: VBoxContainer = $PanelContainer/VBoxContainer
@onready var parent: MainComponent = get_parent() as MainComponent
@onready var name_v_box_container = $PanelContainer/VBoxContainer/ScrollContainer/HBoxContainer/NameVBoxContainer
@onready var value_v_box_container = $PanelContainer/VBoxContainer/ScrollContainer/HBoxContainer/ValueVBoxContainer

func _ready():
	Globals.recenter_window.connect(_on_recenter_window)
	_on_size_changed()
	
	var name_array: Array = PipelinedWrapper.get_register_names()
	for register_name in name_array:
		var name_label: Label = Label.new()
		var value_label: Label = Label.new()
		name_label.text = register_name
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.theme_type_variation = "GridLabel"
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		#value_label.text = name
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value_label.theme_type_variation = "GridLabel"
		#value_label.size_flags_stretch_ratio = 5
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		value_label.custom_minimum_size.y = 25
		name_label.custom_minimum_size.y = 25
		name_v_box_container.add_child(name_label)
		value_v_box_container.add_child(value_label)
		
	position.x = clamp(parent.global_position.x + parent.size.x/2 - size.x/2, 0, DisplayServer.window_get_size().x - size.x -10) # -10 window border default theme
	position.y = clamp(parent.global_position.y + parent.size.y/2 - size.y/2, 40, DisplayServer.window_get_size().y - size.y -10)
	title = parent.window_title
	
	base_window_scale = Globals.base_viewport_size / Vector2(min_size)
	super._ready()


func _on_size_changed():
	return
	if v_box_container:
		v_box_container.set_deferred("size", size)
#		v_box_container.size = size


func add_info():
	visible = true
	Globals.close_window_handled = false
	for i in range(0, 32):
		var value: String = PipelinedWrapper.cpu_info["Registers"]["iRegisters"][i]
		value_v_box_container.get_child(i).text = value
		if value == "00000000":
			(value_v_box_container.get_child(i) as Label).add_theme_color_override("font_color", Color.DIM_GRAY)
			(name_v_box_container.get_child(i) as Label).add_theme_color_override("font_color", Color.DIM_GRAY)
		else:
			(value_v_box_container.get_child(i) as Label).remove_theme_color_override("font_color")
			(name_v_box_container.get_child(i) as Label).remove_theme_color_override("font_color")


func _on_recenter_window():
	position.x = clamp(parent.global_position.x + parent.size.x/2 - size.x/2, 0, DisplayServer.window_get_size().x - size.x -10) # -10 window border default theme
	position.y = clamp(parent.global_position.y + parent.size.y/2 - size.y/2, 40, DisplayServer.window_get_size().y - size.y -10)

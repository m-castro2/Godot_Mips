extends Panel

@onready var data_memory = $DataMemory
@onready var detailed_control = $DetailedControl

func show_detail(value: bool) -> void:
	detailed_control.visible = value


func calculate_positions():
	var control_size: Vector2 = detailed_control.size
	
	if data_memory:
		pass


func draw_lines():
	pass


func _on_data_memory_pressed():
	data_memory.show_info_window()


func _on_gui_input(_event):
	if Input.is_action_just_pressed("Click"):
		if Globals.close_window_handled:
			Globals.close_window_handled = false
		else:
			Globals.expand_stage.emit(3)

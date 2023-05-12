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

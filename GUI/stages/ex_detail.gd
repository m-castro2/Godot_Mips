extends Panel

@onready var detailed_control = $DetailedControl
@onready var alu = $ALU


func show_detail(value: bool) -> void:
	detailed_control.visible = value


func calculate_positions():
	var control_size: Vector2 = detailed_control.size
	
	if alu:
		pass


func draw_lines():
	pass


func _on_alu_pressed():
	alu.show_info_window()

extends Panel

@onready var mux = $Mux
@onready var detailed_control = $DetailedControl


func show_detail(value: bool) -> void:
	detailed_control.visible = value


func calculate_positions():
	var control_size: Vector2 = detailed_control.size
	
	if mux:
		pass


func draw_lines():
	pass


func _on_mux_pressed():
	mux.show_info_window()

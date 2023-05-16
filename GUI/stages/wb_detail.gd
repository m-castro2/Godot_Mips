extends Panel

@onready var mux = $Mux
@onready var detailed_control = $DetailedControl
@onready var input_0 = $Mux/Input0
@onready var input_1 = $Mux/Input1
@onready var input_2 = $Mux/Input2


func show_detail(value: bool) -> void:
	detailed_control.visible = value


func calculate_positions():
	var control_size: Vector2 = detailed_control.size
	
	if mux:
		input_0.position.y = mux.size.y *.1
		input_1.position.y = mux.size.y *.5
		input_2.position.y = mux.size.y *.9


func draw_lines():
	pass


func _on_mux_pressed():
	mux.show_info_window()

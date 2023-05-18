extends Panel

@onready var detailed_control = $DetailedControl
@onready var alu = $ALU
@onready var mux_rs = $DetailedControl/MuxRs
@onready var mux_rt = $DetailedControl/MuxRt
@onready var mux_imm = $DetailedControl/MuxImm
@onready var alu_control = $DetailedControl/AluControl
@onready var forwarding_unit = $DetailedControl/ForwardingUnit


func show_detail(value: bool) -> void:
	detailed_control.visible = value


func calculate_positions():
	var control_size: Vector2 = detailed_control.size
	
	if alu:
		mux_rs.position = Vector2(alu.position.x/2 - mux_rs.size.x/2, alu.position.y - 10)
		
		mux_rt.position = Vector2(mux_rs.position.x, alu.position.y + alu.size.y/2 - mux_rs.size.y/2)
		
		mux_imm.position = Vector2(mux_rt.position.x + mux_rt.size.x + (alu.position.x - mux_rt.position.x - mux_rt.size.x)/2 - mux_imm.size.x/2, \
			alu.position.y + alu.size.y - mux_imm.size.y)
		
		forwarding_unit.position = Vector2(detailed_control.size.x/2 - forwarding_unit.size.x/2,\
			detailed_control.size.y*.98 - forwarding_unit.size.y)
		
		alu_control.position = Vector2(mux_rs.position.x, \
			alu.position.y + alu.size.y + (forwarding_unit.position.y - alu.position.y - alu.size.y)/2 - alu_control.size.y/2)

func draw_lines():
	pass


func _on_alu_pressed():
	alu.show_info_window()


func _on_gui_input(_event):
	if Input.is_action_just_pressed("Click"):
		Globals.expand_stage.emit(2)

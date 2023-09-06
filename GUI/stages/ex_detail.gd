extends Panel

@onready var detailed_control = $DetailedControl
@onready var alu = $ALU
@onready var alu_control = $DetailedControl/AluControl
@onready var forwarding_unit = $DetailedControl/ForwardingUnit

# lines
@onready var pc = $DetailedControl/PC
@onready var reg_dst = $DetailedControl/RegDst
@onready var alu_ex_mem = $ALU/ALUExMem
@onready var rs_data_alu = $DetailedControl/RsData_ALU
@onready var rt_data_alu_2 = $DetailedControl/RtData_ALU2
@onready var imm_val_alu_2 = $DetailedControl/ImmVal_ALU2
@onready var rs_hdu = $DetailedControl/Rs_HDU
@onready var rt_hdu = $DetailedControl/Rt_HDU
@onready var alu_control_alu = $DetailedControl/ALUControl_ALU
@onready var rt_data_exmem = $DetailedControl/Rt_Data_EXMEM

@onready var lines: Array[Line2D] = [ pc, 
									reg_dst,
									alu_ex_mem,
									rs_data_alu,
									rt_data_alu_2,
									imm_val_alu_2,
									rs_hdu,
									rt_hdu,
									alu_control_alu,
									rt_data_exmem]

@onready var stage_color: Color = get_parent().get_parent().stage_color:
	set(value):
		stage_color = value
		for line in lines:
			line.line_color = value

var stage: Globals.STAGES = Globals.STAGES.EX


func _ready():
	LineManager.ex_line_active.connect(_on_LineManager_ex_line_active)
	show_lines()


func show_lines() -> void:
	## Not needed once CpuFlex manages which lines to show
	pass


func show_detail(value: bool) -> void:
	detailed_control.visible = true
	for child in detailed_control.get_children():
		if child is Button:
			child.visible = value or child.requested
		elif child is Line2D:
			child.draw_requested = value and child.active and get_parent().get_parent().expanded


func calculate_positions():
	%ALUOut.global_position = Vector2(global_position.x + size.x, $ALU/Output.global_position.y)
	
	%RtData.global_position = Vector2(global_position.x + size.x, size.y * .6)


func draw_lines():
	for line in lines:
		if line.active:
			line.add_points()
			line.animate_line()


func _on_alu_pressed():
	alu.show_info_window()


func _on_gui_input(_event):
	if Input.is_action_just_pressed("Click"):
		if Globals.close_window_handled:
			Globals.close_window_handled = false
		else:
			Globals.expand_stage.emit(2)


func _on_LineManager_ex_line_active(line: LineManager.ex_lines) -> void:
	match  line:
		LineManager.ex_lines.PC:
			pc.origin = get_node(LineManager.stage_register_path[1]).get("pc_2")
			pc.target = get_node(LineManager.stage_register_path[2]).get("pc")
			pc.active = true
			
		LineManager.ex_lines.RegDst:
			reg_dst.origin = get_node(LineManager.stage_register_path[1]).get("reg_dst_2")
			reg_dst.target = get_node(LineManager.stage_register_path[2]).get("reg_dst")
			reg_dst.active = true
			
		LineManager.ex_lines.ALUEXMEM:
			alu_ex_mem.active = true
			
		LineManager.ex_lines.RSDATA_ALU:
			rs_data_alu.origin = get_node(LineManager.stage_register_path[1]).get("rs_data_2")
			rs_data_alu.target = $ALU/UpperInput
			rs_data_alu.active = true
			
		LineManager.ex_lines.RTDATA_ALU2:
			rt_data_alu_2.origin = get_node(LineManager.stage_register_path[1]).get("rt_data_2")
			rt_data_alu_2.target = $ALU/LowerInput
			rt_data_alu_2.active = true
			
		LineManager.ex_lines.IMMVAL_ALU2:
			imm_val_alu_2.origin = get_node(LineManager.stage_register_path[1]).get("imm_value_2")
			imm_val_alu_2.target = $ALU/LowerInput
			imm_val_alu_2.active = true
			
		LineManager.ex_lines.RS_HDU:
			rs_hdu.origin = get_node(LineManager.stage_register_path[1]).get("rs_2")
			rs_hdu.target = $DetailedControl/ForwardingUnit/UpperInput
			rs_hdu.active = true
			
		LineManager.ex_lines.RT_HDU:
			rt_hdu.origin = get_node(LineManager.stage_register_path[1]).get("rt_2")
			rt_hdu.target = $DetailedControl/ForwardingUnit/LowerInput
			rt_hdu.active = true
			
		LineManager.ex_lines.ALUCONTROL_ALU:
			alu_control_alu.active = true
			
		LineManager.ex_lines.RTDATA_EXMEM:
			if imm_val_alu_2.active:
				rt_data_exmem.origin = imm_val_alu_2
			if rt_data_alu_2.active:
				rt_data_exmem.origin = rt_data_alu_2
			rt_data_exmem.target = get_node(LineManager.stage_register_path[2]).get("imm_value")
			rt_data_exmem.active = true

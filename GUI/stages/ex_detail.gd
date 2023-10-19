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
@onready var rs_fu = $DetailedControl/Rs_FU
@onready var rt_fu = $DetailedControl/Rt_FU
@onready var alu_control_alu = $DetailedControl/ALUControl_ALU
@onready var rt_data_exmem = $DetailedControl/Rt_Data_EXMEM
@onready var pc_add = $DetailedControl/PC_Add
@onready var imm_val_add = $DetailedControl/ImmVal_Add
@onready var fu_alu_1 = $DetailedControl/FU_ALU1
@onready var fu_alu_2 = $DetailedControl/FU_ALU2
@onready var fu_rt_data = $DetailedControl/FU_RTData
@onready var rt_data_exmem_base = $DetailedControl/Rt_Data_EXMEM_Base

@onready var fake_target = $DetailedControl/Fake_Target


@onready var lines: Array[Line2D] = [ pc, 
									reg_dst,
									alu_ex_mem,
									rs_data_alu,
									rt_data_alu_2,
									imm_val_alu_2,
									rs_fu,
									rt_fu,
									alu_control_alu,
									rt_data_exmem,
									pc_add,
									imm_val_add,
									fu_alu_1,
									fu_alu_2,
									fu_rt_data]

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
	return
	for child in detailed_control.get_children():
		if child is Button:
			child.visible = value or child.requested
		elif child is Line2D:
			child.draw_requested = value and child.active and get_parent().get_parent().expanded


func calculate_positions():
	%ALUOut.global_position = Vector2(global_position.x + size.x, $ALU/Output.global_position.y)
	
	%RtData.global_position = Vector2(global_position.x + size.x, size.y * .6)
	
	fake_target.global_position = get_node(LineManager.stage_register_path[1]).get("rt_data_2").global_position + Vector2(90,0)


func draw_lines():
	for line in lines:
		if line.active:
			line.add_points()
			line.animate_line()
			if line is OutsideLine2D:
				line.check_visibility(false, true)
			else:
				line.check_visibility(false)


func hide_lines() -> void:
	for line in lines:
		line.visible = false


func _on_alu_pressed():
	alu.show_info_window()


func _on_gui_input(_event) -> void:
	if !Globals.can_click and Globals.current_cycle:
		return
	if Input.is_action_just_pressed("Click"):
		Globals.can_click = false
		Input.flush_buffered_events()
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
			
		LineManager.ex_lines.RS_FU:
			rs_fu.origin = get_node(LineManager.stage_register_path[1]).get("rs_2")
			rs_fu.target = $DetailedControl/ForwardingUnit/Input1
			rs_fu.active = true
			
		LineManager.ex_lines.RT_FU:
			rt_fu.origin = get_node(LineManager.stage_register_path[1]).get("rt_2")
			rt_fu.target = $DetailedControl/ForwardingUnit/Input2
			rt_fu.active = true
			
		LineManager.ex_lines.ALUCONTROL_ALU:
			alu_control_alu.active = true
			
		LineManager.ex_lines.RTDATA_EXMEM:
			if PipelinedWrapper.stage_signals_map[2]["RT_FU"]:
				return
			
			rt_data_exmem_base.origin = get_node(LineManager.stage_register_path[1]).get("rt_data_2")
			rt_data_exmem_base.default_color = Color.TRANSPARENT
			rt_data_exmem_base.active = true
			
			rt_data_exmem.origin = rt_data_exmem_base
			rt_data_exmem.target = get_node(LineManager.stage_register_path[2]).get("imm_value")
			rt_data_exmem.active = true
			
		LineManager.ex_lines.PC_ADD:
			pc_add.active = true
			
		LineManager.ex_lines.IMMVAL_ADD:
			imm_val_add.origin = get_node(LineManager.stage_register_path[1]).get("imm_value_2")
			imm_val_add.active = true
		
		LineManager.ex_lines.FU_ALU1:
			match PipelinedWrapper.stage_signals_map[2]["RS_FU"]:
				1:
					fu_alu_1.line_color = StageControl.colors_map[StageControl.instruction_map[3]]
				3:
					fu_alu_1.line_color = StageControl.colors_map[StageControl.instruction_map[4]]
			
			fu_alu_1.active = true
		
		LineManager.ex_lines.FU_ALU2:
			match PipelinedWrapper.stage_signals_map[2]["RT_FU"]:
				1:
					fu_alu_2.line_color = StageControl.colors_map[StageControl.instruction_map[3]]
				3:
					fu_alu_2.line_color = StageControl.colors_map[StageControl.instruction_map[4]]
			
			fu_alu_2.active = true
		
		LineManager.ex_lines.FU_RTDATA:
			match PipelinedWrapper.stage_signals_map[2]["RT_FU"]:
				1:
					fu_rt_data.line_color = StageControl.colors_map[StageControl.instruction_map[3]]
				3:
					fu_rt_data.line_color = StageControl.colors_map[StageControl.instruction_map[4]]
			
			fu_rt_data.target = get_node(LineManager.stage_register_path[2]).get("imm_value")
			fu_rt_data.active = true


func _on_forwarding_unit_pressed():
	$DetailedControl/ForwardingUnit/FordwardingUnit_info_window.add_info()

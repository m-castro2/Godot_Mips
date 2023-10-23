extends Panel

@onready var data_memory = $DataMemory
@onready var detailed_control = $DetailedControl

@onready var pc = $DetailedControl/PC
@onready var reg_dst = $DetailedControl/RegDst
@onready var alu_out_data_mem = $DataMemory/AluOut_DataMem
@onready var alu_out_alu_1 = $OutsideLines/AluOut_ALU1
@onready var alu_out_alu_2 = $OutsideLines/AluOut_ALU2
@onready var reg_dst_forwarding_unit = $OutsideLines/RegDst_ForwardingUnit
@onready var data_mem_memwb = $DataMemory/DataMem_MEMWB
@onready var alu_out_memwb = $DetailedControl/AluOut_MEMWB
@onready var rt_data_data_mem = $DataMemory/RtData_DataMem
@onready var alu_out_rt_data = $OutsideLines/AluOut_RTData
@onready var rel_branch_pc = $OutsideLines/RelBranch_PC

@onready var lines: Array[Line2D] = [ pc,
									reg_dst,
									alu_out_data_mem,
									alu_out_alu_1,
									alu_out_alu_2,
									reg_dst_forwarding_unit,
									data_mem_memwb,
									alu_out_memwb,
									rt_data_data_mem,
									alu_out_rt_data,
									rel_branch_pc]

@onready var stage_color: Color = get_parent().get_parent().stage_color:
	set(value):
		if stage_color == value:
			return
		stage_color = value
		for line in lines:
			line.line_color = value

var stage: Globals.STAGES = Globals.STAGES.MEM


func _ready():
	LineManager.mem_line_active.connect(_on_LineManager_mem_line_active)
	show_lines()


func _on_LineManager_mem_line_active(line: LineManager.mem_lines, active: bool) -> void:
	match line:
		LineManager.mem_lines.PC:
			pc.origin = get_node(LineManager.stage_register_path[2]).get("pc_2")
			pc.target = get_node(LineManager.stage_register_path[3]).get("pc")
			pc.active = true
			
		LineManager.mem_lines.RegDst:
			reg_dst.origin = get_node(LineManager.stage_register_path[2]).get("reg_dst_2")
			reg_dst.target = get_node(LineManager.stage_register_path[3]).get("reg_dst")
			reg_dst.active = true
			
		LineManager.mem_lines.ALUOUT_DATAMEM:
			alu_out_data_mem.origin = $DetailedControl/AluOut
			alu_out_data_mem.target = $DataMemory/UpperInput
			alu_out_data_mem.active = active
		
		LineManager.mem_lines.ALUOUT_ALU1:
			alu_out_alu_1.target_component = LineManager.get_stage_component(2, "alu")
			alu_out_alu_1.target = LineManager.get_stage_component(2, "alu").get_node("UpperInput")
			alu_out_alu_1.active = true
			
		LineManager.mem_lines.ALUOUT_ALU2:
			alu_out_alu_2.target = LineManager.get_stage_component(2, "alu").get_node("LowerInput")
			alu_out_alu_2.active = true
			
		LineManager.mem_lines.REGDST_FORWARDINGUNIT:
			reg_dst_forwarding_unit.target_component = LineManager.get_stage_component(2, "forwarding_unit")
			reg_dst_forwarding_unit.origin = get_node(LineManager.stage_register_path[2]).get("reg_dst_2")
			reg_dst_forwarding_unit.target = LineManager.get_stage_component(2, "forwarding_unit").get_node("Input1")
			reg_dst_forwarding_unit.target_component.request_stage_origin.append(Globals.STAGES.MEM)
			reg_dst_forwarding_unit.active = true
		
		LineManager.mem_lines.DATAMEM_MEMWB:
			data_mem_memwb.active = true
			
		LineManager.mem_lines.ALUOUT_MEMWB:
			alu_out_memwb.active = true
		
		LineManager.mem_lines.RTDATA_DATAMEM:
			rt_data_data_mem.origin = get_node(LineManager.stage_register_path[2]).get("imm_value_2")
			rt_data_data_mem.active = active
		
		LineManager.mem_lines.ALUOUT_RT:
			alu_out_rt_data.target = get_node(LineManager.stage_register_path[2]).get("rt")
			alu_out_rt_data.active = true
		
		LineManager.mem_lines.RELBRANCH_PC:
			rel_branch_pc.origin = get_node(LineManager.stage_register_path[2]).get("rel_branch_2")
			rel_branch_pc.target_component = LineManager.get_stage_component(0, "pc")
			rel_branch_pc.target = rel_branch_pc.target_component.get_node("Input")
			rel_branch_pc.active = true


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
	$DetailedControl/AluOut.position = Vector2(0, size.y/2)
	$DetailedControl/MEMWB_AluOut.position = Vector2(size.x, size.y * .7)
	
	%MEMWB.global_position = Vector2(global_position.x + size.x, $DataMemory/Output.global_position.y)


func draw_lines():
	for line in lines:
		if line.active or line.force_visible:
			line.add_points()
			line.animate_line()
			if line is OutsideLine2D:
				line.check_visibility(false, true)
			else:
				line.check_visibility(false)


func hide_lines() -> void:
	for line in lines:
		line.visible = false


func _on_data_memory_pressed():
	$DataMemory/DataMemory_info_window.add_info()


func _on_gui_input(_event) -> void:
	if !Globals.can_click and Globals.current_cycle:
		return
	if Input.is_action_just_pressed("Click"):
		Globals.can_click = false
		Input.flush_buffered_events()
		if Globals.close_window_handled:
			Globals.close_window_handled = false
		else:
			Globals.expand_stage.emit(3)

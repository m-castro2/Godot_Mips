extends Panel

@onready var mux = $Mux
@onready var detailed_control = $DetailedControl

@onready var pc_mux = $Mux/PC_Mux
@onready var mem_out_mux = $Mux/MemOut_Mux
@onready var alu_out_mux = $Mux/ALUOut_Mux
@onready var mux_reg_bank = $OutsideLines/Mux_RegBank
@onready var alu_out_alu_1 = $OutsideLines/ALUOut_ALU1
@onready var alu_out_alu_2 = $OutsideLines/ALUOut_ALU2
@onready var reg_dst_reg_bank = $OutsideLines/RegDst_RegBank
@onready var reg_dst_forwarding_unit = $OutsideLines/RegDst_ForwardingUnit


@onready var lines: Array[Line2D] = [ pc_mux,
									alu_out_mux,
									mem_out_mux,
									mux_reg_bank,
									alu_out_alu_1,
									alu_out_alu_2,
									reg_dst_reg_bank,
									reg_dst_forwarding_unit]

@onready var stage_color: Color = get_parent().get_parent().stage_color:
	set(value):
		stage_color = value
		for line in lines:
			line.line_color = value

var stage: Globals.STAGES = Globals.STAGES.WB


func _ready() -> void:
	LineManager.wb_line_active.connect(_on_wb_line_active)
	show_lines()


func show_lines() -> void:
	## Not needed once CpuFlex manages which lines to show
	LineManager.wb_line_active.emit(LineManager.wb_lines.PC_MUX)
	LineManager.wb_line_active.emit(LineManager.wb_lines.ALUOUT_MUX)
	LineManager.wb_line_active.emit(LineManager.wb_lines.MEMOUT_MUX)
	LineManager.wb_line_active.emit(LineManager.wb_lines.MUX_REGBANK)
	LineManager.wb_line_active.emit(LineManager.wb_lines.ALUOUT_ALU1)
	LineManager.wb_line_active.emit(LineManager.wb_lines.ALUOUT_ALU2)
	LineManager.wb_line_active.emit(LineManager.wb_lines.REGDST_REGBANK)
	LineManager.wb_line_active.emit(LineManager.wb_lines.REGDST_FORWARDINGUNIT)


func _on_wb_line_active(line: LineManager.wb_lines):
	match line:
		LineManager.wb_lines.PC_MUX:
			pc_mux.origin = get_node(LineManager.stage_register_path[3]).get("pc_2")
			pc_mux.active = true
			
		LineManager.wb_lines.ALUOUT_MUX:
			alu_out_mux.origin = $DetailedControl/AluOut
			alu_out_mux.active = true
			
		LineManager.wb_lines.MEMOUT_MUX:
			mem_out_mux.active = true
		
		LineManager.wb_lines.MUX_REGBANK:
			await LineManager.if_stage_updated
			mux_reg_bank.target_component = LineManager.get_stage_component(1, "registers_bank")
			mux_reg_bank.target = LineManager.get_stage_component(1, "registers_bank").get_node("Input4")
			mux_reg_bank.target_component.request_stage_origin.append(Globals.STAGES.WB)
			mux_reg_bank.active = true
		
		LineManager.wb_lines.ALUOUT_ALU1:
			await LineManager.if_stage_updated
			alu_out_alu_1.target_component = LineManager.get_stage_component(2, "alu")
			alu_out_alu_1.target = LineManager.get_stage_component(2, "alu").get_node("UpperInput")
			alu_out_alu_1.target_component.request_stage_origin.append(Globals.STAGES.WB)
			alu_out_alu_1.active = true
		
		LineManager.wb_lines.ALUOUT_ALU2:
			await LineManager.if_stage_updated
			alu_out_alu_2.target_component = LineManager.get_stage_component(2, "alu")
			alu_out_alu_2.target = LineManager.get_stage_component(2, "alu").get_node("LowerInput")
			alu_out_alu_2.target_component.request_stage_origin.append(Globals.STAGES.WB)
			alu_out_alu_2.active = true
		
		LineManager.wb_lines.REGDST_REGBANK:
			await LineManager.if_stage_updated
			reg_dst_reg_bank.target_component = LineManager.get_stage_component(1, "registers_bank")
			reg_dst_reg_bank.target = LineManager.get_stage_component(1, "registers_bank").get_node("Input3")
			reg_dst_reg_bank.target_component.request_stage_origin.append(Globals.STAGES.WB)
			reg_dst_reg_bank.active = true
		
		LineManager.wb_lines.REGDST_FORWARDINGUNIT:
			await LineManager.if_stage_updated
			reg_dst_forwarding_unit.target_component = LineManager.get_stage_component(2, "forwarding_unit")
			reg_dst_forwarding_unit.target = LineManager.get_stage_component(2, "forwarding_unit").get_node("LowerRightInput")
			reg_dst_forwarding_unit.target_component.request_stage_origin.append(Globals.STAGES.WB)
			reg_dst_forwarding_unit.active = true


func show_detail(value: bool) -> void:
	detailed_control.visible = true
	for child in detailed_control.get_children():
		if child is Button:
			child.visible = value or child.requested
		elif child is Line2D:
			child.draw_requested = value and child.active and get_parent().get_parent().expanded


func draw_lines():
	for line in lines:
		if line.active:
			line.add_points()
			line.animate_line()


func calculate_positions():
	$DetailedControl/AluOut.position = Vector2(0, size.y * .7)
	
	$DetailedControl/MemOut.position = Vector2(0, LineManager.get_stage_component(3, "detailed_control").get_node("MEMWB").position.y)
	
	$DetailedControl/RegDst.global_position = Vector2(global_position.x, get_node(LineManager.stage_register_path[2]).get("reg_dst_2").global_position.y)
	
	LineManager.wb_stage_updated.emit()


func _on_mux_pressed():
	mux.show_info_window()


func _on_gui_input(_event):
	if Input.is_action_just_pressed("Click"):
		if Globals.close_window_handled:
			Globals.close_window_handled = false
		else:
			Globals.expand_stage.emit(4)

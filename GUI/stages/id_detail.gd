extends Panel

@onready var registers_bank: MainComponent = $RegistersBank
@onready var detailed_control: Control = $DetailedControl
@onready var add: MainComponent = $DetailedControl/Add
@onready var control: Control = $DetailedControl/Control
@onready var hazard_detection_unit: MainComponent = $HazardDetectionUnit

#lines
@onready var inst_25_21: ComplexLine2D = $"RegistersBank/Inst_25-21"
@onready var inst_20_16_rd_reg_2 = $"RegistersBank/Inst_20-16_RDReg2"
@onready var inst_15_0_imm = $"RegistersBank/Inst_15-0_Imm"
@onready var inst_15_0_add = $"RegistersBank/Inst_15-0_Add"
@onready var inst_20_16_reg_dst = $"RegistersBank/Inst_20-16_RegDst"
@onready var inst_control = $RegistersBank/Inst_Control
@onready var reg_bank_rt_data = $RegistersBank/RegBank_RTData
@onready var reg_bank_rs_data = $RegistersBank/RegBank_RSData
@onready var pc = $DetailedControl/PC
@onready var rs_data = $DetailedControl/RsData
@onready var rt_data = $DetailedControl/RtData
@onready var imm_value = $DetailedControl/ImmValue
@onready var rs = $DetailedControl/Rs
@onready var rt = $DetailedControl/Rt
@onready var reg_dst = $DetailedControl/RegDst
@onready var pc_add = $DetailedControl/PC_Add
@onready var hdu_pc = $OutsideLines/HDU_PC
@onready var inst_pc = $OutsideLines/Inst_PC
@onready var rs_pc = $OutsideLines/RS_PC
@onready var inst_base = $RegistersBank/InstBase
@onready var inst_15_11_reg_dst = $"RegistersBank/Inst_15-11_RegDst"
@onready var add_pc = $OutsideLines/Add_PC
@onready var rs_data_pc = $OutsideLines/RsData_PC
@onready var pc_inst_pc = $DetailedControl/PC_InstPC
@onready var rdreg_1_hdu = $HazardDetectionUnit/RDREG1_HDU
@onready var rdreg_2_hdu = $HazardDetectionUnit/RDREG2_HDU


@onready var lines: Array[Node] = [ inst_25_21,
									inst_20_16_rd_reg_2,
									inst_15_0_imm,
									inst_15_0_add,
									inst_20_16_reg_dst,
									inst_control,
									reg_bank_rt_data,
									reg_bank_rs_data,
									pc, rs_data, rt_data,
									imm_value, rs, rt, reg_dst,
									pc_add, hdu_pc, inst_pc, rs_pc,
									inst_base, inst_15_11_reg_dst,
									add_pc, inst_15_0_add, rs_data_pc,
									pc_inst_pc, rdreg_1_hdu, rdreg_2_hdu]

@onready var stage_color: Color = get_parent().get_parent().stage_color:
	set(value):
		stage_color = value
		for line in lines:
			line.line_color = value

var stage: Globals.STAGES = Globals.STAGES.ID

var is_shrunk: bool = false


func _ready():
	Globals.stage_tween_finished.connect(_on_stage_tween_finished)
	LineManager.id_line_active.connect(_on_LineManager_id_line_active)
	show_lines()


func show_lines() -> void:
	## Probably not needed once CpuFlex manages which lines to show
	pass


func show_detail(value: bool) -> void:
	detailed_control.visible = true
	return
	for child in detailed_control.get_children():
		if child is Button:
			child.visible = value or child.requested
		elif child is Line2D:
			pass#child.draw_requested = value and child.active and get_parent().get_parent().expanded


func calculate_positions() -> void:
	return


func draw_lines() -> void:
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


func _on_registers_bank_pressed() -> void:
	$RegistersBank/RegBankWindow.add_info()


func _get_all_children(node: Node, shrink: bool):
	for child in node.get_children():
		if child is Line2D or child is Marker2D:
			continue
		if child.get_child_count() > 0:
			_get_all_children(child, shrink)
		if child.name == "DetailedControl": #dont shrink DetailedControl size
			continue
		if child is Button or child is Label:
			if shrink:
				child.add_theme_font_size_override("font_size", child.get_theme_font_size("font_size") - 8)
			else:
				child.add_theme_font_size_override("font_size", child.get_theme_font_size("font_size") + 8)
			child.custom_minimum_size = child.custom_minimum_size * .66 if shrink else child.custom_minimum_size / .66
			child.size = child.custom_minimum_size


func _on_stage_tween_finished(_stage):
	return
	var shrink = (DisplayServer.window_get_size().y < 960)
	if shrink and detailed_control.visible:
		_get_all_children(self, true)
		is_shrunk = true
	elif is_shrunk:
		_get_all_children(self, false)
		is_shrunk = false
	
	await get_tree().process_frame
	Globals.recenter_window.emit()


func _on_resized():
	%IFIDOutput.position = Vector2(0, size.y/2)
	%IFIDOutput.get_child(0).position = Vector2(10, 0)
	if inst_pc:
		%PC_InstPC_Target.position = Vector2(0, size.y * inst_pc.height_percent)
	return
	if detailed_control:
		var shrink = (DisplayServer.window_get_size().y < 960)
		if !shrink and is_shrunk:
			_get_all_children(self, false)
			is_shrunk = false
		elif shrink and !is_shrunk and detailed_control.visible:
			_get_all_children(self, true)
			is_shrunk = true
		
		await get_tree().process_frame
		Globals.recenter_window.emit()


func _on_gui_input(_event) -> void:
	if !Globals.can_click and Globals.current_cycle:
		return
	if Input.is_action_just_pressed("Click"):
		Globals.can_click = false
		Input.flush_buffered_events()
		if Globals.close_window_handled:
			Globals.close_window_handled = false
		else:
			Globals.expand_stage.emit(1)


func _on_LineManager_id_line_active(line: LineManager.id_lines, active: bool, label_key: String = "") -> void:
	match  line:
		LineManager.id_lines.HDU_PC:
			hdu_pc.origin_component = hazard_detection_unit
			hdu_pc.origin_component.request_stage_origin.append(Globals.STAGES.IF)
			hdu_pc.target_component = LineManager.get_stage_component(0, "pc")
			hdu_pc.target = hdu_pc.target_component.get_node("UpperInput")
			hdu_pc.active = true
			
		LineManager.id_lines.PC:
			pc.origin = get_node(LineManager.stage_register_path[0]).get("pc_2")
			pc.target = get_node(LineManager.stage_register_path[1]).get("pc")
			pc.active = true
			
		LineManager.id_lines.INST_RDREG1:
			inst_25_21.active = active
			
		LineManager.id_lines.INST_RDREG2:
			inst_20_16_rd_reg_2.active = active
			
		LineManager.id_lines.INST_IMMVAL:
			inst_15_0_imm.target = get_node(LineManager.stage_register_path[1]).get("imm_value")
			(%Inst_Imm_Label as LineLabel).map_key = label_key
			inst_15_0_imm.active = true
			
		LineManager.id_lines.INST20_REGDST:
			inst_20_16_reg_dst.target = get_node(LineManager.stage_register_path[1]).get("reg_dst")
			inst_20_16_reg_dst.active = true
			
		LineManager.id_lines.INST15_REGDST:
			inst_15_11_reg_dst.target = get_node(LineManager.stage_register_path[1]).get("reg_dst")
			inst_15_11_reg_dst.active = true
			
		LineManager.id_lines.INST_CONTROL:
			inst_control.active = true
			
		LineManager.id_lines.RS:
			rs.target = get_node(LineManager.stage_register_path[1]).get("rs")
			rs.active = true
			
		LineManager.id_lines.RT:
			rt.target = get_node(LineManager.stage_register_path[1]).get("rt")
			rt.active = true
			
		LineManager.id_lines.INST_ADD:
			inst_15_0_add.active = true
			
		LineManager.id_lines.PC_ADD:
			pc_add.active = true
			
		LineManager.id_lines.RDDATA_RSDATA:
			reg_bank_rs_data.target = get_node(LineManager.stage_register_path[1]).get("rs_data")
			reg_bank_rs_data.active = active
			
		LineManager.id_lines.RDDATA2_RTDATA:
			reg_bank_rt_data.target = get_node(LineManager.stage_register_path[1]).get("rt_data")
			reg_bank_rt_data.active = active
			
		LineManager.id_lines.ADD_PC:
			add_pc.target_component = LineManager.get_stage_component(0, "pc")
			add_pc.target = add_pc.target_component.get_node("Input")
			add_pc.origin_component.request_stage_origin.append(Globals.STAGES.IF)
			add_pc.active = true
			
		LineManager.id_lines.INST_BASE:
			inst_base.active = active
		
		LineManager.id_lines.RSDATA_PC:
			rs_data_pc.target_component = LineManager.get_stage_component(0, "pc")
			rs_data_pc.target = rs_data_pc.target_component.get_node("Input")
			rs_data_pc.origin_component.request_stage_origin.append(Globals.STAGES.IF)
			rs_data_pc.active = true
		
		LineManager.id_lines.INST_PC:
			inst_pc.target_component = LineManager.get_stage_component(0, "pc")
			inst_pc.target = inst_pc.target_component.get_node("Input")
			inst_pc.active = true
			pc_inst_pc.active = true
		
		LineManager.id_lines.RDREG1_HDU:
			rdreg_1_hdu.active = true
			rdreg_1_hdu.target.get_parent().request_stage_origin.append(Globals.STAGES.ID)
		
		LineManager.id_lines.RDREG2_HDU:
			rdreg_2_hdu.active = true
			rdreg_2_hdu.target.get_parent().request_stage_origin.append(Globals.STAGES.ID)


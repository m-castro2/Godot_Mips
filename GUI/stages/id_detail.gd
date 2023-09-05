extends Panel

@onready var registers_bank = $RegistersBank
@onready var detailed_control = $DetailedControl
@onready var add = $DetailedControl/Add
@onready var control = $DetailedControl/Control
@onready var hazard_detection_unit = $HazardDetectionUnit

#lines
@onready var inst_25_21 = $"RegistersBank/Inst_25-21"
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
									add_pc]

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
	inst_base.active = true
	show_lines()


func show_lines() -> void:
	## Probably not needed once CpuFlex manages which lines to show
	LineManager.id_line_active.emit(LineManager.id_lines.PC)
	LineManager.id_line_active.emit(LineManager.id_lines.ImmValue)
	LineManager.id_line_active.emit(LineManager.id_lines.INST_RDREG1)
	LineManager.id_line_active.emit(LineManager.id_lines.INST_RDREG2)
	LineManager.id_line_active.emit(LineManager.id_lines.INST_IMMVAL)
	LineManager.id_line_active.emit(LineManager.id_lines.INST20_REGDST)
	LineManager.id_line_active.emit(LineManager.id_lines.INST15_REGDST)
	LineManager.id_line_active.emit(LineManager.id_lines.INST_CONTROL)
	LineManager.id_line_active.emit(LineManager.id_lines.RS)
	LineManager.id_line_active.emit(LineManager.id_lines.RT)
	LineManager.id_line_active.emit(LineManager.id_lines.INST_ADD)
	LineManager.id_line_active.emit(LineManager.id_lines.PC_ADD)
	LineManager.id_line_active.emit(LineManager.id_lines.RDDATA_RSDATA)
	LineManager.id_line_active.emit(LineManager.id_lines.RDDATA2_RTDATA)

func show_detail(value: bool) -> void:
	detailed_control.visible = true
	for child in detailed_control.get_children():
		if child is Button:
			child.visible = value or child.requested
		elif child is Line2D:
			pass#child.draw_requested = value and child.active and get_parent().get_parent().expanded


func calculate_positions() -> void:
	return
	

func draw_lines() -> void:
	for line in lines:
		if line.active:
			line.add_points()
			line.animate_line()


func _on_registers_bank_pressed() -> void:
	registers_bank.show_info_window()


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


func _on_gui_input(_event):
	if Input.is_action_just_pressed("Click"):
		if Globals.close_window_handled:
			Globals.close_window_handled = false
		else:
			Globals.expand_stage.emit(1)


func _on_LineManager_id_line_active(line: LineManager.id_lines) -> void:
	match  line:
		LineManager.id_lines.HDU_PC:
			hdu_pc.origin_component = hazard_detection_unit
			hdu_pc.origin_component.request_stage_origin.append(Globals.STAGES.IF)
			hdu_pc.target = LineManager.get_stage_component(0, "pc").get_node("UpperInput")
			hdu_pc.active = true
		LineManager.id_lines.PC:
			await LineManager.if_stage_updated
			await LineManager.stage_register_updated
			pc.origin = get_node(LineManager.stage_register_path[0]).get("pc_2")
			pc.target = get_node(LineManager.stage_register_path[1]).get("pc")
			pc.active = true
		LineManager.id_lines.ImmValue:
			await LineManager.if_stage_updated
			await LineManager.stage_register_updated
		LineManager.id_lines.INST_RDREG1:
			await LineManager.if_stage_updated
			inst_25_21.active = true
		LineManager.id_lines.INST_RDREG2:
			await LineManager.if_stage_updated
			inst_20_16_rd_reg_2.active = true
		LineManager.id_lines.INST_IMMVAL:
			await LineManager.if_stage_updated
			inst_15_0_imm.target = get_node(LineManager.stage_register_path[1]).get("imm_value")
			inst_15_0_imm.active = true
		LineManager.id_lines.INST20_REGDST:
			await LineManager.if_stage_updated
			inst_20_16_reg_dst.target = get_node(LineManager.stage_register_path[1]).get("reg_dst")
			inst_20_16_reg_dst.active = true
		LineManager.id_lines.INST15_REGDST:
			await LineManager.if_stage_updated
			inst_15_11_reg_dst.target = get_node(LineManager.stage_register_path[1]).get("reg_dst")
			inst_15_11_reg_dst.active = true
		LineManager.id_lines.INST_CONTROL:
			await LineManager.if_stage_updated
			inst_control.active = true
		LineManager.id_lines.RS:
			await LineManager.if_stage_updated
			rs.target = get_node(LineManager.stage_register_path[1]).get("rs")
			rs.active = true
		LineManager.id_lines.RT:
			await LineManager.if_stage_updated
			rt.target = get_node(LineManager.stage_register_path[1]).get("rt")
			rt.active = true
		LineManager.id_lines.INST_ADD:
			await LineManager.if_stage_updated
			inst_15_0_add.active = true
		LineManager.id_lines.PC_ADD:
			await LineManager.if_stage_updated
			pc_add.active = true
		LineManager.id_lines.RDDATA_RSDATA:
			await LineManager.if_stage_updated
			reg_bank_rs_data.target = get_node(LineManager.stage_register_path[1]).get("rs_data")
			reg_bank_rs_data.active = true
		LineManager.id_lines.RDDATA2_RTDATA:
			await LineManager.if_stage_updated
			reg_bank_rt_data.target = get_node(LineManager.stage_register_path[1]).get("rt_data")
			reg_bank_rt_data.active = true
		LineManager.id_lines.ADD_PC:
			add_pc.target_component = LineManager.get_stage_component(0, "pc")
			add_pc.target = add_pc.target_component.get_node("Input")
			add_pc.origin_component.request_stage_origin.append(Globals.STAGES.IF)
			add_pc.active = true

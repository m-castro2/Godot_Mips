extends BaseWindow

# field labels
@onready var rel_branch = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerField/RelBranch
@onready var pc: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerField/PC
@onready var instruction: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerField/Instruction
@onready var rs_data: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerField/RsData
@onready var rt_data: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerField/RtData
@onready var imm_value: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerField/ImmValue
@onready var rs: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerField/Rs
@onready var rt: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerField/Rt
@onready var reg_dest: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerField/RegDest
@onready var alu_out: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerField/ALUOut
@onready var mem_out: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerField/MemOut

#write labels
@onready var rel_branch_w = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerWrite/RelBranch
@onready var pc_w: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerWrite/PC
@onready var instruction_w: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerWrite/Instruction
@onready var rs_data_w: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerWrite/RsData
@onready var rt_data_w: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerWrite/RtData
@onready var imm_value_w: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerWrite/ImmValue
@onready var rs_w: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerWrite/Rs
@onready var rt_w: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerWrite/Rt
@onready var reg_dest_w: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerWrite/RegDest
@onready var alu_out_w: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerWrite/ALUOut
@onready var mem_out_w: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerWrite/MemOut

#read labels
@onready var rel_branch_r = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerRead/RelBranch
@onready var pc_r: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerRead/PC
@onready var instruction_r: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerRead/Instruction
@onready var rs_data_r: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerRead/RsData
@onready var rt_data_r: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerRead/RtData
@onready var imm_value_r: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerRead/ImmValue
@onready var rs_r: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerRead/Rs
@onready var rt_r: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerRead/Rt
@onready var reg_dest_r: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerRead/RegDest
@onready var alu_out_r: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerRead/ALUOut
@onready var mem_out_r: Label = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerRead/MemOut

@onready var v_box_container_write: VBoxContainer = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerWrite
@onready var v_box_container_read: VBoxContainer = $PanelContainer/ScrollContainer/HBoxContainer/VBoxContainerRead


var empty_value: String = ""

var seg_reg_index: int:
	set(value):
		seg_reg_index = value
		setup_labels()


func _ready():
	LineManager.seg_regs_updated.connect(_on_LineManager_seg_regs_updated)
	Globals.branch_stage_changed.connect(_on_Globals_branch_stage_changed)
	
	base_window_scale = Globals.base_viewport_size / Vector2(min_size)
	super._ready()


func _on_LineManager_seg_regs_updated():
	var keys:= LineManager.seg_reg_values[seg_reg_index].keys()
	
	match seg_reg_index:
		0:
			instruction_w.text = LineManager.seg_reg_values[seg_reg_index]["INSTRUCTION_W"] if "INSTRUCTION_W" in keys else empty_value
			instruction_r.text = LineManager.seg_reg_values[seg_reg_index]["INSTRUCTION_R"] if "INSTRUCTION_R" in keys else empty_value
			
			pc_w.text = LineManager.seg_reg_values[seg_reg_index]["PC_W"] if "PC_W" in keys else empty_value
			pc_r.text =  LineManager.seg_reg_values[seg_reg_index]["PC_R"] if "PC_R" in keys else empty_value
		
		1:
			pc_w.text = LineManager.seg_reg_values[seg_reg_index]["PC_W"] if "PC_W" in keys else empty_value
			pc_r.text =  LineManager.seg_reg_values[seg_reg_index]["PC_R"] if "PC_R" in keys else empty_value
			
			rs_data_w.text = LineManager.seg_reg_values[seg_reg_index]["RS_DATA_W"] if "RS_DATA_W" in keys else empty_value
			rs_data_r.text = LineManager.seg_reg_values[seg_reg_index]["RS_DATA_R"] if "RS_DATA_R" in keys else empty_value
			
			rt_data_w.text = LineManager.seg_reg_values[seg_reg_index]["RT_DATA_W"] if "RT_DATA_W" in keys else empty_value
			rt_data_r.text = LineManager.seg_reg_values[seg_reg_index]["RT_DATA_R"] if "RT_DATA_R" in keys else empty_value
			
			reg_dest_w.text = get_register_name(2, "REG_DEST_W") if "REG_DEST_W" in keys else empty_value
			reg_dest_r.text = get_register_name(1, "REG_DEST_R") if "REG_DEST_R" in keys else empty_value
			
			imm_value_w.text = str(LineManager.seg_reg_values[seg_reg_index]["IMM_VALUE_W"]) if "IMM_VALUE_W" in keys else empty_value
			imm_value_r.text = str(LineManager.seg_reg_values[seg_reg_index]["IMM_VALUE_R"]) if "IMM_VALUE_R" in keys else empty_value
		
		2:
			rel_branch_w.text = str(LineManager.seg_reg_values[seg_reg_index]["REL_BRANCH_W"]) if "REL_BRANCH_W" in keys else empty_value
			rel_branch_r.text = str(LineManager.seg_reg_values[seg_reg_index]["REL_BRANCH_R"]) if "REL_BRANCH_R" in keys else empty_value
			
			pc_w.text = LineManager.seg_reg_values[seg_reg_index]["PC_W"] if "PC_W" in keys else empty_value
			pc_r.text =  LineManager.seg_reg_values[seg_reg_index]["PC_R"] if "PC_R" in keys else empty_value
			
			rs_data_w.text = LineManager.seg_reg_values[seg_reg_index]["RS_DATA_W"] if "RS_DATA_W" in keys else empty_value
			rs_data_r.text = LineManager.seg_reg_values[seg_reg_index]["RS_DATA_R"] if "RS_DATA_R" in keys else empty_value
			
			rt_data_w.text = LineManager.seg_reg_values[seg_reg_index]["RT_DATA_W"] if "RT_DATA_W" in keys else empty_value
			rt_data_r.text = LineManager.seg_reg_values[seg_reg_index]["RT_DATA_R"] if "RT_DATA_R" in keys else empty_value
			
			reg_dest_w.text = get_register_name(3, "REG_DEST_W") if "REG_DEST_W" in keys else empty_value
			reg_dest_r.text = get_register_name(2, "REG_DEST_R") if "REG_DEST_R" in keys else empty_value
			
			imm_value_w.text = str(LineManager.seg_reg_values[seg_reg_index]["IMM_VALUE_W"]) if "IMM_VALUE_W" in keys else empty_value
			imm_value_r.text = str(LineManager.seg_reg_values[seg_reg_index]["IMM_VALUE_R"]) if "IMM_VALUE_R" in keys else empty_value
			
			alu_out_w.text = str(LineManager.seg_reg_values[seg_reg_index]["ALU_OUT_W"]) if "ALU_OUT_W" in keys else empty_value
			alu_out_r.text = str(LineManager.seg_reg_values[seg_reg_index]["ALU_OUT_R"]) if "ALU_OUT_R" in keys else empty_value
		
		3:
			pc_w.text = LineManager.seg_reg_values[seg_reg_index]["PC_W"] if "PC_W" in keys else empty_value
			pc_r.text =  LineManager.seg_reg_values[seg_reg_index]["PC_R"] if "PC_R" in keys else empty_value
			
			reg_dest_w.text = get_register_name(4, "REG_DEST_W") if "REG_DEST_W" in keys else empty_value
			reg_dest_r.text = get_register_name(3, "REG_DEST_R") if "REG_DEST_R" in keys else empty_value
			
			mem_out_w.text = str(LineManager.seg_reg_values[seg_reg_index]["MEM_OUT_W"]) if "MEM_OUT_W" in keys else empty_value
			mem_out_r.text = str(LineManager.seg_reg_values[seg_reg_index]["MEM_OUT_R"]) if "MEM_OUT_R" in keys else empty_value
			
			alu_out_w.text = str(LineManager.seg_reg_values[seg_reg_index]["ALU_OUT_W"]) if "ALU_OUT_W" in keys else empty_value
			alu_out_r.text = str(LineManager.seg_reg_values[seg_reg_index]["ALU_OUT_R"]) if "ALU_OUT_R" in keys else empty_value


func setup_labels():
	match seg_reg_index:
		0:
			title = "IF/ID"
			
			instruction.show()
			instruction_w.show()
			instruction_r.show()
			
			reg_dest.hide()
			reg_dest_w.hide()
			reg_dest_r.hide()
			
		1:
			title = "ID/EX"
			
			rs_data.show()
			rs_data_w.show()
			rs_data_r.show()
			
			rt_data.show()
			rt_data_w.show()
			rt_data_r.show()
			
			imm_value.show()
			imm_value_w.show()
			imm_value_r.show()
			
		2:
			title = "EX/MEM"
			
			_on_Globals_branch_stage_changed(ConfigManager.get_value("Settings/CPU", "branch_stage"))
			
			rs_data.show()
			rs_data_w.show()
			rs_data_r.show()
			
			rt_data.show()
			rt_data_w.show()
			rt_data_r.show()
			
			imm_value.show()
			imm_value_w.show()
			imm_value_r.show()
			
			alu_out.show()
			alu_out_w.show()
			alu_out_r.show()
			
		3:
			title = "MEM/WB"
			
			alu_out.show()
			alu_out_w.show()
			alu_out_r.show()
			
			mem_out.show()
			mem_out_w.show()
			mem_out_r.show()


func add_info():
	show()
	Globals.close_window_handled = false


func get_active_fields():
	var active_field_index:= [[], []]
	for child in v_box_container_read.get_children():
		if !child.get_index():
			continue
		if (child as Label).text != empty_value:
			active_field_index[1].append(child.name)
	for child in v_box_container_write.get_children():
		if !child.get_index():
			continue
		if (child as Label).text != empty_value:
			active_field_index[0].append(child.name)
	return active_field_index


func _on_Globals_branch_stage_changed(value: int) -> void:
	rel_branch.visible = value
	rel_branch_w.visible = value
	rel_branch_r.visible = value


func get_register_name(stage: int, key: String) -> String:
	return LineManager.register_names[LineManager.seg_reg_values[seg_reg_index][key]]

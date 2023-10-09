extends Window

# field labels
@onready var pc: Label = $ScrollContainer/HBoxContainer/VBoxContainerField/PC
@onready var instruction: Label = $ScrollContainer/HBoxContainer/VBoxContainerField/Instruction
@onready var rs_data: Label = $ScrollContainer/HBoxContainer/VBoxContainerField/RsData
@onready var rt_data: Label = $ScrollContainer/HBoxContainer/VBoxContainerField/RtData
@onready var imm_value: Label = $ScrollContainer/HBoxContainer/VBoxContainerField/ImmValue
@onready var rs: Label = $ScrollContainer/HBoxContainer/VBoxContainerField/Rs
@onready var rt: Label = $ScrollContainer/HBoxContainer/VBoxContainerField/Rt
@onready var reg_dest: Label = $ScrollContainer/HBoxContainer/VBoxContainerField/RegDest
@onready var alu_out: Label = $ScrollContainer/HBoxContainer/VBoxContainerField/ALUOut
@onready var mem_out: Label = $ScrollContainer/HBoxContainer/VBoxContainerField/MemOut

#write labels
@onready var pc_w: Label = $ScrollContainer/HBoxContainer/VBoxContainerWrite/PC
@onready var instruction_w: Label = $ScrollContainer/HBoxContainer/VBoxContainerWrite/Instruction
@onready var rs_data_w: Label = $ScrollContainer/HBoxContainer/VBoxContainerWrite/RsData
@onready var rt_data_w: Label = $ScrollContainer/HBoxContainer/VBoxContainerWrite/RtData
@onready var imm_value_w: Label = $ScrollContainer/HBoxContainer/VBoxContainerWrite/ImmValue
@onready var rs_w: Label = $ScrollContainer/HBoxContainer/VBoxContainerWrite/Rs
@onready var rt_w: Label = $ScrollContainer/HBoxContainer/VBoxContainerWrite/Rt
@onready var reg_dest_w: Label = $ScrollContainer/HBoxContainer/VBoxContainerWrite/RegDest
@onready var alu_out_w: Label = $ScrollContainer/HBoxContainer/VBoxContainerWrite/ALUOut
@onready var mem_out_w: Label = $ScrollContainer/HBoxContainer/VBoxContainerWrite/MemOut

#read labels
@onready var pc_r: Label = $ScrollContainer/HBoxContainer/VBoxContainerRead/PC
@onready var instruction_r: Label = $ScrollContainer/HBoxContainer/VBoxContainerRead/Instruction
@onready var rs_data_r: Label = $ScrollContainer/HBoxContainer/VBoxContainerRead/RsData
@onready var rt_data_r: Label = $ScrollContainer/HBoxContainer/VBoxContainerRead/RtData
@onready var imm_value_r: Label = $ScrollContainer/HBoxContainer/VBoxContainerRead/ImmValue
@onready var rs_r: Label = $ScrollContainer/HBoxContainer/VBoxContainerRead/Rs
@onready var rt_r: Label = $ScrollContainer/HBoxContainer/VBoxContainerRead/Rt
@onready var reg_dest_r: Label = $ScrollContainer/HBoxContainer/VBoxContainerRead/RegDest
@onready var alu_out_r: Label = $ScrollContainer/HBoxContainer/VBoxContainerRead/ALUOut
@onready var mem_out_r: Label = $ScrollContainer/HBoxContainer/VBoxContainerRead/MemOut

var seg_reg_index: int:
	set(value):
		seg_reg_index = value
		setup_labels()


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
	match seg_reg_index:
		0:
			var keys:= LineManager.seg_reg_values[0].keys()
			instruction_w.text = LineManager.seg_reg_values[0]["INSTRUCTION"] if "INSTRUCTION" in keys else "/"
			
			pc_w.text = LineManager.seg_reg_values[0]["PC_W"] if "PC_W" in keys else "/"
			pc_r.text =  LineManager.seg_reg_values[0]["PC_R"] if "PC_R" in keys else "/"
		
		1:
			var keys:= LineManager.seg_reg_values[1].keys()
			rs_data_w.text = LineManager.seg_reg_values[1]["RS_DATA_R"] if "RS_DATA_R" in keys else "/"
			
			rt_data_w.text = LineManager.seg_reg_values[1]["RT_DATA_R"] if "RT_DATA_R" in keys else "/"
			
			reg_dest_w.text = LineManager.seg_reg_values[1]["REG_DEST"] if "REG_DEST" in keys else "/"
			
			imm_value_w.text = str(LineManager.seg_reg_values[1]["IMM_VALUE_R"]) if "IMM_VALUE_R" in keys else "/"


func _on_focus_exited():
	visible = false


func _on_close_requested():
	visible = false

extends BaseWindow

@onready var register_names: Array = PipelinedWrapper.get_register_names()

@onready var alu_1 = $PanelContainer/VBoxContainer/HBoxContainer3/ALU1
@onready var alu_2 = $PanelContainer/VBoxContainer/HBoxContainer3/ALU2
@onready var rt_data = $PanelContainer/VBoxContainer/HBoxContainer3/RTData
@onready var mem_reg_dest = $PanelContainer/VBoxContainer/HBoxContainer3/MEM_RegDest
@onready var wb_reg_dest = $PanelContainer/VBoxContainer/HBoxContainer3/WB_RegDest
@onready var summary = $PanelContainer/VBoxContainer/MarginContainer/Summary

func _ready():
	base_window_scale = Globals.base_viewport_size / Vector2(min_size)
	super._ready()


func add_info():
	visible = true
	Globals.close_window_handled = false
	
	alu_1.text = register_names[PipelinedWrapper.stage_signals_map[2]["RS"]]
	
	if !PipelinedWrapper.stage_signals_map[2]["ALU_SRC"]:
		alu_2.text = register_names[PipelinedWrapper.stage_signals_map[2]["RT"]]
	elif PipelinedWrapper.stage_signals_map[2]["MEM_WRITE"] and PipelinedWrapper.stage_signals_map[2]["RT_FU"] == 1:
		rt_data.text = register_names[PipelinedWrapper.stage_signals_map[3]["REG_DEST_REGISTER"]]
		alu_2.text = "/"
	elif PipelinedWrapper.stage_signals_map[2]["MEM_WRITE"] and PipelinedWrapper.stage_signals_map[2]["RT_FU"] in [2,3,4]:
		rt_data.text = register_names[PipelinedWrapper.stage_signals_map[4]["REG_DEST_REGISTER"]]
		alu_2.text = "/"
	else:
		alu_2.text = "/"
		rt_data.text = "/"
	
	if !PipelinedWrapper.stage_signals_map[3]["MEM_WRITE"] and PipelinedWrapper.stage_signals_map[3]["REG_WRITE"] \
			and (PipelinedWrapper.stage_signals_map[2]["RS_FU"] == 1 or PipelinedWrapper.stage_signals_map[2]["RT_FU"] == 1):
		mem_reg_dest.text = register_names[PipelinedWrapper.stage_signals_map[3]["REG_DEST_REGISTER"]]
	else:
		mem_reg_dest.text = "/"
	
	if PipelinedWrapper.stage_signals_map[4]["REG_WRITE"] and (PipelinedWrapper.stage_signals_map[2]["RS_FU"] in [2,3,4] \
			or PipelinedWrapper.stage_signals_map[2]["RT_FU"] in [2,3,4]):
		wb_reg_dest.text = register_names[PipelinedWrapper.stage_signals_map[4]["REG_DEST_REGISTER"]]
	else:
		wb_reg_dest.text = "/"
		
	summary.text = ""
	if PipelinedWrapper.stage_signals_map[2]["RS_FU"] == 1:
		summary.text += "Forward " + alu_1.text + " from MEM to ALU1\n"
	elif PipelinedWrapper.stage_signals_map[2]["RS_FU"] in [2,3,4]:
		summary.text += "Forward " + alu_1.text + " from WB to ALU1\n"
	if PipelinedWrapper.stage_signals_map[2]["RT_FU"] == 1:
		if !PipelinedWrapper.stage_signals_map[2]["ALU_SRC"]:
			summary.text += "Forward " + alu_2.text + " from MEM to ALU2\n"
		elif  PipelinedWrapper.stage_signals_map[2]["MEM_WRITE"]:
			summary.text += "Forward " + rt_data.text + " from MEM to RTData\n"
	elif PipelinedWrapper.stage_signals_map[2]["RT_FU"] in [2,3,4]:
		if !PipelinedWrapper.stage_signals_map[2]["ALU_SRC"]:
			summary.text += "Forward " + alu_2.text + " from WB to ALU2\n"
		elif PipelinedWrapper.stage_signals_map[2]["MEM_WRITE"]:
			summary.text += "Forward " + rt_data.text + " from WB to RTData\n"

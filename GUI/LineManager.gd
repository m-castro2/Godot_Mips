extends Node

enum if_lines {ADD_IFID, MUX_PC, PC_INSTMEM, PC_ADD, INSTMEM_IFID, _4_ADD,\
	ADD_PC, PC_IFID}

enum id_lines {HDU_PC, PC, ImmValue, INST_RDREG1, INST_RDREG2, INST_IMMVAL,\
	 INST20_REGDST, INST15_REGDST, INST_CONTROL, RS, RT, INST_ADD, PC_ADD, \
	RDDATA_RSDATA, RDDATA2_RTDATA, ADD_PC, INST_BASE, RSDATA_PC, INST_PC}

enum ex_lines {PC, RegDst, ALUEXMEM, RSDATA_ALU, RTDATA_ALU2, IMMVAL_ALU2, \
	RS_FU, RT_FU, ALUCONTROL_ALU, RTDATA_EXMEM, PC_ADD, IMMVAL_ADD, \
	FU_ALU1, FU_ALU2, FU_RTDATA, ADD_RELBRANCH}

enum mem_lines {PC, RegDst, ALUOUT_DATAMEM, ALUOUT_ALU1, ALUOUT_ALU2, \
	REGDST_FORWARDINGUNIT, DATAMEM_MEMWB, ALUOUT_MEMWB, RTDATA_DATAMEM, ALUOUT_RT, \
	RELBRANCH_PC}

enum wb_lines {PC_MUX, REGDST_REGBANK, ALUOUT_MUX, MEMOUT_MUX, \
	REGDST_FORWARDINGUNIT, ALUOUT_ALU1, ALUOUT_ALU2, MUX_REGBANK, ALUOUT_RT}

enum Register_Type {IFID, IDEX, EXMEM, WB}

signal if_line_active(line: if_lines)
signal id_line_active(line: id_lines, value: bool)
signal ex_line_active(line: ex_lines, value: bool, force_visible: bool)
signal mem_line_active(line: mem_lines, value: bool)
signal wb_line_active(line: wb_lines, value: bool)

signal if_stage_updated
signal wb_stage_updated
signal stage_register_updated(register: Register_Type)

signal redraw_lines(register: int)

var stage_detail_path: Array = []
var stage_register_path: Array = []

@onready var register_names: Array = PipelinedWrapper.get_register_names()

var seg_reg_values:Array[Dictionary] = [{}, {}, {}, {}]

signal seg_regs_updated

func _ready():
	Globals.reset_button_pressed.connect(_on_Globals_reset_button_pressed)


func add_stage_detail_path(path: NodePath):
	stage_detail_path.append(path)


func add_stage_register_path(path: NodePath):
	stage_register_path.append(path)


func get_stage_component(stage_number: int, component: String): #Component -> enum?
	return get_node(stage_detail_path[stage_number]).get(component)


func activate_lines(_stage_signals_map: Array):
	if !Globals.current_cycle:
		return
	
	var stage_signals_map = PipelinedWrapper.stage_signals_map
	
	seg_reg_values = [{}, {}, {}, {}] #clear
	
	# STAGE IF
	if StageControl.instruction_map[0] != -1:
		if stage_signals_map[0]["PC_WR"] == 1:
			seg_reg_values[0]["PC_W"] = PipelinedWrapper.to_hex32(stage_signals_map[0]["PREV_PC"])
			if_line_active.emit(if_lines.PC_INSTMEM)
			if_line_active.emit(if_lines.INSTMEM_IFID)
			if_line_active.emit(if_lines.PC_INSTMEM)
			match stage_signals_map[0]["PC_SRC"]:
				0:
					if_line_active.emit(if_lines.ADD_IFID)
					if_line_active.emit(if_lines.ADD_PC)
					if_line_active.emit(if_lines._4_ADD)
					if_line_active.emit(if_lines.PC_ADD)
				1:
					# C branch
					if !Globals.branch_stage: #0 for ID, 1 for MEM
						id_line_active.emit(id_lines.ADD_PC, true)
						id_line_active.emit(id_lines.PC_ADD, true)
						id_line_active.emit(id_lines.INST_ADD, true)
#						if_line_active.emit(if_lines._4_ADD)
#						if_line_active.emit(if_lines.ADD_IFID)
					else:
						mem_line_active.emit(mem_lines.RELBRANCH_PC, true)
					if_line_active.emit(if_lines.PC_IFID)
				2:
					# R branch
					id_line_active.emit(id_lines.RSDATA_PC, true)
					if_line_active.emit(if_lines.PC_IFID)
				3:
					# J branch
					id_line_active.emit(id_lines.INST_PC, true)
					if_line_active.emit(if_lines.PC_IFID)
			
			seg_reg_values[0]["PC_W"] = PipelinedWrapper.to_hex32(stage_signals_map[0]["PC"])
			seg_reg_values[0]["INSTRUCTION_W"] = PipelinedWrapper.to_hex32(stage_signals_map[0]["INSTRUCTION"])
		
		else:
			id_line_active.emit(id_lines.HDU_PC, true)
		
	
	# STAGE ID
	if stage_signals_map[1]["INSTRUCTION"] != 0 and !stage_signals_map[1]["STALL"]:
		id_line_active.emit(id_lines.PC, true)
		id_line_active.emit(id_lines.INST_RDREG1, false)
		id_line_active.emit(id_lines.INST_RDREG2, false)
		if !stage_signals_map[1]["BRANCH"]:
			id_line_active.emit(id_lines.INST_BASE, true)
			id_line_active.emit(id_lines.INST_RDREG1, true)
			id_line_active.emit(id_lines.RDDATA_RSDATA, true)
			seg_reg_values[1]["RS_DATA_W"] = PipelinedWrapper.to_hex32(stage_signals_map[1]["RS_VALUE"])
			if stage_signals_map[1]["ALU_SRC"]:
				id_line_active.emit(id_lines.INST_IMMVAL, true)
				seg_reg_values[1]["IMM_VALUE_W"] = stage_signals_map[1]["IMM_VALUE"]
				id_line_active.emit(id_lines.INST_RDREG2, false)
			else:
				id_line_active.emit(id_lines.INST_RDREG2, true)
				id_line_active.emit(id_lines.RDDATA2_RTDATA, true)
				seg_reg_values[1]["RT_DATA_W"] = PipelinedWrapper.to_hex32(stage_signals_map[1]["RT_VALUE"])
			if stage_signals_map[1]["REG_WRITE"]:
				if stage_signals_map[1]["REG_DEST"] == 0:
					id_line_active.emit(id_lines.INST20_REGDST, true)
				elif stage_signals_map[1]["REG_DEST"] == 1:
					id_line_active.emit(id_lines.INST15_REGDST, true)
				seg_reg_values[1]["REG_DEST_W"] = PipelinedWrapper.to_hex32(stage_signals_map[1]["REG_DEST_REGISTER"])
			if stage_signals_map[1]["ALU_SRC"]:
				id_line_active.emit(id_lines.INST_IMMVAL, true)
			
			#id_line_active.emit(id_lines.RS)
			#id_line_active.emit(id_lines.RT)
			else:
				pass # $ra
		seg_reg_values[0]["PC_R"] = PipelinedWrapper.to_hex32(stage_signals_map[1]["PC"])
		seg_reg_values[0]["INSTRUCTION_R"] = PipelinedWrapper.to_hex32(stage_signals_map[1]["INSTRUCTION"])
		
		seg_reg_values[1]["PC_W"] = seg_reg_values[0]["PC_R"]
	else:
		id_line_active.emit(id_lines.INST_BASE, false)
		id_line_active.emit(id_lines.INST_RDREG1, false)
		id_line_active.emit(id_lines.INST_RDREG2, false)
		
	# STAGE EX
	if StageControl.instruction_map[2] != -1:
		var alu_input_lines_active:= [false, false, false]
		if stage_signals_map[2]["BRANCH"]:
			ex_line_active.emit(ex_lines.PC, true)
			ex_line_active.emit(ex_lines.PC_ADD, true)
			ex_line_active.emit(ex_lines.IMMVAL_ADD, true)
			ex_line_active.emit(ex_lines.ADD_RELBRANCH, true)
			seg_reg_values[1]["IMM_VALUE_R"] = stage_signals_map[2]["ADDR_I"]
			seg_reg_values[2]["REL_BRANCH_W"] = PipelinedWrapper.to_hex32(stage_signals_map[2]["REL_BRANCH"])
			#ex_line_active.emit(ex_lines.RT_FU)
		else:
			ex_line_active.emit(ex_lines.PC, true)
			ex_line_active.emit(ex_lines.ALUEXMEM, true)
			seg_reg_values[2]["ALU_OUT_W"] = PipelinedWrapper.to_hex32(stage_signals_map[2]["ALU_OUT"])
			ex_line_active.emit(ex_lines.RegDst, true)
			seg_reg_values[1]["REG_DEST_R"] = PipelinedWrapper.to_hex32(stage_signals_map[2]["REG_DEST_REGISTER"])
			seg_reg_values[2]["REG_DEST_W"] = seg_reg_values[1]["REG_DEST_R"]
			ex_line_active.emit(ex_lines.ALUCONTROL_ALU, true)
			if stage_signals_map[2]["ALU_SRC"]:
				ex_line_active.emit(ex_lines.IMMVAL_ALU2, true)
				seg_reg_values[1]["IMM_VALUE_R"] = stage_signals_map[2]["ALU_B"]
				alu_input_lines_active[2] = true

			match stage_signals_map[2]["RS_FU"]:
				0:
					ex_line_active.emit(ex_lines.RSDATA_ALU, true)
					seg_reg_values[1]["RS_DATA_R"] = PipelinedWrapper.to_hex32(stage_signals_map[2]["ALU_A"])
					alu_input_lines_active[0] = true
				1:
					ex_line_active.emit(ex_lines.FU_ALU1, true)
					mem_line_active.emit(mem_lines.REGDST_FORWARDINGUNIT, true)
				2:
					pass
				3:
					ex_line_active.emit(ex_lines.FU_ALU1, true)
					wb_line_active.emit(wb_lines.REGDST_FORWARDINGUNIT, true)
				4:
					pass
			
			match stage_signals_map[2]["RT_FU"]:
				0:
					if !stage_signals_map[2]["ALU_SRC"]:
						ex_line_active.emit(ex_lines.RTDATA_ALU2, true)
						seg_reg_values[1]["RT_DATA_R"] = PipelinedWrapper.to_hex32(stage_signals_map[2]["ALU_B"])
						alu_input_lines_active[1] = true
					elif stage_signals_map[2]["MEM_WRITE"]:
						ex_line_active.emit(ex_lines.RTDATA_EXMEM, true)
						seg_reg_values[2]["RT_DATA_W"] = PipelinedWrapper.to_hex32(stage_signals_map[2]["ALU_B"])
				1:
					if !stage_signals_map[2]["ALU_SRC"]:
						mem_line_active.emit(mem_lines.REGDST_FORWARDINGUNIT, true)
						ex_line_active.emit(ex_lines.FU_ALU2, true)
					elif stage_signals_map[2]["MEM_WRITE"]:
						mem_line_active.emit(mem_lines.REGDST_FORWARDINGUNIT, true)
						ex_line_active.emit(ex_lines.FU_RTDATA, true)
						seg_reg_values[2]["RT_DATA_W"] = PipelinedWrapper.to_hex32(stage_signals_map[2]["RT_VALUE"])
				2:
					pass
				3:
					if !stage_signals_map[2]["ALU_SRC"]:
						ex_line_active.emit(ex_lines.FU_ALU2, true)
						wb_line_active.emit(wb_lines.REGDST_FORWARDINGUNIT, true)
					elif stage_signals_map[2]["MEM_WRITE"]:
						ex_line_active.emit(ex_lines.FU_RTDATA, true)
						wb_line_active.emit(wb_lines.REGDST_FORWARDINGUNIT, true)
						seg_reg_values[2]["RT_DATA_W"] = PipelinedWrapper.to_hex32(stage_signals_map[2]["RT_VALUE"])
				4:
					pass
			if stage_signals_map[2]["MEM_WRITE"]:
				ex_line_active.emit(ex_lines.RTDATA_EXMEM, true) # origin gets updated based on IMMVAL?RTDATA_ALU2
				seg_reg_values[1]["RT_DATA_R"] = PipelinedWrapper.to_hex32(stage_signals_map[2]["ALU_B"])
				seg_reg_values[2]["RT_DATA_W"] = PipelinedWrapper.to_hex32(stage_signals_map[2]["ALU_B"])
			#ex_line_active.emit(ex_lines.RS_FU)
			#ex_line_active.emit(ex_lines.RT_FU)
		
		seg_reg_values[1]["PC_R"] = PipelinedWrapper.to_hex32(stage_signals_map[2]["PC"])
		
		seg_reg_values[2]["PC_W"] = seg_reg_values[1]["PC_R"]
		
		if !alu_input_lines_active[0]:
			ex_line_active.emit(ex_lines.RSDATA_ALU, false)
		if !alu_input_lines_active[1]:
			ex_line_active.emit(ex_lines.RTDATA_ALU2, false)
		if !alu_input_lines_active[2]:
			ex_line_active.emit(ex_lines.IMMVAL_ALU2, false)
	
	# STAGE MEM
	if StageControl.instruction_map[3] != -1:
		if stage_signals_map[3]["BRANCH"]:
			mem_line_active.emit(mem_lines.RELBRANCH_PC, true)
			seg_reg_values[2]["REL_BRANCH_R"] = PipelinedWrapper.to_hex32(stage_signals_map[3]["REL_BRANCH"])
		else:
			seg_reg_values[2]["REG_DEST_R"] = PipelinedWrapper.to_hex32(stage_signals_map[3]["REG_DEST_REGISTER"])
			if stage_signals_map[3]["MEM_READ"]:
				mem_line_active.emit(mem_lines.ALUOUT_DATAMEM, true)
				mem_line_active.emit(mem_lines.PC, true)
				mem_line_active.emit(mem_lines.DATAMEM_MEMWB, true)
				mem_line_active.emit(mem_lines.RegDst, true)
				seg_reg_values[3]["PC_W"] = PipelinedWrapper.to_hex32(stage_signals_map[3]["PC"])
				seg_reg_values[3]["ALU_OUT_W"] = PipelinedWrapper.to_hex32(stage_signals_map[3]["REG_VALUE"])
				seg_reg_values[3]["MEM_OUT_W"] = PipelinedWrapper.to_hex32(stage_signals_map[3]["MEM_OUT"])
				seg_reg_values[3]["REG_DEST_W"] = PipelinedWrapper.to_hex32(stage_signals_map[3]["REG_DEST_REGISTER"])
	#			seg_reg_values[3]["ALU_OUT_R"] = PipelinedWrapper.to_hex32(stage_signals_map[2]["ALU_OUT"])
			if stage_signals_map[3]["MEM_WRITE"]:
				mem_line_active.emit(mem_lines.ALUOUT_DATAMEM, true)
				mem_line_active.emit(mem_lines.RTDATA_DATAMEM, true)
				seg_reg_values[2]["RT_DATA_R"] = PipelinedWrapper.to_hex32(stage_signals_map[3]["RT_VALUE"])
				seg_reg_values[2]["ALU_OUT_R"] = PipelinedWrapper.to_hex32(stage_signals_map[3]["REG_VALUE"])
			if stage_signals_map[3]["REG_WRITE"]:
				mem_line_active.emit(mem_lines.RegDst, true)
				mem_line_active.emit(mem_lines.ALUOUT_DATAMEM, false)
	#			seg_reg_values[3]["ALU_OUT_R"] = PipelinedWrapper.to_hex32(stage_signals_map[2]["ALU_OUT"])
				mem_line_active.emit(mem_lines.RTDATA_DATAMEM, false)
				seg_reg_values[3]["RT_DATA_R"] = PipelinedWrapper.to_hex32(stage_signals_map[3]["RT_VALUE"])
				if !stage_signals_map[3]["MEM_READ"] and !stage_signals_map[3]["MEM_WRITE"]:
					mem_line_active.emit(mem_lines.ALUOUT_MEMWB, true)
					seg_reg_values[2]["ALU_OUT_R"] = PipelinedWrapper.to_hex32(stage_signals_map[3]["REG_VALUE"])
				seg_reg_values[3]["REG_DEST_W"] = PipelinedWrapper.to_hex32(stage_signals_map[3]["REG_DEST_REGISTER"])
				seg_reg_values[3]["ALU_OUT_W"] = PipelinedWrapper.to_hex32(stage_signals_map[3]["REG_VALUE"])
			
			seg_reg_values[3]["PC_W"] = PipelinedWrapper.to_hex32(stage_signals_map[3]["PC"])
		
		seg_reg_values[2]["PC_R"] = PipelinedWrapper.to_hex32(stage_signals_map[3]["PC"])
	
	# STAGE WB
	if StageControl.instruction_map[4] != -1:
		if stage_signals_map[4]["REG_WRITE"]:
			wb_line_active.emit(wb_lines.REGDST_REGBANK, true)
			seg_reg_values[3]["REG_DEST_R"] = PipelinedWrapper.to_hex32(stage_signals_map[4]["REG_DEST_REGISTER"])
			wb_line_active.emit(wb_lines.MUX_REGBANK, true)
			if stage_signals_map[4]["MEM_2_REG"] == 0:
				wb_line_active.emit(wb_lines.MEMOUT_MUX, true)
				seg_reg_values[3]["MEM_OUT_R"] = PipelinedWrapper.to_hex32(stage_signals_map[4]["REG_VALUE"])
			elif stage_signals_map[4]["MEM_2_REG"] == 1:
				wb_line_active.emit(wb_lines.ALUOUT_MUX, true)
				seg_reg_values[3]["ALU_OUT_R"] = PipelinedWrapper.to_hex32(stage_signals_map[4]["REG_VALUE"])
			else:
				wb_line_active.emit(wb_lines.PC_MUX, true)
				seg_reg_values[3]["ALU_OUT_R"] = PipelinedWrapper.to_hex32(stage_signals_map[4]["REG_VALUE"])
	
		seg_reg_values[3]["PC_R"] = PipelinedWrapper.to_hex32(stage_signals_map[4]["PC"])
		
	seg_regs_updated.emit()


func _on_Globals_reset_button_pressed():
	seg_reg_values = [{}, {}, {}, {}] #clear

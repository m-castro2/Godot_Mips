extends Node

enum if_lines {ADD_IFID, MUX_PC, PC_INSTMEM, PC_ADD, INSTMEM_IFID, _4_ADD, ADD_PC}

enum id_lines {HDU_PC, PC, ImmValue, INST_RDREG1, INST_RDREG2, INST_IMMVAL,\
	 INST20_REGDST, INST15_REGDST, INST_CONTROL, RS, RT, INST_ADD, PC_ADD, \
	RDDATA_RSDATA, RDDATA2_RTDATA, ADD_PC, INST_BASE, RSDATA_PC, INST_PC}

enum ex_lines {PC, RegDst, ALUEXMEM, RSDATA_ALU, RTDATA_ALU2, IMMVAL_ALU2, \
	RS_FU, RT_FU, ALUCONTROL_ALU, RTDATA_EXMEM, PC_ADD, IMMVAL_ADD, \
	FU_ALU1, FU_ALU2, FU_RTDATA}

enum mem_lines {PC, RegDst, ALUOUT_DATAMEM, ALUOUT_ALU1, ALUOUT_ALU2, \
	REGDST_FORWARDINGUNIT, DATAMEM_MEMWB, ALUOUT_MEMWB, RTDATA_DATAMEM, ALUOUT_RT, \
	RELBRANCH_PC}

enum wb_lines {PC_MUX, REGDST_REGBANK, ALUOUT_MUX, MEMOUT_MUX, \
	REGDST_FORWARDINGUNIT, ALUOUT_ALU1, ALUOUT_ALU2, MUX_REGBANK, ALUOUT_RT}

enum Register_Type {IFID, IDEX, EXMEM, WB}

signal if_line_active(line: if_lines)
signal id_line_active(line: id_lines)
signal ex_line_active(line: ex_lines)
signal mem_line_active(line: mem_lines)
signal wb_line_active(line: wb_lines)

signal if_stage_updated
signal wb_stage_updated
signal stage_register_updated(register: Register_Type)

signal redraw_lines(register: int)

var stage_detail_path: Array = []
var stage_register_path: Array = []


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
	
	var branch_stage = ConfigManager.get_value("Settings/CPU", "branch_stage")
	
	# STAGE IF
	if StageControl.instruction_map[0] != -1:
		if stage_signals_map[0]["PC_WR"] == 1: 
			if_line_active.emit(if_lines.PC_INSTMEM)
			if_line_active.emit(if_lines.INSTMEM_IFID)
			if_line_active.emit(if_lines.ADD_IFID)
			if_line_active.emit(if_lines.PC_INSTMEM)
			if_line_active.emit(if_lines._4_ADD)
			if_line_active.emit(if_lines.PC_ADD)
			match stage_signals_map[0]["PC_SRC"]:
				0:
					if_line_active.emit(if_lines.ADD_PC)
				1:
					if !branch_stage: #0 for ID, 1 for MEM
						id_line_active.emit(id_lines.ADD_PC)
					else:
						mem_line_active.emit(mem_lines.RELBRANCH_PC)
				2:
					id_line_active.emit(id_lines.RSDATA_PC)
				3:
					id_line_active.emit(id_lines.INST_PC)
			
		id_line_active.emit(id_lines.HDU_PC)
	
	# STAGE ID
	if StageControl.instruction_map[1] != -1:
		id_line_active.emit(id_lines.PC)
		id_line_active.emit(id_lines.INST_BASE)
		if stage_signals_map[1]["BRANCH"]:
			id_line_active.emit(id_lines.PC_ADD)
			id_line_active.emit(id_lines.INST_ADD)
		else:
			id_line_active.emit(id_lines.INST_RDREG1)
			id_line_active.emit(id_lines.RDDATA_RSDATA)
			if stage_signals_map[1]["ALU_SRC"]:
				id_line_active.emit(id_lines.INST_IMMVAL)
			else:
				id_line_active.emit(id_lines.INST_RDREG2)
				id_line_active.emit(id_lines.RDDATA2_RTDATA)
			if stage_signals_map[1]["REG_WRITE"]:
				if stage_signals_map[1]["REG_DEST"] == 0:
					id_line_active.emit(id_lines.INST20_REGDST)
				elif stage_signals_map[1]["REG_DEST"] == 1:
					id_line_active.emit(id_lines.INST15_REGDST)
			if stage_signals_map[1]["ALU_SRC"]:
				id_line_active.emit(id_lines.INST_IMMVAL)
			
			#id_line_active.emit(id_lines.RS)
			#id_line_active.emit(id_lines.RT)
			else:
				pass # $ra
	
	# STAGE EX
	if StageControl.instruction_map[2] != -1:
		ex_line_active.emit(ex_lines.PC)
		ex_line_active.emit(ex_lines.ALUEXMEM)
		ex_line_active.emit(ex_lines.RegDst)
		ex_line_active.emit(ex_lines.ALUCONTROL_ALU)
		if stage_signals_map[2]["ALU_SRC"]:
			ex_line_active.emit(ex_lines.IMMVAL_ALU2)

		match stage_signals_map[2]["RS_FU"]:
			0:
				ex_line_active.emit(ex_lines.RSDATA_ALU)
			1:
				ex_line_active.emit(ex_lines.FU_ALU1)
				mem_line_active.emit(mem_lines.REGDST_FORWARDINGUNIT)
			2:
				pass
			3:
				ex_line_active.emit(ex_lines.FU_ALU1)
				wb_line_active.emit(wb_lines.REGDST_FORWARDINGUNIT)
			4:
				pass
		
		match stage_signals_map[2]["RT_FU"]:
			0:
				if !stage_signals_map[2]["ALU_SRC"]:
					ex_line_active.emit(ex_lines.RTDATA_ALU2)
				else:
					ex_line_active.emit(ex_lines.RTDATA_EXMEM)
			1:
				mem_line_active.emit(mem_lines.REGDST_FORWARDINGUNIT)
				if !stage_signals_map[2]["ALU_SRC"]:
					ex_line_active.emit(ex_lines.FU_ALU2)
				else:
					ex_line_active.emit(ex_lines.FU_RTDATA)
			2:
				pass
			3:
				wb_line_active.emit(wb_lines.REGDST_FORWARDINGUNIT)
				if !stage_signals_map[2]["ALU_SRC"]:
					ex_line_active.emit(ex_lines.FU_ALU2)
				else:
					ex_line_active.emit(ex_lines.FU_RTDATA)
			4:
				pass
		
		ex_line_active.emit(ex_lines.RTDATA_EXMEM) # origin gets updated based on IMMVAL?RTDATA_ALU2
		#ex_line_active.emit(ex_lines.RS_FU)
		#ex_line_active.emit(ex_lines.RT_FU)
		if stage_signals_map[2]["RELBRANCH"]:
			ex_line_active.emit(ex_lines.PC_ADD)
			ex_line_active.emit(ex_lines.IMMVAL_ADD)
			ex_line_active.emit(ex_lines.RT_FU)
	
	# STAGE MEM
	if StageControl.instruction_map[3] != -1:
		if stage_signals_map[3]["MEM_READ"]:
			mem_line_active.emit(mem_lines.ALUOUT_DATAMEM)
			mem_line_active.emit(mem_lines.PC)
			mem_line_active.emit(mem_lines.DATAMEM_MEMWB)
			mem_line_active.emit(mem_lines.RegDst)
		if stage_signals_map[3]["MEM_WRITE"]:
			mem_line_active.emit(mem_lines.ALUOUT_DATAMEM)
			mem_line_active.emit(mem_lines.RTDATA_DATAMEM)
		if stage_signals_map[3]["REG_WRITE"]:
			mem_line_active.emit(mem_lines.RegDst)
			mem_line_active.emit(mem_lines.ALUOUT_MEMWB)
	
	# STAGE WB
	if StageControl.instruction_map[4] != -1:
		if stage_signals_map[4]["REG_WRITE"]:
			wb_line_active.emit(wb_lines.REGDST_REGBANK)
			wb_line_active.emit(wb_lines.MUX_REGBANK)
			if stage_signals_map[4]["MEM_2_REG"] == 0:
				wb_line_active.emit(wb_lines.PC_MUX)
			elif stage_signals_map[4]["MEM_2_REG"] == 1:
				wb_line_active.emit(wb_lines.MEMOUT_MUX)
			else:
				wb_line_active.emit(wb_lines.ALUOUT_MUX)
	

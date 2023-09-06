extends Node

enum if_lines {ADD_IFID, MUX_PC, PC_INSTMEM, PC_ADD, INSTMEM_IFID, _4_ADD, ADD_PC}

enum id_lines {HDU_PC, PC, ImmValue, INST_RDREG1, INST_RDREG2, INST_IMMVAL,\
	 INST20_REGDST, INST15_REGDST, INST_CONTROL, RS, RT, INST_ADD, PC_ADD, \
	RDDATA_RSDATA, RDDATA2_RTDATA, ADD_PC, INST_BASE}

enum ex_lines {PC, RegDst, ALUEXMEM, RSDATA_ALU, RTDATA_ALU2, IMMVAL_ALU2, \
	RS_HDU, RT_HDU, ALUCONTROL_ALU, RTDATA_EXMEM}

enum mem_lines {PC, RegDst, ALUOUT_DATAMEM, ALUOUT_ALU1, ALUOUT_ALU2, \
	REGDST_FORWARDINGUNIT, DATAMEM_MEMWB, ALUOUT_MEMWB, RTDATA_DATAMEM}

enum wb_lines {PC_MUX, REGDST_REGBANK, ALUOUT_MUX, MEMOUT_MUX, \
	REGDST_FORWARDINGUNIT, ALUOUT_ALU1, ALUOUT_ALU2, MUX_REGBANK}

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


func activate_lines(stage_signals_map: Array):
	if !Globals.current_cycle:
		return
	
	# STAGE IF
	if stage_signals_map[0]["PC_WR"] == 1: 
		if_line_active.emit(if_lines.PC_INSTMEM)
		if_line_active.emit(if_lines.INSTMEM_IFID)
		if_line_active.emit(if_lines.ADD_IFID)
		if_line_active.emit(if_lines.PC_INSTMEM)
		if_line_active.emit(if_lines._4_ADD)
		if_line_active.emit(if_lines.PC_ADD)
		if stage_signals_map[0]["PC_SRC"] == 0:
			if_line_active.emit(if_lines.ADD_PC)
		if stage_signals_map[0]["PC_SRC"] == 1:
			id_line_active.emit(id_lines.ADD_PC)
	id_line_active.emit(id_lines.HDU_PC)
	
	# STAGE ID
	id_line_active.emit(id_lines.PC)
	id_line_active.emit(id_lines.INST_BASE)
	id_line_active.emit(id_lines.INST_RDREG1)
	id_line_active.emit(id_lines.INST_RDREG2)
	id_line_active.emit(id_lines.RDDATA_RSDATA)
	id_line_active.emit(id_lines.RDDATA2_RTDATA)
	id_line_active.emit(id_lines.RS)
	id_line_active.emit(id_lines.RT)
	if stage_signals_map[1]["BRANCH"]:
		id_line_active.emit(id_lines.PC_ADD)
		id_line_active.emit(id_lines.INST_ADD)
		id_line_active.emit(id_lines.ADD_PC)
	if stage_signals_map[1]["REG_DEST"] == 0:
		id_line_active.emit(id_lines.INST20_REGDST)
	elif stage_signals_map[1]["REG_DEST"] == 1:
		id_line_active.emit(id_lines.INST15_REGDST)
	else:
		pass # $ra
	
	# STAGE EX
	ex_line_active.emit(ex_lines.PC)
	ex_line_active.emit(ex_lines.ALUEXMEM)
	ex_line_active.emit(ex_lines.RegDst)
	ex_line_active.emit(ex_lines.ALUCONTROL_ALU)
	if stage_signals_map[2]["ALU_SRC"]:
		ex_line_active.emit(ex_lines.IMMVAL_ALU2)
	else:
		ex_line_active.emit(ex_lines.RTDATA_ALU2)
	
	ex_line_active.emit(ex_lines.RTDATA_EXMEM) # origin gets updated based on IMMVAL?RTDATA_ALU2
	
	# STAGE MEM
	mem_line_active.emit(mem_lines.PC)
	mem_line_active.emit(mem_lines.DATAMEM_MEMWB)
	mem_line_active.emit(mem_lines.RegDst)
	mem_line_active.emit(mem_lines.ALUOUT_DATAMEM)
	mem_line_active.emit(mem_lines.ALUOUT_MEMWB)
	mem_line_active.emit(mem_lines.RTDATA_DATAMEM)
	
	# STAGE WB
	if stage_signals_map[4]["REG_WRITE"]:
		wb_line_active.emit(wb_lines.REGDST_REGBANK)
		wb_line_active.emit(wb_lines.MUX_REGBANK)
	if stage_signals_map[4]["MEM_2_REG"] == 0:
		wb_line_active.emit(wb_lines.PC_MUX)
	elif stage_signals_map[4]["MEM_2_REG"] == 1:
		wb_line_active.emit(wb_lines.MEMOUT_MUX)
	else:
		wb_line_active.emit(wb_lines.ALUOUT_MUX)
	

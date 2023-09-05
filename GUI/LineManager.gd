extends Node

enum if_lines {ADD_IFID, MUX_PC, PC_INSTMEM, PC_ADD, INSTMEM_IFID, _4_ADD, ADD_PC}

enum id_lines {HDU_PC, PC, ImmValue, INST_RDREG1, INST_RDREG2, INST_IMMVAL,\
	 INST20_REGDST, INST15_REGDST, INST_CONTROL, RS, RT, INST_ADD, PC_ADD, \
	RDDATA_RSDATA, RDDATA2_RTDATA, ADD_PC}

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
	#id_line_active.emit(id_lines.HDU_PC)
	

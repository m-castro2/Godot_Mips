extends Node

enum if_lines {ADD_MUX, ADD_IFID, MUX_PC, PC_INSTMEM, PC_ADD, INSTMEM_IFID}

signal if_line_active(line: if_lines)

extends Node

const STAGES_COUNT = 5

var colors: Array[Color] = [Color.TOMATO, Color.MEDIUM_SEA_GREEN, Color.DARK_RED, Color.YELLOW_GREEN, Color.SLATE_BLUE, Color.MEDIUM_PURPLE]
var colors_map: Dictionary = {}
var used_colors: Array = []

var instruction_map: Array = [] # map[cycle][stage] = instruction_idx
var first_active_instruction_index: int = 0

signal update_stage_colors(colors_map, instructions)


func update_instruction_map(instructions, loaded_instructions: Array, diagram: Array):
	if !Globals.current_cycle:
		instruction_map.push_back([]) #no diagram at cycle 0
		return

	instruction_map.push_back([])
	for i in range(loaded_instructions.size()-2, first_active_instruction_index-1, -1):
		instruction_map[Globals.current_cycle].push_back(get_instruction_from_address(instructions, loaded_instructions[i+1]))
	while instruction_map[Globals.current_cycle].size() > 5:
		instruction_map[Globals.current_cycle].pop_back() # remove finished instructions
	
	print(instruction_map[Globals.current_cycle])
	calculate_stage_color(instruction_map[Globals.current_cycle])
	update_stage_colors.emit(colors_map, instruction_map[Globals.current_cycle])

func calculate_stage_color(instruction_map):
	for color_key in colors_map.keys():
		if !(color_key in instruction_map):
			used_colors.erase(colors_map[color_key])
			colors_map.erase(color_key)
	for instruction in instruction_map:
		if !(instruction in colors_map.keys()):
			for color in colors:
				if !(color in used_colors):
					colors_map[instruction] = color
					used_colors.push_back(color)
					break


func get_instruction_from_address(instructions, address):
	for i in range(0, instructions.size() - 1):
		if str(instructions[i][0]) == address:
			return i
	

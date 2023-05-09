extends Node

const STAGES_COUNT = 5

var colors: Array[Color] = [Color.TOMATO, Color.MEDIUM_SEA_GREEN, Color.DARK_RED, Color.YELLOW_GREEN, Color.SLATE_BLUE, Color.MEDIUM_PURPLE]
var colors_map: Dictionary = {}
var used_colors: Array = []

var instruction_map: Array = [] # map[stage] = instruction_idx

signal update_stage_colors(colors_map, instructions)


func update_instruction_map(instructions, loaded_instructions: Array, diagram: Array):
	if !Globals.current_cycle:
		return
	
	instruction_map.clear()
	for i in range(loaded_instructions.size()-1, -1, -1):
		instruction_map.push_back(get_instruction_from_address(instructions, loaded_instructions[i]))
	while instruction_map.size() > 5:
		instruction_map.pop_back() # remove finished instructions
	calculate_stage_color(instruction_map)
	update_stage_colors.emit(colors_map, instruction_map)

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
	for i in range(0, instructions.size()):
		if str(instructions[i][0]) == address:
			return i

func reset():
	colors_map.clear()
	used_colors.clear()
	update_stage_colors.emit(colors_map, instruction_map)

extends Node

const STAGES_COUNT = 5

@onready var colors: Array[Color] = [
	ConfigManager.get_value("Settings/UI", "color_mode_0"),
	ConfigManager.get_value("Settings/UI", "color_mode_1"),
	ConfigManager.get_value("Settings/UI", "color_mode_2"),
	ConfigManager.get_value("Settings/UI", "color_mode_3"),
	ConfigManager.get_value("Settings/UI", "color_mode_4"),
	]

enum coloring_type {STAGE_COLOR, INSTRUCTION_COLOR}
@onready var color_system: coloring_type = ConfigManager.get_value("Settings/UI", "color_mode_idx")

var colors_map: Dictionary = {}
var used_colors: Array = []

var instruction_map: Array = [] # map[stage] = instruction_idx

signal update_stage_colors(colors_map, instructions)
signal instruction_map_updated

func _ready():
	Globals.stage_color_changed.connect(_on_stage_color_changed)
	Globals.stage_color_mode_changed.connect(_on_stage_color_mode_changed)


func _on_stage_color_changed(p_color: Color, index: int) -> void:
	for color in colors_map.values():
		if color == colors[index]:
			colors_map[colors_map.find_key(color)] = p_color
	for i in range(0, used_colors.size()):
		if used_colors[i] == colors[index]:
			used_colors[i] = p_color
	
	colors[index] = p_color
	update_stage_colors.emit(colors_map, instruction_map)


func _on_stage_color_mode_changed(mode: int) -> void:
	color_system = mode as coloring_type
	if color_system:
		var i: int = 0
		for key in colors_map.keys():
			if key == -1:
				used_colors.remove_at(i)
				break
			i = i +1
	calculate_stage_color(instruction_map)
	update_stage_colors.emit(colors_map, instruction_map)


func update_instruction_map(_instructions: Array, _loaded_instructions: Array, \
		_diagram: Dictionary) -> void:
	if !Globals.is_program_loaded:
		return
	
	instruction_map.clear()
	if Globals.current_cycle:
		instruction_map.push_back(PipelinedWrapper.diagram[0])
		instruction_map.push_back(PipelinedWrapper.diagram[1])
		instruction_map.push_back(PipelinedWrapper.diagram[2])
		instruction_map.push_back(PipelinedWrapper.diagram[3])
		instruction_map.push_back(PipelinedWrapper.diagram[4])
	
	instruction_map_updated.emit()
	calculate_stage_color(instruction_map)
	update_stage_colors.emit(colors_map, instruction_map)


func calculate_stage_color(p_instruction_map):
	if color_system:
		for color_key in colors_map.keys():
			if !(color_key in p_instruction_map):
				used_colors.erase(colors_map[color_key])
				colors_map.erase(color_key)
		for instruction in p_instruction_map:
			if !(instruction in colors_map.keys()) and instruction != -1:
				for color in colors:
					if !(color in used_colors):
						colors_map[instruction] = color
						used_colors.push_back(color)
						break
			if instruction == -1:
				colors_map[instruction] = Color.TRANSPARENT
	
	else:
		colors_map.clear()
		used_colors.clear()
		for i in range(0, instruction_map.size()):
			colors_map[instruction_map[i]] = colors[i]
			used_colors.push_back(colors[i])


func get_instruction_from_address(instructions, address): #UNUSED?
	for i in range(0, instructions.size()):
		if str(instructions[i][0]) == address:
			return i


func reset():
	colors_map.clear()
	used_colors.clear()
	update_stage_colors.emit(colors_map, instruction_map)

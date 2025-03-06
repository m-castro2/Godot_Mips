extends Control

@export var stages: Array[Stage]
var expanded_stage = -1

enum StageSizeTypes {NORMAL, EXPANDED, COMPRESSED, WB}
var test_sizes: Array[float] = [0,0,0,0]

func _ready():
	Globals.expand_stage.connect(_on_expand_stage)
	Globals.stage_component_requested.connect(get_stage_component)


func clear_instructions():
	%InstructionsPanel.clear_instructions()


func add_instructions(p_instructions: Array, description: String):
	%InstructionsPanel.add_instructions(p_instructions)
	%InstructionsPanel.add_description(description)


func _on_resized():
	calculate_stage_sizes()
	var height = size.y * .85 #stage registers size is 65% of space available
	var max_size: float = 0
	for child in get_child(0).get_children():
		if child is StageRegister:
			child.get_child(0).custom_minimum_size.y = height #+ 28 * child.has_block.count(true) # 28 height of extra registers on top
			child.get_child(0).size.y = child.get_child(0).custom_minimum_size.y
			child.get_child(0).add_theme_constant_override("margin_top", 41) #41 height of stage button with concept theme
			max_size = max(max_size, child.get_child(0).size.y)
	
	for child in get_child(0).get_children():
		if child is StageRegister:
			child.get_child(0).position.y = (size.y - max_size)/2 + (max_size - child.get_child(0).size.y)


func _on_expand_stage(stage_number: int) -> void:
	if Globals.current_expanded_stage == -1: #nothing is expanded
		expanded_stage = stage_number
		(stages[expanded_stage] as Stage).tween_size()
	elif expanded_stage == stage_number: #reduce expanded stage
		(stages[expanded_stage] as Stage).tween_size()
		expanded_stage = -1
	else: # one stage is already expanded
		(stages[expanded_stage] as Stage).tween_size()
		expanded_stage = stage_number
		(stages[expanded_stage] as Stage).tween_size()
		
	Globals.current_expanded_stage = expanded_stage


func get_stage_component(stage_number: int, component_name: String, caller_ref: NodePath):
	get_node(caller_ref).set_outside_component(stages[stage_number].get("detail").get(component_name), "origin")


func calculate_stage_sizes():
	var available_space = size.x - 31 * 4 #31 = seg reg width
	var divide_by:= 6
	if available_space < 172 * 6:
		available_space = available_space - 171 # instructions minimum size is 171
		divide_by = 5
	test_sizes[StageSizeTypes.NORMAL] = available_space * 1 / divide_by
	test_sizes[StageSizeTypes.EXPANDED] = available_space * 2.75 / (divide_by + 1.75)
	test_sizes[StageSizeTypes.COMPRESSED] = (available_space - (available_space * 2.75 / (divide_by + 1.75))) / (divide_by-1)
	test_sizes[StageSizeTypes.WB] = available_space * 1.5 / (divide_by + .5)
	Globals.tweened_stage_sizes = test_sizes

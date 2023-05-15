extends Control

@export var stages: Array[NodePath]
var expanded_stage = -1


func _ready():
	Globals.expand_stage.connect(_on_expand_stage)


func clear_instructions():
	%InstructionsPanel.clear_instructions()


func add_instructions(p_instructions: Array):
	%InstructionsPanel.add_instructions(p_instructions)


func _on_resized():
	var height = size.y * .75 #stage registers size is 75% of space available
	for child in get_child(0).get_children():
		if child is MarginContainer:
			var child2 = child.get_child(0)
			child2.custom_minimum_size.y = height
			child.add_theme_constant_override("margin_top", 41) #41 height of stage button with concept theme


func _on_expand_stage(stage_number: int) -> void:
	if expanded_stage == -1: #nothing is expanded
		expanded_stage = stage_number
		(get_node(stages[expanded_stage]) as Stage).tween_size()
		return
	if expanded_stage == stage_number: #reduce expanded stage
		(get_node(stages[expanded_stage]) as Stage).tween_size()
		expanded_stage = -1
	else: # one stage is already expanded
		(get_node(stages[expanded_stage]) as Stage).tween_size()
		expanded_stage = stage_number
		(get_node(stages[expanded_stage]) as Stage).tween_size()

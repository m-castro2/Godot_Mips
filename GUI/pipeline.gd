extends Control


func clear_instructions():
	%InstructionsPanel.clear_instructions()


func add_instructions(p_instructions: Array):
	%InstructionsPanel.add_instructions(p_instructions)


func _on_resized():
	var height = size.y * .75
	for child in get_child(0).get_children():
		if child is MarginContainer:
			var child2 = child.get_child(0)
			child2.custom_minimum_size.y = height
			child.add_theme_constant_override("margin_top", 41) #41 height of stage button with concept theme

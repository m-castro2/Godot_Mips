extends Control

@onready var codeEdit: CodeEdit = %CodeEdit
@onready var labelContainer: VBoxContainer = %LabelVBoxContainer

func add_instructions(p_instructions: Array) -> void:
	clear_instructions()
	codeEdit.visible = false
	for instruction in p_instructions:
		var label: RichTextLabel = RichTextLabel.new()
		label.text = instruction[1].right(-11) # delete first 11 chars (inst mem addr)
		label.fit_content = true
		labelContainer.add_child(label)

func clear_instructions() -> void:
	codeEdit.text = ""
	for child in %LabelVBoxContainer.get_children():
		if child is RichTextLabel:
			child.queue_free()

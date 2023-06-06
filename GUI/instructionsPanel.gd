extends Control

@onready var codeEdit: CodeEdit = %CodeEdit
@onready var labelContainer: VBoxContainer = %LabelVBoxContainer

func _ready() -> void:
	StageControl.update_stage_colors.connect(_on_update_stage_colors)


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


func _on_update_stage_colors(colors_map: Dictionary, _instructions: Array) -> void:
	for child in labelContainer.get_children():
		(child as RichTextLabel).remove_theme_stylebox_override("normal")
	for key in colors_map.keys():
		if key == null:
			continue
		var styleBox: StyleBoxFlat = StyleBoxFlat.new()
		styleBox.bg_color = colors_map[key]
		(labelContainer.get_child(key) as RichTextLabel).add_theme_stylebox_override("normal", styleBox)

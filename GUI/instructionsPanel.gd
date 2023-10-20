extends Control

@onready var label_v_box_container = %LabelVBoxContainer
@onready var description_label = $PanelContainer/MarginContainer/VSplitContainer/DescriptionVBoxContainer/DescriptionScrollContainer/DescriptionLabel
@onready var description_title = $PanelContainer/MarginContainer/VSplitContainer/DescriptionVBoxContainer/DescriptionTitle
@onready var description_v_box_container = $PanelContainer/MarginContainer/VSplitContainer/DescriptionVBoxContainer
@onready var v_split_container: VSplitContainer = $PanelContainer/MarginContainer/VSplitContainer
@onready var scroll_container: ScrollContainer = $PanelContainer/MarginContainer/VSplitContainer/VBoxContainer/ScrollContainer

func _ready() -> void:
	StageControl.update_stage_colors.connect(_on_update_stage_colors)


func add_instructions(p_instructions: Array) -> void:
	clear_instructions()
	for instruction in p_instructions:
		var label: RichTextLabel = RichTextLabel.new()
		label.text = instruction[1].right(-11) # delete first 11 chars (inst mem addr)
		label.fit_content = true
		label_v_box_container.add_child(label)


func clear_instructions() -> void:
	for child in %LabelVBoxContainer.get_children():
		if child is RichTextLabel:
			child.queue_free()
	description_label.text = ""


func _on_update_stage_colors(colors_map: Dictionary, _instructions: Array) -> void:
	if !label_v_box_container.get_child_count():
		return
	for child in label_v_box_container.get_children():
		(child as RichTextLabel).remove_theme_stylebox_override("normal")
	for key in colors_map.keys():
		if key < 0 or key == null:
			continue
		var styleBox: StyleBoxFlat = StyleBoxFlat.new()
		styleBox.bg_color = colors_map[key]
		(label_v_box_container.get_child(key) as RichTextLabel).add_theme_stylebox_override("normal", styleBox)
	
	if Globals.current_cycle:
		scroll_container.ensure_control_visible(label_v_box_container.get_child(StageControl.instruction_map[0]))


func add_description(description: String) -> void:
	if description == "":
		description_label.hide()
		v_split_container.split_offset = 32000 # max offset to force it to use minimum space, hide?
	else:
		description_label.show()
		v_split_container.split_offset = 0
		description_label.text = description

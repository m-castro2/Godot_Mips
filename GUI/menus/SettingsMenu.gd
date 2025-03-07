extends PanelContainer

@onready var color_mode_options = $MarginContainer/TabContainer/UI/MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/ColorModeOptions
@onready var color_mode_option_button = $MarginContainer/TabContainer/UI/MarginContainer/HBoxContainer/VBoxContainer/ColorMode/ColorModeOptionButton
@onready var scaling_option_button = %ScalingOptionButton

const color_mode_option: PackedScene = preload("res://color_mode_option.tscn")

signal option_button_focus_changed(value: bool)

func _ready() -> void:
	Globals.can_instantiate_load_menu = false
	Globals.active_menu = "settings"
	color_mode_option_button.selected = ConfigManager.get_value("Settings/UI", "color_mode_idx")
	add_color_options()
	
	# CPU Settings
	%BranchStageOptionButton.selected = ConfigManager.get_value("Settings/CPU", "branch_stage")
	%BranchTypeOptionButton.selected = ConfigManager.get_value("Settings/CPU", "branch_type")
	%HDUCheckBox.button_pressed = ConfigManager.get_value("Settings/CPU", "hdu_enabled")
	%FUCheckBox.button_pressed = ConfigManager.get_value("Settings/CPU", "fu_enabled")
	scaling_option_button.selected = ConfigManager.get_value("Settings/UI", "scaling")


func add_color_options() -> void:
	for i in range(0, 5): # stage count config?
		var color = ConfigManager.get_value("Settings/UI", "color_mode_" + str(i))
		var option: HBoxContainer = color_mode_option.instantiate()
		(option.get_child(0) as Label).text = "Instruction " + str(i) + " color: " \
			if color_mode_option_button.selected else "Stage " + str(i) + " color: "
		(option.get_child(1) as ColorPickerButton).color = Color(color)
		(option.get_child(1) as ColorPickerButton).color.a = 1.0
		(option.get_child(1) as ColorPickerButton).color_changed.connect(_on_color_picker_color_changed.bind(i))
		option.name = str(i)
		color_mode_options.add_child(option)


func update_color_options_label() -> void:
	for child in color_mode_options.get_children():
		(child.get_child(0) as Label).text = "Instruction " + child.name + " color: " \
			if color_mode_option_button.selected else "Stage " + child.name + " color: "


func _exit_tree() -> void:
	Globals.can_instantiate_load_menu = true
	Globals.active_menu = ""


func _on_close_pressed():
	Globals.close_menu.emit()
	queue_free()


func _on_color_mode_option_button_item_selected(index):
	ConfigManager.update_value("Settings/UI", "color_mode_idx", index)
	update_color_options_label()
	Globals.stage_color_mode_changed.emit(index)


func _on_color_picker_color_changed(color, i):
	ConfigManager.update_value("Settings/UI", "color_mode_" + str(i), color)
	Globals.stage_color_changed.emit(color, i)


func _on_branch_type_option_button_item_selected(index):
	ConfigManager.update_value("Settings/CPU", "branch_type", index)
	Globals.branch_type_changed.emit(index)
	%BranchTypeOptionButton.release_focus()
	option_button_focus_changed.emit(false)


func _on_branch_stage_option_button_item_selected(index):
	ConfigManager.update_value("Settings/CPU", "branch_stage", index)
	Globals.branch_stage_changed.emit(index)
	%BranchStageOptionButton.release_focus()
	option_button_focus_changed.emit(false)


func _on_hdu_check_box_toggled(button_pressed):
	ConfigManager.update_value("Settings/CPU", "hdu_enabled", button_pressed)
	Globals.hdu_available_changed.emit(button_pressed)


func _on_fu_check_box_toggled(button_pressed):
	ConfigManager.update_value("Settings/CPU", "fu_enabled", button_pressed)
	Globals.fu_available_changed.emit(button_pressed)


func _on_scaling_option_button_item_selected(index):
	ConfigManager.update_value("Settings/UI", "scaling", index)
	Globals.window_scaling_changed.emit(index)


func _on_branch_stage_option_button_focus_entered():
	option_button_focus_changed.emit(true)


func _on_branch_type_option_button_focus_entered():
	option_button_focus_changed.emit(true)


func _on_branch_stage_option_button_focus_exited():
	option_button_focus_changed.emit(false)


func _on_branch_type_option_button_focus_exited():
	option_button_focus_changed.emit(false)

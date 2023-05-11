extends Control
class_name Stage


var expanded = false
var detail: Panel = null
@export var stage_name: String
@export var stage_number: int
@onready var expand_stage_signal: Signal = get_parent().get_parent().expand_stage

var lines_groups: Array[String] = ["PC_InstMem", "Mux_PC", "PC_Add", "Add_IFID", "InstMem_IFID", "Add_Mux"]

func _ready() -> void:
	$VBoxContainer/PanelContainer/StageButton.text = stage_name
	StageControl.update_stage_colors.connect(_on_update_stage_colors)
	get_tree().root.size_changed.connect(_on_resized)
	if stage_name == "IF":
		$VBoxContainer.add_child(load("res://stages/" + stage_name.to_lower() + "_detail.tscn").instantiate())
		detail = $VBoxContainer.get_child(1)


func _on_stage_button_pressed():
	expand_stage_signal.emit(stage_number)


func tween_size():
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "size_flags_stretch_ratio", 1 if expanded else 3, 0.15)
	expanded = !expanded
	if detail:
		if !expanded:
			detail.show_detail(expanded)
			await tween.finished
		else:
			await tween.finished
			detail.show_detail(expanded)


func _on_update_stage_colors(colors_map: Dictionary, instructions):
	if colors_map.size() > stage_number:
		var styleBox: StyleBoxFlat = StyleBoxFlat.new()
		styleBox.bg_color = colors_map[instructions[stage_number]]
		$VBoxContainer/PanelContainer/StageButton.add_theme_stylebox_override("normal", styleBox)
		return
	elif colors_map.size() == 0:
		$VBoxContainer/PanelContainer/StageButton.remove_theme_stylebox_override("normal")


func _on_resized():
	if expanded and detail:
		await get_tree().process_frame #wait a frame for nodes position to be updated 
		detail.calculate_positions()
		detail.draw_lines()

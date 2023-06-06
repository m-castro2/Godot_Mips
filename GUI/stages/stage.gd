extends Control
class_name Stage


var expanded = false
var detail: Panel = null
@export var stage_name: String
@export var stage_number: int

var lines_groups: Array[String] = ["PC_InstMem", "Mux_PC", "PC_Add", "Add_IFID", "InstMem_IFID", "Add_Mux"]

func _ready() -> void:
	$VBoxContainer/PanelContainer/StageButton.text = stage_name
	StageControl.update_stage_colors.connect(_on_update_stage_colors)
	Globals.stage_color_mode_changed.connect(_on_stage_color_mode_changed)
	get_tree().root.size_changed.connect(_on_resized)
	
	$VBoxContainer.add_child(load("res://stages/" + stage_name.to_lower() + "_detail.tscn").instantiate())
	detail = $VBoxContainer.get_child(1)
	add_fixed_stage_color()


func _on_stage_button_pressed():
	Globals.expand_stage.emit(stage_number)


func tween_size():
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "size_flags_stretch_ratio", 1 if expanded else 3, 0.15)
	expanded = !expanded
	if detail:
		if !expanded:
			detail.show_detail(expanded)
			await tween.finished
			Globals.stage_tween_finished.emit()
		else:
			await tween.finished
			Globals.stage_tween_finished.emit()
			detail.show_detail(expanded)


func add_fixed_stage_color():
	if !StageControl.color_system: # fixed stage color
		var styleBox: StyleBoxFlat = StyleBoxFlat.new()
		styleBox.bg_color = StageControl.colors[stage_number]
		$VBoxContainer/PanelContainer/StageButton.add_theme_stylebox_override("normal", styleBox)
		return


func _on_update_stage_colors(colors_map: Dictionary, instructions):
	if StageControl.color_system:
		# fixed instruction color
		if colors_map.size() > stage_number:
			var styleBox: StyleBoxFlat = StyleBoxFlat.new()
			styleBox.bg_color = colors_map[instructions[stage_number]]
			$VBoxContainer/PanelContainer/StageButton.add_theme_stylebox_override("normal", styleBox)
			return
		else:#if colors_map.size() == 0:
			$VBoxContainer/PanelContainer/StageButton.remove_theme_stylebox_override("normal")
	else:
		add_fixed_stage_color()


func _on_resized():
	if expanded and detail:
		await get_tree().process_frame #wait a frame for nodes position to be updated
		await get_tree().process_frame #twice?
		detail.calculate_positions()
		detail.draw_lines()


func _on_stage_color_mode_changed(mode: int) -> void:
	pass

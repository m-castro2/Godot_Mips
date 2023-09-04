extends Control
class_name Stage


var expanded: bool = false
var detail: Panel = null
@export var stage_name: String
@export var stage_number: int

var stage_color: Color

var lines_groups: Array[String] = ["PC_InstMem", "Mux_PC", "PC_Add", "Add_IFID", "InstMem_IFID", "Add_Mux"]

func _ready() -> void:
	$VBoxContainer/PanelContainer/StageButton.text = stage_name
	StageControl.update_stage_colors.connect(_on_update_stage_colors)
	Globals.stage_color_mode_changed.connect(_on_stage_color_mode_changed)
	get_tree().root.size_changed.connect(_on_resized)
	
	add_fixed_stage_color()
	
	$VBoxContainer.add_child(load("res://stages/" + stage_name.to_lower() + "_detail.tscn").instantiate())
	detail = $VBoxContainer.get_child(1)
	detail.stage_color = stage_color
	LineManager.add_stage_detail_path(detail.get_path())


func _on_stage_button_pressed():
	Globals.expand_stage.emit(stage_number)


func tween_size():
	var tween: Tween = get_tree().create_tween()
	Globals.is_stage_tweening = true
	tween.tween_property(self, "size_flags_stretch_ratio", 1 if expanded else 2.75, 0.15)
	expanded = !expanded
	if detail:
		if !expanded:
			detail.show_detail(expanded)
			await tween.finished
			Globals.stage_tween_finished.emit(stage_number)
		else:
			await tween.finished
			Globals.stage_tween_finished.emit(stage_number)
			detail.show_detail(expanded)
	Globals.is_stage_tweening = false


func add_fixed_stage_color():
	if !StageControl.color_system: # fixed stage color
		var styleBox: StyleBoxFlat = StyleBoxFlat.new()
		styleBox.bg_color = StageControl.colors[stage_number]
		stage_color = styleBox.bg_color
		detail.stage_color = stage_color
		$VBoxContainer/PanelContainer/StageButton.add_theme_stylebox_override("normal", styleBox)


func _on_update_stage_colors(colors_map: Dictionary, instructions):
	if StageControl.color_system:
		# fixed instruction color
		if colors_map.size() > stage_number and instructions[stage_number] != -1:
			var styleBox: StyleBoxFlat = StyleBoxFlat.new()
			if colors_map.has(instructions[stage_number]):
				detail.stage_color = colors_map[instructions[stage_number]]
			else:
				detail.stage_color = Color.BLACK
			styleBox.bg_color = detail.stage_color
			$VBoxContainer/PanelContainer/StageButton.add_theme_stylebox_override("normal", styleBox)
			return
		else:#if colors_map.size() == 0:
			$VBoxContainer/PanelContainer/StageButton.remove_theme_stylebox_override("normal")
	else:
		add_fixed_stage_color()


func _on_resized():
	await Globals.components_tween_finished
	await get_tree().process_frame # positions are broken unless we wait a frame
	
	detail.calculate_positions()
	detail.draw_lines()


func _on_stage_color_mode_changed(mode: int) -> void:
	pass

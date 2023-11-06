extends Control
class_name Stage


var expanded: bool = false
var detail: Panel = null
@export var stage_name: String
@export var stage_number: int

var tween: Tween = null

var stage_color: Color = Color.TRANSPARENT

var lines_groups: Array[String] = ["PC_InstMem", "Mux_PC", "PC_Add", "Add_IFID", "InstMem_IFID", "Add_Mux"]

@onready var stage_button: Button = $VBoxContainer/PanelContainer/StageButton

func _ready() -> void:
	$VBoxContainer/PanelContainer/StageButton.text = stage_name
	Globals.stage_color_mode_changed.connect(_on_stage_color_mode_changed)
	get_tree().root.size_changed.connect(_on_resized)
	StageControl.update_stage_colors.connect(_on_update_stage_colors)
	
	
	$VBoxContainer.add_child(load("res://stages/" + stage_name.to_lower() + "_detail.tscn").instantiate())
	detail = $VBoxContainer.get_child(1)
	detail.stage_color = stage_color
	add_fixed_stage_color()
	LineManager.add_stage_detail_path(detail.get_path())
	
	Globals.current_stage_sizes_updated.connect(_on_Globals_current_stage_sizes_updated)


func _on_stage_button_pressed():
	if !Globals.can_click:
		return
	Globals.expand_stage.emit(stage_number)


func tween_size():
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	Globals.is_stage_tweening = true
	if stage_number == 4: #WB does not need as much space
		tween.tween_property(self, "size_flags_stretch_ratio", 1.0 if expanded else 1.5, 0.15)
	else:
		tween.tween_property(self, "size_flags_stretch_ratio", 1.0 if expanded else 2.75, 0.15)
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
		styleBox.set_corner_radius_all(5)
		detail.stage_color = stage_color
		stage_button.add_theme_stylebox_override("normal", styleBox)
		stage_button.add_theme_stylebox_override("hover", styleBox)
		stage_button.add_theme_stylebox_override("pressed", styleBox)


func _on_update_stage_colors(colors_map: Dictionary, instructions):
	if StageControl.color_system:
		# fixed instruction color
		if colors_map.size() > stage_number and instructions[stage_number] != -1:
			var styleBox: StyleBoxFlat = StyleBoxFlat.new()
			if colors_map.has(instructions[stage_number]):
				detail.stage_color = colors_map[instructions[stage_number]]
			else:
				detail.stage_color = Color.TRANSPARENT
			styleBox.bg_color = detail.stage_color
			styleBox.set_corner_radius_all(3)
			stage_button.add_theme_stylebox_override("normal", styleBox)
			stage_button.add_theme_stylebox_override("hover", styleBox)
			stage_button.add_theme_stylebox_override("pressed", styleBox)
			return
		else:#if colors_map.size() == 0:
			stage_button.remove_theme_stylebox_override("normal")
			stage_button.remove_theme_stylebox_override("hover")
			stage_button.remove_theme_stylebox_override("pressed")
			detail.stage_color = Color.TRANSPARENT
	else:
		add_fixed_stage_color()


signal resize_completed
var timer: SceneTreeTimer = null
var resize_completed_emited:= false
func _on_resized():
	if detail:
		detail.hide_lines()
	resize_completed_emited = false
	Globals.update_current_stage_sizes(size.x, stage_number)
	if timer != null:
		timer.timeout.disconnect(_on_Globals_components_tween_finished)
	timer = get_tree().create_timer(0.5)
	timer.timeout.connect(_on_Globals_components_tween_finished)
	_await_component_tween_finished()
	await resize_completed
	# some stages are not getting this signal
	# root of the line bug? no need for marker_updated if fixed?
	await get_tree().process_frame # positions are broken unless we wait a frame
	
	detail.calculate_positions()
#	if abs(Globals.current_stage_sizes[stage_number] - size.x) <= 1:
	detail.draw_lines()
	Globals.can_click = true


func _on_stage_color_mode_changed(mode: int) -> void:
	pass


func _on_Globals_components_tween_finished() -> void:
#	if resize_completed_emited:
#		return
	resize_completed.emit()
	resize_completed_emited = true


func _await_component_tween_finished() -> void:
	await Globals.components_tween_finished
	_on_Globals_components_tween_finished()


func _on_Globals_current_stage_sizes_updated(stage: int) -> void:
	return
	if stage != stage_number:
		return
	if abs(Globals.current_stage_sizes[stage_number] - size.x) <= 1:
		detail.draw_lines()
		Globals.can_click = true
		if stage_number == 0:
			pass

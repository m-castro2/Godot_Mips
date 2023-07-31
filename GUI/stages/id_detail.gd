extends Panel

@onready var registers_bank = $RegistersBank
@onready var detailed_control = $DetailedControl
@onready var add = $DetailedControl/Add
@onready var control = $DetailedControl/Control
@onready var hazard_detection_unit = $HazardDetectionUnit

@onready var lines: Array[Node] = [ $OutsideLines/HDU_PC,
									$DetailedControl/PC]

@onready var stage_color: Color = get_parent().get_parent().stage_color
var stage: Globals.STAGES = Globals.STAGES.ID

var is_shrunk: bool = false


func _ready():
	Globals.stage_tween_finished.connect(_on_stage_tween_finished)
	LineManager.id_line_active.connect(_on_LineManager_id_line_active)
	show_lines()


func show_lines() -> void:
	## Probably not needed once CpuFlex manages which lines to show
	LineManager.id_line_active.emit(LineManager.id_lines.HDU_PC)
	LineManager.id_line_active.emit(LineManager.id_lines.PC)


func show_detail(value: bool) -> void:
	detailed_control.visible = true
	for child in detailed_control.get_children():
		if child is Button:
			child.visible = value or child.requested
		elif child is Line2D:
			pass#child.draw_requested = value and child.active and get_parent().get_parent().expanded


func calculate_positions() -> void:
	return
	

func draw_lines() -> void:
	for line in lines:
		if line.active:
			line.add_points()
			line.animate_line(stage_color)


func _on_registers_bank_pressed() -> void:
	registers_bank.show_info_window()


func _get_all_children(node: Node, shrink: bool):
	for child in node.get_children():
		if child is Line2D or child is Marker2D:
			continue
		if child.get_child_count() > 0:
			_get_all_children(child, shrink)
		if child.name == "DetailedControl": #dont shrink DetailedControl size
			continue
		if child is Button or child is Label:
			if shrink:
				child.add_theme_font_size_override("font_size", child.get_theme_font_size("font_size") - 8)
			else:
				child.add_theme_font_size_override("font_size", child.get_theme_font_size("font_size") + 8)
			child.custom_minimum_size = child.custom_minimum_size * .66 if shrink else child.custom_minimum_size / .66
			child.size = child.custom_minimum_size


func _on_stage_tween_finished(_stage):
	return
	var shrink = (DisplayServer.window_get_size().y < 960)
	if shrink and detailed_control.visible:
		_get_all_children(self, true)
		is_shrunk = true
	elif is_shrunk:
		_get_all_children(self, false)
		is_shrunk = false
	
	await get_tree().process_frame
	Globals.recenter_window.emit()


func _on_resized():
	return
	if detailed_control:
		var shrink = (DisplayServer.window_get_size().y < 960)
		if !shrink and is_shrunk:
			_get_all_children(self, false)
			is_shrunk = false
		elif shrink and !is_shrunk and detailed_control.visible:
			_get_all_children(self, true)
			is_shrunk = true
		
		await get_tree().process_frame
		Globals.recenter_window.emit()


func _on_gui_input(_event):
	if Input.is_action_just_pressed("Click"):
		if Globals.close_window_handled:
			Globals.close_window_handled = false
		else:
			Globals.expand_stage.emit(1)


func _on_LineManager_id_line_active(line: LineManager.id_lines) -> void:
	match  line:
		LineManager.id_lines.HDU_PC:
			$OutsideLines/HDU_PC.origin_component = hazard_detection_unit
			$OutsideLines/HDU_PC.origin_component.request_stage_origin.append(Globals.STAGES.IF)
			$OutsideLines/HDU_PC.target = LineManager.get_stage_component(0, "pc").get_node("UpperInput")
			$OutsideLines/HDU_PC.active = true
		LineManager.id_lines.PC:
			await LineManager.if_stage_updated
			await LineManager.stage_register_updated
			($DetailedControl/PC as Line).origin = get_node(LineManager.stage_register_path[0]).get("pc_2")
			$DetailedControl/PC.target = get_node(LineManager.stage_register_path[1]).get("pc")
			$DetailedControl/PC.active = true


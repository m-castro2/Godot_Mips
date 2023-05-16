extends Panel

@onready var registers_bank = $RegistersBank
@onready var fp_registers_bank = $FPRegistersBank
@onready var detailed_control = $DetailedControl
@onready var add = $DetailedControl/Add
@onready var mux_control = $DetailedControl/MuxControl
@onready var mux_rt_data = $DetailedControl/MuxRtData
@onready var mux_reg_dst = $DetailedControl/MuxRegDst
@onready var control = $DetailedControl/Control
@onready var hazard_detection_unit = $DetailedControl/HazardDetectionUnit
@onready var sign_extend = $DetailedControl/SignExtend

var is_shrunk: bool = false


func _ready():
	Globals.stage_tween_finished.connect(_on_stage_tween_finished)


func show_detail(value: bool) -> void:
	detailed_control.visible = value


func calculate_positions():
	var control_size: Vector2 = detailed_control.size
	if add: #if one is ready all are ready
		add.position = Vector2((registers_bank.position.x + registers_bank.size.x/2)*.925 - add.size.x/2, \
		(registers_bank.position.y - detailed_control.position.y)*.75-add.size.y/2 + detailed_control.position.y)
		
		control.position = add.position - control.size
		
		hazard_detection_unit.position = Vector2(control.position.x + control.size.x/2 - hazard_detection_unit.size.x/2, control_size.y*.02)
		
		mux_control.position = control.position + Vector2(control.size.x + detailed_control.size.x*.15, control.size.y/2 - mux_control.size.y/2)
		
		mux_rt_data.position = Vector2(registers_bank.position.x + registers_bank.size.x + (registers_bank.position.x)*.5 , \
		registers_bank.position.y + registers_bank.size.y - mux_rt_data.size.y/2)
		
		sign_extend.position = Vector2(registers_bank.position.x + registers_bank.size.x/2 - sign_extend.size.x/2, \
		((registers_bank.position.y + registers_bank.size.y) + (fp_registers_bank.position.y - (registers_bank.position.y + registers_bank.size.y))/3) - sign_extend.size.y/2)
		
		mux_reg_dst.position = Vector2(registers_bank.position.x + registers_bank.size.x/2 - mux_reg_dst.size.x/2, \
		((registers_bank.position.y + registers_bank.size.y) + (fp_registers_bank.position.y - (registers_bank.position.y + registers_bank.size.y))/3*2) - mux_reg_dst.size.y/2)


func draw_lines():
	pass


func _on_registers_bank_pressed():
	registers_bank.show_info_window()


func _on_fp_registers_bank_pressed():
	fp_registers_bank.show_info_window()


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


func _on_stage_tween_finished():
	var shrink = (DisplayServer.window_get_size().y < 960)
	if shrink and detailed_control.visible:
		_get_all_children(self, true)
		is_shrunk = true
	elif is_shrunk:
		_get_all_children(self, false)
		is_shrunk = false


func _on_resized():
	if detailed_control:
		var shrink = (DisplayServer.window_get_size().y < 960)
		if !shrink and is_shrunk:
			_get_all_children(self, false)
			is_shrunk = false
		elif shrink and !is_shrunk and detailed_control.visible:
			_get_all_children(self, true)
			is_shrunk = true

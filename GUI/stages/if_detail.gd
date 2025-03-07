extends Panel

var expanded: bool = false
@onready var detailed_control: Control = $DetailedControl
@onready var add: MainComponent = $Add
@onready var pc: MainComponent = $PC
@onready var instructions_memory_button: MainComponent = $InstructionsMemoryButton
@onready var instruction_memory_info_window = $InstructionsMemoryButton/InstructionMemoryInfoWindow

@onready var stage_color: Color = get_parent().get_parent().stage_color:
	set(value):
		stage_color = value
		for line in lines:
			line.line_color = value

var stage: Globals.STAGES = Globals.STAGES.IF


@onready var pc_ifid: ComplexLine2D = $PC/PC_IFID
@onready var add_pc = $Add/Add_PC
@onready var add_ifid = $Add/Add_IFID

@onready var lines: Array[Node] = [
	$"Add/4_Add",
	$PC/PC_InstMem,
	$PC/PC_Add,
	$InstructionsMemoryButton/InstMem_IFID,
	pc_ifid,
	add_pc,
	add_ifid]

func _ready() -> void:
	LineManager.if_line_active.connect(_on_LineManager_if_line_active)
	Globals.stage_tween_finished.connect(calculate_positions.unbind(1))
	show_detail(true)


func show_detail(value: bool) -> void:
	detailed_control.visible = true
	for child in detailed_control.get_children():
		if child is Button:
			child.visible = value or child.requested
		elif child is Line2D:
			child.draw_requested = value and child.active and get_parent().get_parent().expanded
	
	#lines[0].animate_line(stage_color) # lines share ShaderMaterial so animating one animates them all


func calculate_positions() -> void:
	%IFID_UpperInput.global_position = Vector2(global_position.x + size.x, add.global_position.y + add.size.y/2)
	%IFID_MiddleInput.global_position = Vector2(global_position.x + size.x, global_position.y + size.y/2)
	
	LineManager.if_stage_updated.emit()


#STILL NEEDED
func draw_lines() -> void:
	for line in lines:
		if line.active:
			line.add_points()
			line.animate_line()
			line.check_visibility(false)


func hide_lines() -> void:
	for line in lines:
		line.visible = false


func _get_all_children(node: Node, zoom_value: bool):
	for child in node.get_children():
		if child is Line2D or child is Marker2D:
			continue
		if child.get_child_count() > 0:
			_get_all_children(child, zoom_value)
		child.size = child.size / .9 if zoom_value else child.size * .9


func _on_instructions_memory_button_pressed() -> void:
	instruction_memory_info_window.add_info()
	#instructions_memory_button.show_info_window()


func _on_pc_pressed() -> void:
	pc.show_info_window()


func _on_add_pressed() -> void:
	add.show_info_window()


func _on_gui_input(_event) -> void:
	if !Globals.can_click and Globals.current_cycle:
		return
	if Input.is_action_just_pressed("Click"):
		Input.flush_buffered_events()
		Globals.can_click = false
		if Globals.close_window_handled:
			Globals.close_window_handled = false
		else:
			Globals.expand_stage.emit(0)


func _on_LineManager_if_line_active(line: LineManager.if_lines) -> void:
	match  line:
		LineManager.if_lines.ADD_IFID:
			$Add/Add_IFID.active = true
		LineManager.if_lines.PC_INSTMEM:
			$PC/PC_InstMem.active = true
		LineManager.if_lines.PC_ADD:
			$PC/PC_Add.active = true
		LineManager.if_lines.INSTMEM_IFID:
			$InstructionsMemoryButton/InstMem_IFID.active = true
		LineManager.if_lines._4_ADD:
			$"Add/4_Add".active = true
		LineManager.if_lines.ADD_PC:
			add_pc.active = true
		LineManager.if_lines.PC_IFID:
			pc_ifid.active = true

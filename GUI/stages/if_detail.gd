extends Panel

var expanded: bool = false
@onready var detailed_control: Control = $DetailedControl
@onready var add: ClickableComponent = $DetailedControl/Add
@onready var mux = $DetailedControl/Mux
@onready var pc: ClickableComponent = $DetailedControl/PC
@onready var instructions_memory_button: MainComponent = $InstructionsMemoryButton
@onready var if_flush = $DetailedControl/IF_Flush

@onready var lines: Array[Node] = [ $DetailedControl/Add/Add_Mux, 
	$DetailedControl/Add/Add_IFID,
	$DetailedControl/Mux/Mux_PC,
	$DetailedControl/PC/PC_InstMem,
	$DetailedControl/PC/PC_Add,
	$DetailedControl/InstructionsMemoryDetail/InstMem_IFID,
	$DetailedControl/OutsideLines/MuxBranch, 
	$DetailedControl/OutsideLines/MuxRs, 
	$DetailedControl/OutsideLines/MuxJump,
	$DetailedControl/IF_Flush/IFflush_IFID,
	$DetailedControl/OutsideLines/PCSrc, 
	$DetailedControl/OutsideLines/PCWrite]


func _ready():
	LineManager.if_line_active.connect(_on_LineManager_if_line_active)


func show_detail(value: bool) -> void:
	detailed_control.visible = value
	#LineManager.if_line_active.emit(LineManager.if_lines.ADD_IFID)
	LineManager.if_line_active.emit(LineManager.if_lines.PC_ADD)


func calculate_positions():
	var control_size: Vector2 = detailed_control.size
	
	if add: #if one is ready all are ready
		
		add.global_position = Vector2((instructions_memory_button.global_position.x + instructions_memory_button.size.x/2) - add.size.x/2, \
		(control_size.y/2 - instructions_memory_button.size.y/2)/2-add.size.y/2 + detailed_control.global_position.y + 10)
		
		pc.position = Vector2(instructions_memory_button.position.x/2 - pc.size.x/2 + detailed_control.size.x*.05, \
		control_size.y/2 - pc.size.y/2 )
		
		mux.position = Vector2(instructions_memory_button.position.x/2 - mux.size.x/2 - detailed_control.size.x*.1, \
		control_size.y/2 - mux.size.y/2 )
		
		%IFID_UpperInput.global_position = Vector2(global_position.x + size.x, add.global_position.y + add.size.y/2)
		%IFID_MiddleInput.global_position = Vector2(global_position.x + size.x, instructions_memory_button.global_position.y + instructions_memory_button.size.y/2)
		
		%MuxBranchOrigin.global_position = Vector2(global_position.x + size.x, global_position.y + size.y * .01)
		%MuxRsOrigin.global_position = Vector2(global_position.x + size.x, global_position.y + size.y * .97)
		%MuxJumpOrigin.global_position = Vector2(global_position.x + size.x, global_position.y + size.y * .95)
		%PCSrcOrigin.global_position = Vector2(global_position.x + size.x, global_position.y + size.y * .001)
		%PCWriteOrigin.global_position = Vector2(global_position.x + size.x, global_position.y + size.y * .005)
		
		if_flush.position = Vector2(pc.position.x, size.y * .8)
		%IFID_IFflushInput.global_position = Vector2(global_position.x + size.x, if_flush.global_position.y + if_flush.size.y/2)

func draw_lines():
	for line in lines:
		line.add_points()


func _get_all_children(node: Node, zoom_value: bool):
	for child in node.get_children():
		if child is Line2D or child is Marker2D:
			continue
		if child.get_child_count() > 0:
			_get_all_children(child, zoom_value)
		child.size = child.size / .9 if zoom_value else child.size * .9


func _on_instructions_memory_button_pressed():
	instructions_memory_button.show_info_window()


func _on_pc_pressed():
	pc.show_info_window()


func _on_add_pressed():
	add.show_info_window()


func _on_gui_input(_event):
	if Input.is_action_just_pressed("Click"):
		if Globals.close_window_handled:
			Globals.close_window_handled = false
		else:
			Globals.expand_stage.emit(0)


func _on_LineManager_if_line_active(line: LineManager.if_lines):
	match  line:
		LineManager.if_lines.ADD_IFID:
			$DetailedControl/Add/Add_IFID.active = true
		LineManager.if_lines.ADD_MUX:
			$DetailedControl/Add/Add_Mux.active = true
		LineManager.if_lines.PC_INSTMEM:
			$DetailedControl/PC/PC_Add.active = true

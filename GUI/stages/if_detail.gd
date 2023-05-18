extends Panel

var expanded: bool = false
@onready var detailed_control: Control = $DetailedControl
@onready var add: ClickableComponent = $DetailedControl/Add
@onready var mux = $DetailedControl/Mux
@onready var pc: ClickableComponent = $DetailedControl/PC
@onready var instructions_memory_button: MainComponent = $InstructionsMemoryButton

var lines_groups: Array[String] = ["PC_InstMem", "Mux_PC", "PC_Add", "Add_IFID", "InstMem_IFID", "Add_Mux"]

func show_detail(value: bool) -> void:
	detailed_control.visible = value


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


func draw_lines():
	await get_tree().process_frame
	var line: Line2D = null
	var points: Array[Vector2] = []
	for group in lines_groups:
		for node in get_tree().get_nodes_in_group(group):
			if node is ComplexLine2D:
				node.add_points()
			elif node is Line2D:
				node.clear_points()
				line = node
				line.global_position = Vector2(0,0)
			else:
				points.push_back(node.global_position)
		for point in points:
			line.add_point(point)
		points.clear()


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
		Globals.expand_stage.emit(0)
